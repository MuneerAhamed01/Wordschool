import {initializeApp, getApps} from "firebase-admin/app";

if (getApps().length === 0) {
  initializeApp();
}

export {generateDailyCase} from "./generateDailyCase";
export {seedDetectiveCase} from "./seedCase";
export {updateDetectiveLeaderboard} from "./updateDetectiveLeaderboard";
