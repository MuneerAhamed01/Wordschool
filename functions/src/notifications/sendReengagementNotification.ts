import {onSchedule} from "firebase-functions/v2/scheduler";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import {sendTokenNotification} from "./notificationUtils";

const REENGAGEMENT_MESSAGES = [
  {
    title: "We saved today's case for you",
    body: "Ready to investigate? Your detective skills are needed.",
  },
  {
    title: "A mystery awaits your return",
    body: "Today's puzzle and case file are still open.",
  },
  {
    title: "The Bureau misses you",
    body: "Pick up where you left off — it only takes a few minutes.",
  },
];

export const sendReengagementNotification = onSchedule(
  {
    schedule: "0 14 * * *",
    timeZone: "UTC",
  },
  async () => {
    const db = getFirestore();
    const cutoff = Timestamp.fromDate(
      new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
    );
    const snapshot = await db.collection("userGameStates").get();
    const message =
      REENGAGEMENT_MESSAGES[
        Math.floor(Math.random() * REENGAGEMENT_MESSAGES.length)
      ];

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const notifications = data.notifications as Record<string, unknown> | undefined;
      if (!notifications || notifications.enabled === false) continue;

      const updatedDate = data.updatedDate;
      if (!(updatedDate instanceof Timestamp) || updatedDate.toMillis() > cutoff.toMillis()) {
        continue;
      }

      const lastSent = data.lastReengagementSentAt;
      if (lastSent instanceof Timestamp) {
        const threeDaysAgo = Date.now() - 3 * 24 * 60 * 60 * 1000;
        if (lastSent.toMillis() > threeDaysAgo) continue;
      }

      const tokens = (data.fcmTokens as string[] | undefined) ?? [];
      if (tokens.length === 0) continue;

      await sendTokenNotification(
        tokens,
        message.title,
        message.body,
        {
          type: "reengagement",
          route: "/home",
        },
      );

      await doc.ref.set(
        {lastReengagementSentAt: Timestamp.now()},
        {merge: true},
      );
    }
  },
);
