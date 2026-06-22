export function todayUtcDateId(): string {
  const now = new Date();
  const year = now.getUTCFullYear().toString().padStart(4, "0");
  const month = (now.getUTCMonth() + 1).toString().padStart(2, "0");
  const day = now.getUTCDate().toString().padStart(2, "0");
  return `${year}-${month}-${day}`;
}

export function isValidDateId(value: string): boolean {
  return /^\d{4}-\d{2}-\d{2}$/.test(value);
}
