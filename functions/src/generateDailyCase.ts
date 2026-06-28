import {onSchedule} from "firebase-functions/v2/scheduler";
import {initializeApp, getApps} from "firebase-admin/app";
import {runScheduledDailyCaseGeneration} from "./generateDailyCaseCore";

if (getApps().length === 0) {
  initializeApp();
}

export {generateCaseForDate, runScheduledDailyCaseGeneration} from "./generateDailyCaseCore";
export type {GenerateCaseForDateOptions, GenerateCaseForDateResult} from "./generateDailyCaseCore";

export const generateDailyCase = onSchedule(
  {
    schedule: "0 0 * * *",
    timeZone: "UTC",
    timeoutSeconds: 120,
    memory: "256MiB",
  },
  async () => {
    await runScheduledDailyCaseGeneration();
  },
);
