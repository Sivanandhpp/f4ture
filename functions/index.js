/**
 * ============================================================================
 * F4ture Backend - Firebase Cloud Functions
 * ============================================================================
 *
 * This file contains the server-side logic for the F4ture application.
 * It handles data consistency, denormalization, notifications,
 * and security checks.
 *
 * CORE RESPONSIBILITIES:
 * 1. Data Consistency: Syncing group membership to user profiles.
 * 2. Role Management: Automatically calculating user roles
 *    based on group affiliations.
 * 3. Feature Synchronization: Propagating Task and Issue updates.
 * 4. Notifications: Sending Push Notifications (FCM) for chat messages.
 * 5. Security: Verifying email existence securely.
 *
 * @module functions/index
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK to interact with Firestore and Auth
admin.initializeApp();
const db = admin.firestore();

/**
 * ============================================================================
 * 1. Group Membership & Synchronization
 * ============================================================================
 */

/**
 * Trigger: Firestore Write (Create/Update/Delete)
 * Path: groups/{groupId}/members/{userId}
 *
 * Purpose:
 * Maintains consistency between a central 'Group' and individual 'Users'.
 * unique source of truth for membership is the `groups/{id}/members` collection.
 *
 * Actions:
 * 1. Updates `membersCount` on the parent Group document.
 * 2. Syncs membership details (Role, Join Date, Type) to User's private `groups`.
 * 3. Triggers Role Recalculation for the user.
 */
exports.syncGroupToUser = functions.firestore
    .document("groups/{groupId}/members/{userId}")
    .onWrite(async (change, context) => {
        const { groupId, userId } = context.params;
        const groupRef = db.collection("groups").doc(groupId);
        const batch = db.batch(); // Use batch for atomic updates

        // ----------------------------------------------------------------------
        // Step 1: Maintain 'membersCount' on the Group Document
        // ----------------------------------------------------------------------
        if (!change.before.exists && change.after.exists) {
            // CASE: New Member Added
            // Increment the count atomically to prevent race conditions
            batch.update(groupRef, {
                membersCount: admin.firestore.FieldValue.increment(1),
            });
        } else if (change.before.exists && !change.after.exists) {
            // CASE: Member Removed
            // Decrement the count
            batch.update(groupRef, {
                membersCount: admin.firestore.FieldValue.increment(-1),
            });
        }

        // ----------------------------------------------------------------------
        // Step 2: Denormalize Data to User Profile (users/{userId}/groups/{id})
        // ----------------------------------------------------------------------
        if (!change.after.exists) {
            // CASE: Member Removed -> Remove record from User's profile
            console.log(`Removing group ${groupId} from user ${userId}`);
            batch.delete(db.doc(`users/${userId}/groups/${groupId}`));
        } else {
            // CASE: Member Added/Updated -> Sync details to User's profile
            const memberData = change.after.data();

            // Fetch fresh group data to get current 'type' (e.g. committee vs public)
            const groupDoc = await groupRef.get();

            // Safety check: Ensure group still exists before syncing
            if (groupDoc.exists) {
                const groupType = groupDoc.data().type || "public";

                const userGroupData = {
                    joinedAt: memberData.joinedAt,
                    role: memberData.role, // e.g., 'admin', 'attendee'
                    type: groupType, // Important for Role Calculation
                };

                // Merge prevents overwriting other user-specific fields
                batch.set(
                    db.doc(`users/${userId}/groups/${groupId}`),
                    userGroupData,
                    { merge: true },
                );
            }
        }

        // Commit all Firestore changes atomically
        await batch.commit();

        // ----------------------------------------------------------------------
        // Step 3: Recalculate User's Global Role
        // ----------------------------------------------------------------------
        return recalculateUserRole(userId);
    });

/**
 * Helper Function: Recalculate User Role
 *
 * Logic:
 * - Scans all groups a user is part of.
 * - Determines the highest privilege level based on group type and internal role.
 * - Updates the user's global `role` field.
 *
 * Hierarchy:
 * - Level 2 (LEAD): Admin of a 'committee' group.
 * - Level 1 (ORGANISER): Member of a 'committee' group.
 * - Level 0 (ATTENDEE): Default.
 *
 * Note: 'core' and 'admin' (global admins) roles are protected.
 *
 * @param {string} userId - The ID of the user to update.
 */
async function recalculateUserRole(userId) {
    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) return;

    const userData = userDoc.data();
    const currentRole = userData.role;

    // PROTECTION: Do not demote Global Admins or Core members automatically
    if (currentRole === "core" || currentRole === "admin") return;

    // Fetch all groups the user belongs to
    const userGroupsSnapshot = await db.collection(`users/${userId}/groups`).get();

    let highestRoleLevel = 0; // Default to Attendee

    userGroupsSnapshot.forEach((doc) => {
        const data = doc.data();
        const groupType = data.type;
        const memberRole = data.role;

        // Logic: Committee membership grants higher privileges
        if (groupType === "committee") {
            if (highestRoleLevel < 1) highestRoleLevel = 1; // At least Organiser
            if (memberRole === "admin") highestRoleLevel = 2; // Admin is Lead
        }
    });

    const roleMap = { 0: "attendee", 1: "organiser", 2: "lead" };
    const newRole = roleMap[highestRoleLevel];

    // Update the user document
    await db.collection("users").doc(userId).update({ role: newRole });
}

