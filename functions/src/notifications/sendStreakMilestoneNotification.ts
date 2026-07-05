import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {crossedMilestone, sendTokenNotification} from "./notificationUtils";

export const sendStreakMilestoneNotification = onDocumentUpdated(
  "userGameStates/{userId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;

    const notifications = after.notifications as Record<string, unknown> | undefined;
    if (notifications?.enabled === false) return;

    const tokens = (after.fcmTokens as string[] | undefined) ?? [];
    if (tokens.length === 0) return;

    const dailyMilestone = crossedMilestone(
      before.streak as number | undefined,
      after.streak as number | undefined,
    );
    const storyMilestone = crossedMilestone(
      before.storyModeStreak as number | undefined,
      after.storyModeStreak as number | undefined,
    );

    const milestone = dailyMilestone ?? storyMilestone;
    if (milestone == null) return;

    await sendTokenNotification(
      tokens,
      `${milestone} days strong!`,
      "You're officially a WordSchool regular. Keep the streak alive.",
      {
        type: "milestone",
        route: "/home",
        streak: String(milestone),
      },
    );
  },
);
