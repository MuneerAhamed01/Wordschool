import {onSchedule} from "firebase-functions/v2/scheduler";
import {getFirestore} from "firebase-admin/firestore";
import {
  localDateIdForTimezone,
  localHourForTimezone,
  sendTokenNotification,
  utcDateId,
} from "./notificationUtils";

export const sendStreakAtRiskReminders = onSchedule(
  {
    schedule: "0 * * * *",
    timeZone: "UTC",
  },
  async () => {
    const db = getFirestore();
    const snapshot = await db.collection("userGameStates").get();
    const utcToday = utcDateId();

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const notifications = data.notifications as Record<string, unknown> | undefined;
      if (!notifications || notifications.streakReminderEnabled !== true) {
        continue;
      }

      const timezone = (data.timezone as string | undefined) ?? "UTC";
      const reminderHour = Number(notifications.streakReminderHour ?? 20);
      const currentHour = localHourForTimezone(timezone);
      if (currentHour !== reminderHour) {
        continue;
      }

      const tokens = (data.fcmTokens as string[] | undefined) ?? [];
      if (tokens.length === 0) continue;

      const localToday = localDateIdForTimezone(timezone);
      const dailyStreak = Number(data.streak ?? 0);
      const storyStreak = Number(data.storyModeStreak ?? 0);
      const lastDaily = data.lastStreakDate as string | undefined;
      const lastStory = data.lastStoryModeStreakDate as string | undefined;

      if (dailyStreak > 0 && lastDaily !== localToday) {
        await sendTokenNotification(
          tokens,
          "Streak at risk",
          `Don't lose your ${dailyStreak}-day streak — 10 minutes is all it takes.`,
          {
            type: "streak_reminder",
            feature: "daily",
            route: "/game",
            streak: String(dailyStreak),
          },
        );
        continue;
      }

      if (storyStreak > 0 && lastStory !== utcToday) {
        await sendTokenNotification(
          tokens,
          "Detective streak at risk",
          `Your ${storyStreak}-day detective streak ends tonight. Open today's case.`,
          {
            type: "streak_reminder",
            feature: "detective",
            route: "/story",
            streak: String(storyStreak),
          },
        );
      }
    }
  },
);