/**
 * ============================================================================
 * 2. Task Management System
 * ============================================================================
 */

/**
 * Trigger: Firestore Write (Create/Update/Delete)
 * Path: tasks/{taskId}
 *
 * Purpose:
 * Synchronizes Task data to relevant contexts and generates system messages.
 * The `tasks` root collection is the source of truth.
 *
 * Actions:
 * 1. Syncs task summary to `groups/{groupId}/tasks/{taskId}`.
 * 2. Syncs task summary to `users/{userId}/tasks/{taskId}` for assignees.
 * 3. Cleans up references when a task is deleted or a user is unassigned.
 * 4. Generates a 'System Message' in the group chat.
 */
exports.onTaskWrite = functions.firestore
    .document("tasks/{taskId}")
    .onWrite(async (change, context) => {
        const taskId = context.params.taskId;
        const taskData = change.after.exists ? change.after.data() : null;
        const previousData = change.before.exists ? change.before.data() : null;

        const batch = db.batch();

        // ----------------------------------------------------------------------
        // CASE: Task Deleted
        // ----------------------------------------------------------------------
        if (!taskData) {
            if (previousData) {
                // 1. Remove from Group Context
                const groupRef = db.doc(
                    `groups/${previousData.groupId}/tasks/${taskId}`,
                );
                batch.delete(groupRef);

                // 2. Remove from User Contexts (Assignees)
                if (previousData.assignedTo) {
                    previousData.assignedTo.forEach((uid) => {
                        batch.delete(db.doc(`users/${uid}/tasks/${taskId}`));
                    });
                }
            }
            return batch.commit();
        }

        // ----------------------------------------------------------------------
        // CASE: Task Created or Updated
        // ----------------------------------------------------------------------
        const { groupId, title, status, assignedTo, priority } = taskData;

        // Create a lightweight summary object for denormalization
        const summary = {
            id: taskId,
            title,
            status,
            priority: priority || "medium",
            dueAt: taskData.dueAt,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            groupId,
        };

        // 1. Sync Summary to Group
        batch.set(
            db.doc(`groups/${groupId}/tasks/${taskId}`),
            summary,
            { merge: true },
        );

        // 2. Sync Summary to Assignees (Handle Change in Assignees)
        const oldAssignees = previousData ? (previousData.assignedTo || []) : [];
        const newAssignees = assignedTo || [];

        // Sub-step: Remove task from users who were unassigned
        oldAssignees
            .filter((uid) => !newAssignees.includes(uid))
            .forEach((uid) => {
                batch.delete(db.doc(`users/${uid}/tasks/${taskId}`));
            });

        // Sub-step: Add/Update task for current assignees
        newAssignees.forEach((uid) => {
            batch.set(
                db.doc(`users/${uid}/tasks/${taskId}`),
                summary,
                { merge: true },
            );
        });

        // 3. Generate System Message for Chat
        let systemMessage = "";
        if (!previousData) {
            // New Task Created
            systemMessage = `📝 New Task: "${title}"`;
        } else if (previousData.status !== status) {
            // Status Changed
            const readableStatus = status.replace(/_/g, " ").toUpperCase();
            systemMessage = `🔄 Task "${title}" is now ${readableStatus}`;
        }

        if (systemMessage) {
            const msgRef = db
                .collection("groups")
                .doc(groupId)
                .collection("messages")
                .doc();
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
 * ============================================================================
 * 3. Issue Tracking System
 * ============================================================================
 */

/**
 * Trigger: Firestore Write (Create/Update/Delete)
 * Path: issues/{issueId}
 *
 * Purpose:
 * Similar to Tasks, synchronizes Issue data and logs key events to the chat.
 */
exports.onIssueWrite = functions.firestore
    .document("issues/{issueId}")
    .onWrite(async (change, context) => {
        const issueId = context.params.issueId;
        const issueData = change.after.exists ? change.after.data() : null;
        const previousData = change.before.exists ? change.before.data() : null;

        const batch = db.batch();

        // ----------------------------------------------------------------------
        // CASE: Issue Deleted
        // ----------------------------------------------------------------------
        if (!issueData) {
            if (previousData) {
                // Cleanup Group reference
                const groupRef = db.doc(
                    `groups/${previousData.groupId}/issues/${issueId}`,
                );
                batch.delete(groupRef);

                // Cleanup User references
                if (previousData.assignedTo) {
                    previousData.assignedTo.forEach((uid) => {
                        batch.delete(db.doc(`users/${uid}/issues/${issueId}`));
                    });
                }
            }
            return batch.commit();
        }

        // ----------------------------------------------------------------------
        // CASE: Issue Created/Updated
        // ----------------------------------------------------------------------
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
        batch.set(
            db.doc(`groups/${groupId}/issues/${issueId}`),
            summary,
            { merge: true },
        );

        // 2. Sync to Assignees (Diffing Logic)
        const oldAssignees = previousData ? (previousData.assignedTo || []) : [];
        const newAssignees = assignedTo || [];

        // Remove from unassigned users
        oldAssignees
            .filter((uid) => !newAssignees.includes(uid))
            .forEach((uid) => {
                batch.delete(db.doc(`users/${uid}/issues/${issueId}`));
            });

        // Update current assignees
        newAssignees.forEach((uid) => {
            batch.set(
                db.doc(`users/${uid}/issues/${issueId}`),
                summary,
                { merge: true },
            );
        });

        // 3. System Message Generation
        let systemMessage = "";
        if (!previousData) {
            // New Issue with Severity
            systemMessage = `🚨 New Issue: "${title}" (${severity})`;
        } else if (previousData.status !== status) {
            // Status Change
            const readableStatus = status.replace(/_/g, " ").toUpperCase();
            systemMessage = `🔄 Issue "${title}" is now ${readableStatus}`;
        }

        if (systemMessage) {
            const msgRef = db
                .collection("groups")
                .doc(groupId)
                .collection("messages")
                .doc();
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
 * ============================================================================
 * 4. Chat & Notifications
 * ============================================================================
 */

/**
 * Trigger: Firestore Create
 * Path: groups/{groupId}/messages/{messageId}
 *
 * Purpose:
 * Digested logic that runs whenever a new message is sent.
 *
 * Actions:
 * 1. Updates `lastMessage` metadata on the Group.
 * 2. Updates `lastMessage` for every member's user profile (inbox view).
 * 3. Sends FCM Push Notifications to all members (excluding sender).
 */
exports.onMessageCreate = functions.firestore
    .document("groups/{groupId}/messages/{messageId}")
    .onCreate(async (snap, context) => {
        const { groupId } = context.params;
        const messageData = snap.data();
        const { text, type, senderId, senderName, createdAt } = messageData;

        // Determine the string to display in previews/notifications
        let displayMessage = text;
        if (type === "image") displayMessage = "📷 Image";
        if (type === "file") displayMessage = "📁 File";
        if (type === "system") return null; // Do not notify for system messages

        const batch = db.batch();

        // ----------------------------------------------------------------------
        // Step 1: Update Group Metadata (Last Message)
        // ----------------------------------------------------------------------
        const groupRef = db.collection("groups").doc(groupId);
        const groupDoc = await groupRef.get();
        const groupName = groupDoc.exists ? groupDoc.data().name : "Group Chat";

        batch.update(groupRef, {
            lastMessage: displayMessage,
            lastMessageAt:
                createdAt || admin.firestore.FieldValue.serverTimestamp(),
        });

        // ----------------------------------------------------------------------
        // Step 2: Fan-out Updates to Members & Collect Tokens
        // ----------------------------------------------------------------------
        const membersSnap = await groupRef.collection("members").get();
        const tokens = [];

        // Process each member in parallel for performance
        const memberPromises = membersSnap.docs.map(async (doc) => {
            const userId = doc.id;

            // Skip the sender (they don't need a notification)
            if (userId !== senderId) {
                // A. Update User's personal Group View (Inbox Sort/Preview)
                const userGroupRef = db.doc(`users/${userId}/groups/${groupId}`);
                batch.set(
                    userGroupRef,
                    {
                        lastMessage: displayMessage,
                        lastMessageAt:
                            createdAt || admin.firestore.FieldValue.serverTimestamp(),
                    },
                    { merge: true },
                );

                // B. Fetch FCM Token for Push Notification
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

        // ----------------------------------------------------------------------
        // Step 3: Send FCM Push Notifications (Multicast)
        // ----------------------------------------------------------------------
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
                    data: payload.data,
                });
                console.log(
                    `Notifications sent: ${response.successCount} success, ` +
                    `${response.failureCount} failed.`,
                );
            } catch (e) {
                console.error("Error sending notifications:", e);
            }
        }
    });

/**
 * ============================================================================
 * 5. Security - Auth Helper
 * ============================================================================
 */

/**
 * Callable Function: Check if Email Exists
 *
 * Purpose:
 * Allows the client to check if an email is already registered.
 *
 * Security Note:
 * Controlled exposure to avoid public auth enumeration errors.
 *
 * @param {object} data - { email: string }
 * @returns {object} - { exists: boolean }
 */
exports.checkEmailExists = functions.https.onCall(async (data, context) => {
    const email = data.email;

    // Validation
    if (!email || typeof email !== "string") {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "The function must be called with a valid email string.",
        );
    }

    try {
        // Attempt to fetch user by email
        await admin.auth().getUserByEmail(email);
        return { exists: true };
    } catch (error) {
        if (error.code === "auth/user-not-found") {
            return { exists: false };
        }
        // Handle unexpected errors (e.g., API downtime)
        console.error("Error in checkEmailExists:", error);
        throw new functions.https.HttpsError(
            "unknown",
            "Error checking email existence",
            error.message,
        );
    }
});
