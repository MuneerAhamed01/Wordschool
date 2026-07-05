import {Firestore} from "firebase-admin/firestore";
import {caseExists, writeDetectiveCase} from "./caseWriter";
import {generateCaseWithCursor} from "./cursor/client";
import {prodDb} from "./firestore";
import {getPlannedCase} from "./localCaseCatalog";
import {notifyNewDetectiveCase} from "./notifications/sendNewDetectiveCaseNotification";
import {todayUtcDateId} from "./utils/dateId";

export interface GenerateCaseForDateOptions {
  apiKey?: string;
  force?: boolean;
  /** Target database; defaults to production `(default)`. */
  db?: Firestore;
  /** Send FCM topic notification when a case is created. Default true. */
  notify?: boolean;
}

export interface GenerateCaseForDateResult {
  dateId: string;
  status: "created" | "skipped";
}

export async function generateCaseForDate(
  dateId: string,
  options: GenerateCaseForDateOptions = {},
): Promise<GenerateCaseForDateResult> {
  const db = options.db ?? prodDb();
  const shouldNotify = options.notify !== false;

  if (!options.force && await caseExists(dateId, db)) {
    console.log(JSON.stringify({
      event: "generate_case_skipped",
      dateId,
      reason: "already_exists",
    }));
    return {dateId, status: "skipped"};
  }

  const plannedCase = getPlannedCase(dateId);
  if (plannedCase) {
    const status = await writeDetectiveCase(dateId, plannedCase, {
      force: options.force,
      db,
    });

    console.log(JSON.stringify({
      event: "generate_case_complete",
      dateId,
      status,
      source: "planned",
    }));

    if (status === "created" && shouldNotify) {
      await notifyNewDetectiveCase(dateId, plannedCase.title);
    }

    return {dateId, status};
  }

  const apiKey = options.apiKey;
  if (!apiKey) {
    throw new Error(
      `No planned case for ${dateId} and CURSOR_API_KEY is not configured`,
    );
  }

  const payload = await generateCaseWithCursor({apiKey, dateId});
  const status = await writeDetectiveCase(dateId, payload, {
    force: options.force,
    db,
  });

  console.log(JSON.stringify({
    event: "generate_case_complete",
    dateId,
    status,
    source: "cursor",
  }));

  if (status === "created" && shouldNotify) {
    await notifyNewDetectiveCase(dateId, payload.title);
  }

  return {dateId, status};
}

export async function runScheduledDailyCaseGeneration(
  apiKey?: string,
): Promise<void> {
  const dateId = todayUtcDateId();
  await generateCaseForDate(dateId, {apiKey});
}
