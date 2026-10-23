/** Asia/Kolkata is UTC+05:30 all year (no daylight saving). */
export const IST_OFFSET_MS = (5 * 60 + 30) * 60 * 1000;

/**
 * Daily key `YYYY-MM-DD` for the calendar day in India (DEC-001).
 * @param {Date} now Instant to convert; defaults to the current time.
 * @return {string} The IST date id.
 */
export function todayIstDateId(now: Date = new Date()): string {
  const ist = new Date(now.getTime() + IST_OFFSET_MS);
  const year = ist.getUTCFullYear().toString().padStart(4, "0");
  const month = (ist.getUTCMonth() + 1).toString().padStart(2, "0");
  const day = ist.getUTCDate().toString().padStart(2, "0");
  return `${year}-${month}-${day}`;
}

/**
 * True when `value` is `YYYY-MM-DD` and a real calendar date.
 * @param {string} value Candidate date id.
 * @return {boolean} Whether it is valid.
 */
export function isValidDateId(value: string): boolean {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value);
  if (!match) {
    return false;
  }
  const [year, month, day] = match.slice(1).map(Number);
  const date = new Date(Date.UTC(year, month - 1, day));
  return date.getUTCFullYear() === year &&
    date.getUTCMonth() === month - 1 &&
    date.getUTCDate() === day;
}
