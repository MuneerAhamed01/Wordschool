import {onSchedule} from "firebase-functions/v2/scheduler";
import {initializeApp, getApps} from "firebase-admin/app";
import {cursorApiKey} from "./config/secrets";
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
    secrets: [cursorApiKey],
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async () => {
    await runScheduledDailyCaseGeneration(cursorApiKey.value());
  },
);
