import {initializeApp, getApps} from "firebase-admin/app";

if (getApps().length === 0) {
  initializeApp();
}

export {generateDailyCase} from "./generateDailyCase";
export {seedDetectiveCase} from "./seedCase";
export {updateDetectiveLeaderboard} from "./updateDetectiveLeaderboard";
export {sendStreakAtRiskReminders} from "./notifications/sendStreakAtRiskReminders";
export {sendStreakMilestoneNotification} from "./notifications/sendStreakMilestoneNotification";
export {sendReengagementNotification} from "./notifications/sendReengagementNotification";
export {notifyNewDetectiveCase} from "./notifications/sendNewDetectiveCaseNotification";
