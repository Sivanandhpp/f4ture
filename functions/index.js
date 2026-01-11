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
