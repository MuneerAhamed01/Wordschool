import {initializeApp, getApps} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {writeDetectiveCase} from "../caseWriter";
import {listPlannedCaseDateIds, getPlannedCase} from "../localCaseCatalog";

function parseArgs(argv: string[]): {force: boolean; dateId?: string} {
  let force = false;
  let dateId: string | undefined;

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === "--force") {
      force = true;
    } else if (arg === "--date" && argv[i + 1]) {
      dateId = argv[i + 1];
      i++;
    }
  }

  return {force, dateId};
}

async function main(): Promise<void> {
  const {force, dateId} = parseArgs(process.argv.slice(2));

  if (getApps().length === 0) {
    initializeApp({
      projectId: process.env.GCLOUD_PROJECT || process.env.GOOGLE_CLOUD_PROJECT || "wordschool-dev",
    });
  }

  if (process.env.FIRESTORE_EMULATOR_HOST) {
    getFirestore().settings({
      host: process.env.FIRESTORE_EMULATOR_HOST,
      ssl: false,
    });
  }

  const dateIds = dateId ? [dateId] : listPlannedCaseDateIds();
  const results: Array<{dateId: string; status: string}> = [];

  for (const id of dateIds) {
    const payload = getPlannedCase(id);
    if (!payload) {
      throw new Error(`No planned case found for ${id}`);
    }

    const status = await writeDetectiveCase(id, payload, {force});
    results.push({dateId: id, status});
    console.log(JSON.stringify({
      event: "seed_planned_case",
      dateId: id,
      status,
      title: payload.title,
    }));
  }

  console.log(JSON.stringify({
    event: "seed_planned_cases_complete",
    count: results.length,
    force,
    results,
  }));
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
