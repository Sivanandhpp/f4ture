const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * Triggers when a member is added, updated, or removed from a group.
 * Syncs the membership data to the user's 'groups' subcollection.
 */
exports.syncGroupToUser = functions.firestore
  .document("groups/{groupId}/members/{userId}")
  .onWrite(async (change, context) => {
    const { groupId, userId } = context.params;

    // 1. Handle deletion (member removed)
    if (!change.after.exists) {
      console.log(`Removing group ${groupId} from user ${userId}`);
      await db.doc(`users/${userId}/groups/${groupId}`).delete();
    } else {
      // 2. Handle add/update
      const memberData = change.after.data();

      // Fetch group details to get the 'type'
      const groupDoc = await db.collection("groups").doc(groupId).get();
      const groupType = groupDoc.exists ? groupDoc.data().type : "public";

      const userGroupData = {
        joinedAt: memberData.joinedAt,
        role: memberData.role,
        type: groupType, // Store type for efficient recalculation
      };

      console.log(`Syncing group ${groupId} to user ${userId} (Type: ${groupType})`);
      await db.doc(`users/${userId}/groups/${groupId}`).set(
        userGroupData,
        { merge: true },
      );
    }

    // 3. Recalculate User Global Role
    return recalculateUserRole(userId);
  });

/**
 * Recalculates and updates the user's global role based on group memberships.
 * Hierarchy: attendee < organiser < lead
 *
 * @param {string} userId The user ID to recalculate.
 */
async function recalculateUserRole(userId) {
  // 1. Fetch current user to check for immunity (core/admin)
  const userDoc = await db.collection("users").doc(userId).get();
  if (!userDoc.exists) return;

  const userData = userDoc.data();
  const currentRole = userData.role;

  // Immunity check: core (3) or admin (4) are not affected by automation
  if (currentRole === "core" || currentRole === "admin") {
    console.log(`User ${userId} is ${currentRole}. Skipping automated role update.`);
    return;
  }

  const userGroupsSnapshot = await db
    .collection(`users/${userId}/groups`)
    .get();

  let highestRoleLevel = 0; // 0: attendee, 1: organiser, 2: lead

  userGroupsSnapshot.forEach((doc) => {
    const data = doc.data();
    const groupType = data.type;
    const memberRole = data.role;

    if (groupType === "committee") {
      // Membership in committee -> at least organiser
      if (highestRoleLevel < 1) highestRoleLevel = 1;

      // Admin of committee -> lead
      if (memberRole === "admin") {
        highestRoleLevel = 2;
      }
    }
  });

  const roleMap = {
    0: "attendee",
    1: "organiser",
    2: "lead",
  };

  const newRole = roleMap[highestRoleLevel];
  console.log(`Recalculated role for ${userId}: ${newRole} (Level: ${highestRoleLevel})`);

  await db.collection("users").doc(userId).update({ role: newRole });
}

/**
 * Triggers when a task is created or updated.
 * 1. Syncs reference to groups/{groupId}/tasks/{taskId}
 * 2. Syncs reference to users/{userId}/tasks/{taskId} for all assignees
 * 3. Posts a system message to the group chat
 */
exports.onTaskWrite = functions.firestore
  .document("tasks/{taskId}")
  .onWrite(async (change, context) => {
    const taskId = context.params.taskId;
    const taskData = change.after.exists ? change.after.data() : null;
    const previousData = change.before.exists ? change.before.data() : null;

    const batch = db.batch();

    // --- HANDLE DELETION ---
    if (!taskData) {
      console.log(`Task ${taskId} deleted. Cleaning up references.`);
      if (previousData) {
        // Remove from group
        const groupRef = db.doc(`groups/${previousData.groupId}/tasks/${taskId}`);
        batch.delete(groupRef);

        // Remove from all assignees
        if (previousData.assignedTo && previousData.assignedTo.length > 0) {
          previousData.assignedTo.forEach((uid) => {
            const userRef = db.doc(`users/${uid}/tasks/${taskId}`);
            batch.delete(userRef);
          });
        }
      }
      return batch.commit();
    }

    // --- HANDLE UPDATE/CREATE ---
    const { groupId, title, status, assignedTo, priority } = taskData;

    // Prepare lightweight summary for denormalization
    const summary = {
      id: taskId,
      title,
      status,
      priority: priority || "medium",
      dueAt: taskData.dueAt,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      groupId, // Useful context
    };

    // 1. Sync to Group
    const groupTaskRef = db.doc(`groups/${groupId}/tasks/${taskId}`);
    batch.set(groupTaskRef, summary, { merge: true });

    // 2. Sync to Users (Handle added/removed assignees)
    const oldAssignees = previousData ? (previousData.assignedTo || []) : [];
    const newAssignees = assignedTo || [];

    // Identify removed users
    const removedUsers = oldAssignees.filter(uid => !newAssignees.includes(uid));
    removedUsers.forEach(uid => {
      const userRef = db.doc(`users/${uid}/tasks/${taskId}`);
      batch.delete(userRef);
    });

    // Identify added/kept users (update all current assignees to ensure fresh data)
    newAssignees.forEach(uid => {
      const userRef = db.doc(`users/${uid}/tasks/${taskId}`);
      batch.set(userRef, summary, { merge: true });
    });

    // 3. Chat System Message
    // Post only on Create or Status Change
    let systemMessage = "";

    if (!previousData) {
      // Created
      // Format date nicely if possible, but JS date handling in functions can be basic.
      // We'll rely on client showing details, messsage is just notification.
      systemMessage = `📝 New Task: "${title}"`;
    } else {
      // Status Changed
      if (previousData.status !== status) {
        const readableStatus = status.replace(/_/g, ' ').toUpperCase();
        systemMessage = `🔄 Task "${title}" is now ${readableStatus}`;
      }
      // Reassigned? (Optional: could notify if assignee list changes)
    }

    if (systemMessage) {
      const msgRef = db.collection("groups").doc(groupId).collection("messages").doc();
      batch.set(msgRef, {
        senderId: "system",
        senderName: "System",
        type: "system",
        text: systemMessage,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        status: "sent",
      });
    }

    return batch.commit();
  });

