import {IST_OFFSET_MS} from "./dateId";

/** ISO 8601 week id in `yyyy-Www` format (Monday–Sunday, UTC). */
export function getIsoWeekId(date: Date): string {
  const utc = new Date(
    Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()),
  );
  const dayNum = utc.getUTCDay() || 7;
  utc.setUTCDate(utc.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(utc.getUTCFullYear(), 0, 1));
  const weekNo = Math.ceil(
    ((utc.getTime() - yearStart.getTime()) / 86400000 + 1) / 7,
  );
  return `${utc.getUTCFullYear()}-W${String(weekNo).padStart(2, "0")}`;
}

/**
 * ISO week id of the current calendar day in India, so weekly leaderboards
 * roll over at Monday 00:00 IST like the daily keys (DEC-001).
 * @param {Date} now Instant to convert; defaults to the current time.
 * @return {string} Week id such as `2026-W43`.
 */
export function istIsoWeekId(now: Date = new Date()): string {
  return getIsoWeekId(new Date(now.getTime() + IST_OFFSET_MS));
}
