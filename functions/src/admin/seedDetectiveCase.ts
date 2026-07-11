import * as fs from "fs";
import * as path from "path";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {generateCaseForDate} from "../generateDailyCaseCore";
import {writeDetectiveCase} from "../caseWriter";
import {cursorApiKey} from "../config/secrets";
import {dbForDatabaseId} from "../firestore";
import {listPlannedCaseDateIds, getPlannedCase} from "../localCaseCatalog";
import {DetectiveCasePayload} from "../types/detectiveCase";
import {validateCase} from "../validation/validateCase";
import {isValidDateId, todayUtcDateId} from "../utils/dateId";
import {assertAdmin, parseDatabaseId} from "./assertAdmin";
import {writeAuditLog} from "./auditLog";

interface AdminSeedCaseRequest {
  dateId?: string;
  force?: boolean;
  useExample?: boolean;
  source?: "planned" | "example" | "ai";
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
    throw new HttpsError("failed-precondition", "seed-case.example.json not found");
  }

  const raw = JSON.parse(fs.readFileSync(filePath, "utf8")) as DetectiveCasePayload;
  return validateCase({...raw, id: dateId});
}

export const adminSeedDetectiveCase = onCall(
  {secrets: [cursorApiKey], timeoutSeconds: 540, memory: "512MiB"},
  async (request) => {
    const adminUid = assertAdmin(request);
    const data = (request.data ?? {}) as AdminSeedCaseRequest;
    const databaseId = parseDatabaseId(data.databaseId);
    const dbLabel = databaseId ?? "(default)";
    const useDevDatabase = databaseId === "development";

    const dateId = data.dateId ?? todayUtcDateId();
    if (!isValidDateId(dateId)) {
      throw new HttpsError("invalid-argument", "dateId must be YYYY-MM-DD");
    }

    const db = dbForDatabaseId(databaseId);
    const source = data.source ?? (data.useExample ? "example" : "planned");

    let result: {dateId: string; status: "created" | "skipped"; source: string};

    if (source === "example") {
      const payload = loadExampleCase(dateId);
      const status = await writeDetectiveCase(dateId, payload, {
        force: data.force === true,
        db,
      });
      result = {dateId, status, source: "example"};
    } else if (source === "planned") {
      const planned = getPlannedCase(dateId);
      if (!planned) {
        throw new HttpsError(
          "not-found",
          `No planned case for ${dateId}. Try source=ai or source=example.`,
        );
      }
      const status = await writeDetectiveCase(dateId, planned, {
        force: data.force === true,
        db,
      });
      result = {dateId, status, source: "planned"};
    } else {
      const generated = await generateCaseForDate(dateId, {
        apiKey: cursorApiKey.value(),
        force: data.force === true,
        db,
        notify: !useDevDatabase,
      });
      result = {dateId: generated.dateId, status: generated.status, source: "ai"};
    }

    await writeAuditLog({
      action: "seed_detective_case",
      adminUid,
      databaseId: dbLabel,
      targetId: dateId,
      payload: {source, force: data.force === true, status: result.status},
    }, databaseId);

    return {...result, databaseId: dbLabel};
  },
);

interface BulkSeedRequest {
  startDateId?: string;
  endDateId?: string;
  force?: boolean;
  databaseId?: string;
}

export const adminBulkSeedPlannedCases = onCall(async (request) => {
  const adminUid = assertAdmin(request);
  const data = (request.data ?? {}) as BulkSeedRequest;
  const databaseId = parseDatabaseId(data.databaseId);
  const dbLabel = databaseId ?? "(default)";
  const db = dbForDatabaseId(databaseId);

  const dateIds = listPlannedCaseDateIds().filter((id) => {
    if (data.startDateId && id < data.startDateId) return false;
    if (data.endDateId && id > data.endDateId) return false;
    return true;
  });

  const results: Array<{dateId: string; status: string}> = [];

  for (const dateId of dateIds) {
    const payload = getPlannedCase(dateId);
    if (!payload) continue;
    const status = await writeDetectiveCase(dateId, payload, {
      force: data.force === true,
      db,
    });
    results.push({dateId, status});
  }

  await writeAuditLog({
    action: "bulk_seed_planned_cases",
    adminUid,
    databaseId: dbLabel,
    payload: {count: results.length, force: data.force === true},
  }, databaseId);

  return {results, databaseId: dbLabel};
});

interface GetCasePreviewRequest {
  dateId: string;
  databaseId?: string;
}

export const adminGetCasePreview = onCall(async (request) => {
  assertAdmin(request);
  const data = (request.data ?? {}) as GetCasePreviewRequest;
  const databaseId = parseDatabaseId(data.databaseId);

  if (!data.dateId || !isValidDateId(data.dateId)) {
    throw new HttpsError("invalid-argument", "dateId must be YYYY-MM-DD");
  }

  const doc = await dbForDatabaseId(databaseId)
    .collection("detectiveCases")
    .doc(data.dateId)
    .get();

  const planned = getPlannedCase(data.dateId);

  return {
    dateId: data.dateId,
    exists: doc.exists,
    hasPlannedCatalog: planned != null,
    case: doc.exists ? doc.data() : null,
    plannedTitle: planned?.title ?? null,
  };
});

interface ListCasesRequest {
  startDateId: string;
  endDateId: string;
  databaseId?: string;
}

export const adminListCases = onCall(async (request) => {
  assertAdmin(request);
  const data = (request.data ?? {}) as ListCasesRequest;
  const databaseId = parseDatabaseId(data.databaseId);

  if (!isValidDateId(data.startDateId) || !isValidDateId(data.endDateId)) {
    throw new HttpsError("invalid-argument", "Invalid date range");
  }

  const db = dbForDatabaseId(databaseId);
  const cases: Array<{
    dateId: string;
    exists: boolean;
    title?: string;
    hasPlanned: boolean;
  }> = [];

  const current = new Date(`${data.startDateId}T00:00:00Z`);
  const end = new Date(`${data.endDateId}T00:00:00Z`);

  while (current <= end) {
    const dateId = current.toISOString().slice(0, 10);
    const doc = await db.collection("detectiveCases").doc(dateId).get();
    const planned = getPlannedCase(dateId);
    cases.push({
      dateId,
      exists: doc.exists,
      title: doc.exists ? (doc.data()?.title as string) : undefined,
      hasPlanned: planned != null,
    });
    current.setUTCDate(current.getUTCDate() + 1);
  }

  return {cases};
});
