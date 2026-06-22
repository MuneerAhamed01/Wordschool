import {caseExists, writeDetectiveCase} from "./caseWriter";
import {generateCaseWithCursor} from "./cursor/client";
import {todayUtcDateId} from "./utils/dateId";

export interface GenerateCaseForDateOptions {
  apiKey?: string;
  force?: boolean;
}

export interface GenerateCaseForDateResult {
  dateId: string;
  status: "created" | "skipped";
}

export async function generateCaseForDate(
  dateId: string,
  options: GenerateCaseForDateOptions = {},
): Promise<GenerateCaseForDateResult> {
  if (!options.force && await caseExists(dateId)) {
    console.log(JSON.stringify({
      event: "generate_case_skipped",
      dateId,
      reason: "already_exists",
    }));
    return {dateId, status: "skipped"};
  }

  const apiKey = options.apiKey;
  if (!apiKey) {
    throw new Error("CURSOR_API_KEY is not configured");
  }

  const payload = await generateCaseWithCursor({apiKey, dateId});
  const status = await writeDetectiveCase(dateId, payload, {
    force: options.force,
  });

  console.log(JSON.stringify({
    event: "generate_case_complete",
    dateId,
    status,
  }));

  return {dateId, status};
}

export async function runScheduledDailyCaseGeneration(
  apiKey: string,
): Promise<void> {
  const dateId = todayUtcDateId();
  await generateCaseForDate(dateId, {apiKey});
}
