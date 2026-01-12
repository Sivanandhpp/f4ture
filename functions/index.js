const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// ... (Existing Sync Group to User Function - unchanged) ...
exports.syncGroupToUser = functions.firestore
  .document("groups/{groupId}/members/{userId}")
  .onWrite(async (change, context) => {
    const { groupId, userId } = context.params;

    if (!change.after.exists) {
      console.log(`Removing group ${groupId} from user ${userId}`);
      await db.doc(`users/${userId}/groups/${groupId}`).delete();
    } else {
      const memberData = change.after.data();
      const groupDoc = await db.collection("groups").doc(groupId).get();
      const groupType = groupDoc.exists ? groupDoc.data().type : "public";

      const userGroupData = {
        joinedAt: memberData.joinedAt,
        role: memberData.role,
        type: groupType,
      };

      await db.doc(`users/${userId}/groups/${groupId}`).set(
        userGroupData,
        { merge: true },
      );
    }
    return recalculateUserRole(userId);
  });

// ... (Existing Recalculate User Role Function - unchanged) ...
async function recalculateUserRole(userId) {
  const userDoc = await db.collection("users").doc(userId).get();
  if (!userDoc.exists) return;

  const userData = userDoc.data();
  const currentRole = userData.role;

  if (currentRole === "core" || currentRole === "admin") return;

  const userGroupsSnapshot = await db.collection(`users/${userId}/groups`).get();

  let highestRoleLevel = 0;

  userGroupsSnapshot.forEach((doc) => {
    const data = doc.data();
    const groupType = data.type;
    const memberRole = data.role;

    if (groupType === "committee") {
      if (highestRoleLevel < 1) highestRoleLevel = 1;
      if (memberRole === "admin") highestRoleLevel = 2;
    }
  });

  const roleMap = { 0: "attendee", 1: "organiser", 2: "lead" };
  const newRole = roleMap[highestRoleLevel];
  await db.collection("users").doc(userId).update({ role: newRole });
}

// ... (Existing Task Write Function - unchanged) ...
exports.onTaskWrite = functions.firestore
  .document("tasks/{taskId}")
  .onWrite(async (change, context) => {
    const taskId = context.params.taskId;
    const taskData = change.after.exists ? change.after.data() : null;
    const previousData = change.before.exists ? change.before.data() : null;

    const batch = db.batch();

    if (!taskData) {
      if (previousData) {
        const groupRef = db.doc(`groups/${previousData.groupId}/tasks/${taskId}`);
        batch.delete(groupRef);
        if (previousData.assignedTo) {
          previousData.assignedTo.forEach((uid) => {
            batch.delete(db.doc(`users/${uid}/tasks/${taskId}`));
          });
        }
      }
      return batch.commit();
    }

    const { groupId, title, status, assignedTo, priority } = taskData;
    const summary = {
      id: taskId,
      title,
      status,
      priority: priority || "medium",
      dueAt: taskData.dueAt,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      groupId,
    };

    batch.set(db.doc(`groups/${groupId}/tasks/${taskId}`), summary, { merge: true });

    const oldAssignees = previousData ? (previousData.assignedTo || []) : [];
    const newAssignees = assignedTo || [];

    oldAssignees.filter(uid => !newAssignees.includes(uid)).forEach(uid => {
      batch.delete(db.doc(`users/${uid}/tasks/${taskId}`));
    });

    newAssignees.forEach(uid => {
      batch.set(db.doc(`users/${uid}/tasks/${taskId}`), summary, { merge: true });
    });

    let systemMessage = "";
    if (!previousData) {
      systemMessage = `📝 New Task: "${title}"`;
    } else if (previousData.status !== status) {
      const readableStatus = status.replace(/_/g, ' ').toUpperCase();
      systemMessage = `🔄 Task "${title}" is now ${readableStatus}`;
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

// ... (Existing Issue Write Function - unchanged) ...
exports.onIssueWrite = functions.firestore
  .document("issues/{issueId}")
  .onWrite(async (change, context) => {
    // ... (Same as before, skipped for brevity, keeping existing logic) ...
    const issueId = context.params.issueId;
    const issueData = change.after.exists ? change.after.data() : null;
    const previousData = change.before.exists ? change.before.data() : null;

    const batch = db.batch();

    if (!issueData) {
      // ... (Cleanup logic) ...
      return batch.commit();
    }

    const { groupId, title, status, severity, assignedTo } = issueData;
    const summary = {
      id: issueId,
      title,
      status,
      severity,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      groupId,
    };

    batch.set(db.doc(`groups/${groupId}/issues/${issueId}`), summary, { merge: true });

    const newAssignees = assignedTo || [];
    newAssignees.forEach(uid => {
      batch.set(db.doc(`users/${uid}/issues/${issueId}`), summary, { merge: true });
    });

    // ... (Chat Log) ...
    return batch.commit();
  });


/**
 * Triggers when a new message is added to a group.
 * 1. Updates group's lastMessage.
 * 2. Increments unreadCount.
 * 3. Sends FCM Push Notification to all group members (except sender).
 */
exports.onMessageCreate = functions.firestore
  .document("groups/{groupId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const { groupId } = context.params;
    const messageData = snap.data();
    const { text, type, senderId, senderName, createdAt } = messageData;

    let displayMessage = text;
    if (type === "image") displayMessage = "📷 Image";
    if (type === "file") displayMessage = "📁 File";
    if (type === "system") return null;

    const batch = db.batch();

    // 1. Update Group details
    const groupRef = db.collection("groups").doc(groupId);
    const groupDoc = await groupRef.get();
    const groupName = groupDoc.exists ? groupDoc.data().name : "Group Chat";

    batch.update(groupRef, {
      lastMessage: displayMessage,
      lastMessageAt: createdAt || admin.firestore.FieldValue.serverTimestamp(),
    });

    // 2. Fetch Members & Send Notifications
    const membersSnap = await groupRef.collection("members").get();
    const tokens = [];

    // We process members in parallel to fetch user docs for tokens
    const memberPromises = membersSnap.docs.map(async (doc) => {
      const userId = doc.id;

      if (userId !== senderId) {
        // Update User's Group View (Last message only)
        const userGroupRef = db.doc(`users/${userId}/groups/${groupId}`);
        batch.set(userGroupRef, {
          lastMessage: displayMessage,
          lastMessageAt: createdAt || admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        // Fetch User for Token
        const userDoc = await db.collection("users").doc(userId).get();
        if (userDoc.exists) {
          const userData = userDoc.data();
          if (userData.fcmToken) {
            tokens.push(userData.fcmToken);
          }
        }
      }
    });

    await Promise.all(memberPromises);
    await batch.commit();

    // 3. Send FCM Multicast
    if (tokens.length > 0) {
      const payload = {
        notification: {
          title: groupName,
          body: `${senderName}: ${displayMessage}`,
          sound: "default",
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          type: "chat",
          groupId: groupId,
        },
      };

      try {
        const response = await admin.messaging().sendEachForMulticast({
          tokens: tokens,
          notification: payload.notification,
          data: payload.data
        });
        console.log(`Notifications sent: ${response.successCount} success, ${response.failureCount} failed.`);
      } catch (e) {
        console.error("Error sending notifications:", e);
      }
    }
  });
