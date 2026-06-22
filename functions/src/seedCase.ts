import {onCall, HttpsError} from "firebase-functions/v2/https";
import {initializeApp, getApps} from "firebase-admin/app";
import * as fs from "fs";
import * as path from "path";
import {generateCaseForDate} from "./generateDailyCaseCore";
import {cursorApiKey, seedSecret} from "./config/secrets";
import {validateCase} from "./validation/validateCase";
import {writeDetectiveCase} from "./caseWriter";
import {DetectiveCasePayload} from "./types/detectiveCase";
import {isValidDateId, todayUtcDateId} from "./utils/dateId";

if (getApps().length === 0) {
  initializeApp();
}

interface SeedDetectiveCaseRequest {
  dateId?: string;
  force?: boolean;
  useExample?: boolean;
  secret?: string;
}

function loadExampleCase(dateId: string): DetectiveCasePayload {
  const candidates = [
    path.resolve(__dirname, "../../../technical_doc/story_mode/seed-case.example.json"),
    path.resolve(__dirname, "../../../../technical_doc/story_mode/seed-case.example.json"),
    path.resolve(process.cwd(), "../technical_doc/story_mode/seed-case.example.json"),
  ];

  const filePath = candidates.find((candidate) => fs.existsSync(candidate));
  if (!filePath) {
    throw new HttpsError(
      "failed-precondition",
      "seed-case.example.json not found",
    );
  }

  const raw = JSON.parse(fs.readFileSync(filePath, "utf8")) as DetectiveCasePayload;
  return validateCase({...raw, id: dateId});
}

export const seedDetectiveCase = onCall(
  {
    secrets: [cursorApiKey, seedSecret],
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async (request) => {
    const data = (request.data ?? {}) as SeedDetectiveCaseRequest;
    const providedSecret = data.secret ?? request.rawRequest?.get?.("x-seed-secret");

    if (!providedSecret || providedSecret !== seedSecret.value()) {
      throw new HttpsError("permission-denied", "Invalid seed secret");
    }

    const dateId = data.dateId ?? todayUtcDateId();
    if (!isValidDateId(dateId)) {
      throw new HttpsError("invalid-argument", "dateId must be YYYY-MM-DD");
    }

    if (data.useExample) {
      const payload = loadExampleCase(dateId);
      const status = await writeDetectiveCase(dateId, payload, {
        force: data.force === true,
      });
      return {dateId, status, source: "example"};
    }

    const result = await generateCaseForDate(dateId, {
      apiKey: cursorApiKey.value(),
      force: data.force === true,
    });

    return {dateId: result.dateId, status: result.status, source: "cursor"};
  },
);
