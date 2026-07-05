import {getFirestore} from "firebase-admin/firestore";
import {
  DETECTIVE_CASE_TOPIC,
  sendTopicNotification,
} from "./notificationUtils";

export async function notifyNewDetectiveCase(
  dateId: string,
  caseTitle?: string,
): Promise<void> {
  const title = "New case file dropped";
  const body = caseTitle ?
    `Case ${dateId}: ${caseTitle} — the Bureau needs you.` :
    "A new detective case is waiting at the Bureau.";

  await sendTopicNotification(
    DETECTIVE_CASE_TOPIC,
    title,
    body,
    {
      type: "detective_case",
      route: "/story",
    },
  );

  console.log(JSON.stringify({
    event: "detective_case_notification_sent",
    dateId,
  }));
}

export async function markCaseNotificationSent(dateId: string): Promise<void> {
  await getFirestore()
    .collection("detectiveCases")
    .doc(dateId)
    .set({notificationSentAt: new Date().toISOString()}, {merge: true});
}
