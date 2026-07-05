import {onCall, HttpsError} from "firebase-functions/v2/https";
import {initializeApp, getApps} from "firebase-admin/app";
import * as fs from "fs";
import * as path from "path";
import {generateCaseForDate} from "./generateDailyCaseCore";
import {cursorApiKey, seedSecret} from "./config/secrets";
import {DEV_DATABASE_ID, dbForDatabaseId} from "./firestore";
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
  /** Target Firestore database. Only `dev` is allowed besides default prod. */
  databaseId?: string;
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

    if (data.databaseId && data.databaseId !== DEV_DATABASE_ID) {
      throw new HttpsError(
        "invalid-argument",
        `databaseId must be '${DEV_DATABASE_ID}' or omitted`,
      );
    }

    const useDevDatabase = data.databaseId === DEV_DATABASE_ID;
    const db = dbForDatabaseId(data.databaseId);

    if (data.useExample) {
      const payload = loadExampleCase(dateId);
      const status = await writeDetectiveCase(dateId, payload, {
        force: data.force === true,
        db,
      });
      return {
        dateId,
        status,
        source: "example",
        databaseId: useDevDatabase ? DEV_DATABASE_ID : "(default)",
      };
    }

    const result = await generateCaseForDate(dateId, {
      apiKey: cursorApiKey.value(),
      force: data.force === true,
      db,
      notify: !useDevDatabase,
    });

    return {
      dateId: result.dateId,
      status: result.status,
      source: "cursor",
      databaseId: useDevDatabase ? DEV_DATABASE_ID : "(default)",
    };
  },
);
