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

    // Handle deletion
    if (!taskData) {
      // Clean up references if needed (omitted for brevity, usually mostly needed for users)
      // Ideally delete from groups/... and users/... 
      // For now focusing on Creation/Update
      return;
    }

    const { groupId, title, status, assignedTo, createdBy } = taskData;
    const summary = {
      id: taskId,
      title,
      status,
      priority: taskData.priority,
      dueAt: taskData.dueAt,
      updatedAt: taskData.updatedAt,
    };

    // 1. Sync to Group
    await db.doc(`groups/${groupId}/tasks/${taskId}`).set(summary);

    // 2. Sync to Users
    if (assignedTo && assignedTo.length > 0) {
      const batch = db.batch();
      assignedTo.forEach((uid) => {
        const ref = db.doc(`users/${uid}/tasks/${taskId}`);
        batch.set(ref, { ...summary, groupId });
      });
      await batch.commit();
    }

    // 3. Chat System Message
    // Determine if we should send a message
    let systemMessage = "";

    if (!previousData) {
      // Created
      systemMessage = `📝 New Task Created: "${title}"`;
    } else {
      // Updated
      if (previousData.status !== status) {
        systemMessage = `🔄 Task "${title}" marked as ${status.replace('_', ' ').toUpperCase()}`;
      }
    }

    if (systemMessage) {
      await postSystemMessage(groupId, systemMessage);
    }
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

    if (!issueData) return;

    const { groupId, title, status, severity, assignedTo } = issueData;
    const summary = {
      id: issueId,
      title,
      status,
      severity,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // 1. Sync to Group
    await db.doc(`groups/${groupId}/issues/${issueId}`).set(summary);

    // 2. Sync to Users
    if (assignedTo && assignedTo.length > 0) {
      const batch = db.batch();
      assignedTo.forEach((uid) => {
        const ref = db.doc(`users/${uid}/issues/${issueId}`);
        batch.set(ref, { ...summary, groupId });
      });
      await batch.commit();
    }

    // 3. Chat Log
    let systemMessage = "";
    if (!previousData) {
      systemMessage = `🚨 New Issue Reported: "${title}" (${severity})`;
    } else if (previousData.status !== status) {
      systemMessage = `🔧 Issue "${title}" status updated to ${status.toUpperCase()}`;
    }

    if (systemMessage) {
      await postSystemMessage(groupId, systemMessage);
    }
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
