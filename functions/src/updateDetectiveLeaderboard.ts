import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {getIsoWeekId} from "./utils/isoWeekId";

interface StoryProgressData {
  totalScore?: number;
  completedAt?: FirebaseFirestore.Timestamp | null;
}

interface LeaderboardEntry {
  displayName: string;
  totalPoints: number;
  casesCompleted: number;
  updatedAt: FirebaseFirestore.FieldValue;
}

/**
 * Aggregates detective points into the weekly leaderboard when a case is completed.
 */
export const updateDetectiveLeaderboard = onDocumentUpdated(
  "userStoryProgress/{userId}/cases/{dateId}",
  async (event) => {
    const before = event.data?.before.data() as StoryProgressData | undefined;
    const after = event.data?.after.data() as StoryProgressData | undefined;
    if (!before || !after) {
      return;
    }

    if (before.completedAt != null || after.completedAt == null) {
      return;
    }

    const score = after.totalScore ?? 0;
    if (score < 0) {
      return;
    }

    const userId = event.params.userId;
    const db = getFirestore();
    const weekId = getIsoWeekId(new Date());
    const entryRef = db
      .collection("detectiveLeaderboard")
      .doc(weekId)
      .collection("entries")
      .doc(userId);

    const authUser = await getAuth().getUser(userId).catch(() => null);
    const displayName = authUser?.displayName ?? "Detective";

    await db.runTransaction(async (transaction) => {
      const existing = await transaction.get(entryRef);
      const currentPoints =
        (existing.data()?.totalPoints as number | undefined) ?? 0;
      const currentCases =
        (existing.data()?.casesCompleted as number | undefined) ?? 0;

      const entry: LeaderboardEntry = {
        displayName,
        totalPoints: currentPoints + score,
        casesCompleted: currentCases + 1,
        updatedAt: FieldValue.serverTimestamp(),
      };

      transaction.set(entryRef, entry, {merge: true});
    });
  },
);
