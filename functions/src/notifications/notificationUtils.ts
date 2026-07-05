import {getMessaging} from "firebase-admin/messaging";

export const DETECTIVE_CASE_TOPIC = "detective_case_daily";
const STREAK_MILESTONES = [7, 14, 30, 100];

export interface NotificationPayload {
  type: string;
  route?: string;
  feature?: string;
  streak?: string;
}

export async function sendTopicNotification(
  topic: string,
  title: string,
  body: string,
  data: NotificationPayload,
): Promise<void> {
  await getMessaging().send({
    topic,
    notification: {title, body},
    data: {
      type: data.type,
      route: data.route ?? "",
      feature: data.feature ?? "",
      streak: data.streak ?? "",
    },
  });
}

export async function sendTokenNotification(
  tokens: string[],
  title: string,
  body: string,
  data: NotificationPayload,
): Promise<void> {
  if (tokens.length === 0) return;

  await getMessaging().sendEachForMulticast({
    tokens,
    notification: {title, body},
    data: {
      type: data.type,
      route: data.route ?? "",
      feature: data.feature ?? "",
      streak: data.streak ?? "",
    },
  });
}

export function crossedMilestone(
  previous: number | undefined,
  current: number | undefined,
): number | null {
  const prev = previous ?? 0;
  const next = current ?? 0;
  if (next <= prev) return null;

  for (const milestone of STREAK_MILESTONES) {
    if (prev < milestone && next >= milestone) {
      return milestone;
    }
  }

  return null;
}

export function localDateIdForTimezone(timezone: string, date = new Date()): string {
  try {
    const parts = new Intl.DateTimeFormat("en-CA", {
      timeZone: timezone,
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    }).formatToParts(date);

    const year = parts.find((part) => part.type === "year")?.value ?? "1970";
    const month = parts.find((part) => part.type === "month")?.value ?? "01";
    const day = parts.find((part) => part.type === "day")?.value ?? "01";
    return `${year}-${month}-${day}`;
  } catch {
    return date.toISOString().slice(0, 10);
  }
}

export function utcDateId(date = new Date()): string {
  return date.toISOString().slice(0, 10);
}

export function localHourForTimezone(timezone: string, date = new Date()): number {
  try {
    const hour = new Intl.DateTimeFormat("en-US", {
      timeZone: timezone,
      hour: "numeric",
      hour12: false,
    }).format(date);
    return Number.parseInt(hour, 10);
  } catch {
    return date.getUTCHours();
  }
}