/**
 * Triggers when an issue is created or updated.
 * Syncs references and posts chat logs.
 */
exports.onIssueWrite = functions.firestore
  .document("issues/{issueId}")
  .onWrite(async (change, context) => {
    const issueId = context.params.issueId;
    const issueData = change.after.exists ? change.after.data() : null;
    const previousData = change.before.exists ? change.before.data() : null;

    const batch = db.batch();

    // --- HANDLE DELETION ---
    if (!issueData) {
      console.log(`Issue ${issueId} deleted. Cleaning up references.`);
      if (previousData) {
        const groupRef = db.doc(`groups/${previousData.groupId}/issues/${issueId}`);
        batch.delete(groupRef);

        if (previousData.assignedTo && previousData.assignedTo.length > 0) {
          previousData.assignedTo.forEach((uid) => {
            const userRef = db.doc(`users/${uid}/issues/${issueId}`);
            batch.delete(userRef);
          });
        }
      }
      return batch.commit();
    }

    // --- HANDLE UPDATE/CREATE ---
    const { groupId, title, status, severity, assignedTo } = issueData;

    const summary = {
      id: issueId,
      title,
      status,
      severity,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      groupId,
    };

    // 1. Sync to Group
    const groupIssueRef = db.doc(`groups/${groupId}/issues/${issueId}`);
    batch.set(groupIssueRef, summary, { merge: true });

    // 2. Sync to Users (Admins/Assignees)
    const oldAssignees = previousData ? (previousData.assignedTo || []) : [];
    const newAssignees = assignedTo || [];

    const removedUsers = oldAssignees.filter(uid => !newAssignees.includes(uid));
    removedUsers.forEach(uid => {
      const userRef = db.doc(`users/${uid}/issues/${issueId}`);
      batch.delete(userRef);
    });

    newAssignees.forEach(uid => {
      const userRef = db.doc(`users/${uid}/issues/${issueId}`);
      batch.set(userRef, summary, { merge: true });
    });

    // 3. Chat Log
    let systemMessage = "";
    if (!previousData) {
      systemMessage = `🚨 New Issue Reported: "${title}" (${severity})`;
    } else if (previousData.status !== status) {
      const readableStatus = status.replace(/_/g, ' ').toUpperCase();
      systemMessage = `🔧 Issue "${title}" status updated to ${readableStatus}`;
    }

    if (systemMessage) {
      const msgRef = db.collection("groups").doc(groupId).collection("messages").doc();
      batch.set(msgRef, {
        senderId: "system",
        senderName: "System",
        type: "system",
        text: systemMessage,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        status: "sent",
      });
    }

    return batch.commit();
  });

/**
 * Triggers when a new message is added to a group.
 * 1. Updates group's lastMessage and lastMessageAt.
 * 2. Increments unreadCount for all members (except sender).
 */
exports.onMessageCreate = functions.firestore
  .document("groups/{groupId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const { groupId } = context.params;
    const messageData = snap.data();
    const { text, type, senderId, createdAt } = messageData;

    let displayMessage = text;
    if (type === "image") displayMessage = "📷 Image";
    if (type === "file") displayMessage = "📁 File";
    if (type === "system") return null; // Don't track unread/last-msg for system? Or maybe yes?
    // Let's track system messages too for context, but maybe not unread counts?
    // User requested "unread message bubbles", usually implies user messages. 
    // But system messages (tasks) are important too. Let's count them for now.

    const batch = db.batch();

    // 1. Update Group details
    const groupRef = db.collection("groups").doc(groupId);
    batch.update(groupRef, {
      lastMessage: displayMessage,
      lastMessageAt: createdAt || admin.firestore.FieldValue.serverTimestamp(),
    });

    // 2. Increment unread count for all members
    // We need to fetch members. For large groups, this might be slow, but for now strict "members" subcollection.
    const membersSnap = await groupRef.collection("members").get();

    membersSnap.forEach((doc) => {
      const userId = doc.id;
      // Skip sender if it's a user message (system messages have no specific sender user usually, or "system")
      if (userId !== senderId) {
        const userGroupRef = db.doc(`users/${userId}/groups/${groupId}`);
        batch.set(
          userGroupRef,
          {
            unreadCount: admin.firestore.FieldValue.increment(1),
            lastMessage: displayMessage,
            lastMessageAt: createdAt || admin.firestore.FieldValue.serverTimestamp(),
            // Ensure other fields exist if document was missing (set with merge true handles updates)
          },
          { merge: true }
        );
      }
    });

    return batch.commit();
  });

/**
 * Helper to post a system message to a group chat.
 */
async function postSystemMessage(groupId, text) {
  await db.collection("groups").doc(groupId).collection("messages").add({
    senderId: "system",
    senderName: "System",
    type: "system",
    text: text,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    status: "sent",
  });
}
