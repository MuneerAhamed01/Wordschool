import {initializeApp, getApps} from "firebase-admin/app";
import * as fs from "fs";
import * as path from "path";
import {validateCase} from "../validation/validateCase";
import {writeDetectiveCase} from "../caseWriter";
import {configureEmulatorIfNeeded, dbFromEnv} from "../firestore";
import {DetectiveCasePayload} from "../types/detectiveCase";
import {isValidDateId, todayUtcDateId} from "../utils/dateId";

function parseArgs(argv: string[]): {dateId: string; force: boolean} {
  let dateId = todayUtcDateId();
  let force = false;

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--date" && argv[i + 1]) {
      dateId = argv[i + 1];
      i++;
    } else if (arg === "--force") {
      force = true;
    }
  }

  return {dateId, force};
}

function loadExampleCase(dateId: string): DetectiveCasePayload {
  const candidates = [
    path.resolve(__dirname, "../../../technical_doc/story_mode/seed-case.example.json"),
    path.resolve(__dirname, "../../../../technical_doc/story_mode/seed-case.example.json"),
    path.resolve(process.cwd(), "../technical_doc/story_mode/seed-case.example.json"),
  ];

  const filePath = candidates.find((candidate) => fs.existsSync(candidate));
  if (!filePath) {
    throw new Error("seed-case.example.json not found");
  }

  const raw = JSON.parse(fs.readFileSync(filePath, "utf8")) as DetectiveCasePayload;
  return validateCase({...raw, id: dateId});
}

async function main(): Promise<void> {
  const {dateId, force} = parseArgs(process.argv.slice(2));

  if (!isValidDateId(dateId)) {
    throw new Error(`Invalid dateId: ${dateId}. Expected YYYY-MM-DD.`);
  }

  if (getApps().length === 0) {
    initializeApp({
      projectId: process.env.GCLOUD_PROJECT || process.env.GOOGLE_CLOUD_PROJECT || "wordschool-dev",
    });
  }

  const db = dbFromEnv();
  configureEmulatorIfNeeded(db);

  const payload = loadExampleCase(dateId);
  const status = await writeDetectiveCase(dateId, payload, {force, db});

  console.log(JSON.stringify({
    event: "seed_case_complete",
    dateId,
    status,
    force,
    databaseId: process.env.FIRESTORE_DATABASE_ID ?? "(default)",
  }));
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
