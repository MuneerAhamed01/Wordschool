import {getAuth} from "firebase-admin/auth";
import {FieldValue, Firestore} from "firebase-admin/firestore";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {dbForDatabaseId} from "./firestore";
import {getIsoWeekId} from "./utils/isoWeekId";

const BATCH_SIZE = 500;

async function deleteQueryBatch(
  db: Firestore,
  query: FirebaseFirestore.Query,
  resolve: () => void,
): Promise<void> {
  const snapshot = await query.get();
  if (snapshot.empty) {
    resolve();
    return;
  }

  const batch = db.batch();
  snapshot.docs.forEach((doc) => batch.delete(doc.ref));
  await batch.commit();

  process.nextTick(() => {
    deleteQueryBatch(db, query, resolve).catch(() => resolve());
  });
}

async function deleteCollection(
  db: Firestore,
  collectionRef: FirebaseFirestore.CollectionReference,
): Promise<void> {
  const query = collectionRef.limit(BATCH_SIZE);
  await new Promise<void>((resolve, reject) => {
    deleteQueryBatch(db, query, resolve).catch(reject);
  });
}

function resolveDatabaseId(raw: unknown): string | undefined {
  if (typeof raw !== "string" || raw.length === 0) {
    return undefined;
  }
  if (raw === "(default)") {
    return undefined;
  }
  return raw;
}

/**
 * Soft-deletes the authenticated user's account: clears all game progress,
 * marks the profile as deleted, removes leaderboard entries, and deletes
 * the Firebase Auth user so they can sign in fresh later.
 */
export const softDeleteUserAccount = onCall(async (request) => {
  if (!request.auth?.uid) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const userId = request.auth.uid;
  const db = dbForDatabaseId(resolveDatabaseId(request.data?.firestoreDatabaseId));
  const userStateRef = db.collection("userGameStates").doc(userId);

  const userStateSnap = await userStateRef.get();
  if (!userStateSnap.exists) {
    throw new HttpsError("not-found", "User profile not found.");
  }

  await deleteCollection(
    db,
    userStateRef.collection("userGameData"),
  );

  await deleteCollection(
    db,
    db.collection("userStoryProgress").doc(userId).collection("cases"),
  );

  const weekId = getIsoWeekId(new Date());
  const leaderboardEntryRef = db
    .collection("detectiveLeaderboard")
    .doc(weekId)
    .collection("entries")
    .doc(userId);
  await leaderboardEntryRef.delete().catch(() => undefined);

  await userStateRef.update({
    deletedAt: FieldValue.serverTimestamp(),
    streak: 0,
    longestStreak: 0,
    completedGames: 0,
    totalGames: 0,
    detectivePoints: 0,
    storyModeStreak: 0,
    storyModeLongestStreak: 0,
    hintPackBalance: 0,
    hasRemoveAds: false,
    isDetectivePro: false,
    lastStreakDate: FieldValue.delete(),
    lastStoryModeStreakDate: FieldValue.delete(),
    fcmTokens: [],
    updatedDate: FieldValue.serverTimestamp(),
  });

  await getAuth().deleteUser(userId).catch((error: unknown) => {
    const code = (error as {code?: string}).code;
    if (code === "auth/user-not-found") {
      return;
    }
    throw new HttpsError("internal", "Failed to delete authentication account.");
  });

  return {success: true};
});
