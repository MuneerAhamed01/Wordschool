import {DetectiveCasePayload} from "../types/detectiveCase";
import {CaseValidationError} from "../validation/validateCase";
import {getCursorModel, MAX_GENERATION_ATTEMPTS} from "../config/secrets";
import {parseCaseResponse} from "./parseCase";
import {
  buildAgentPrompt,
  buildRetryPrompt,
  buildUserPrompt,
} from "./prompt";

const CURSOR_API_BASE = "https://api.cursor.com/v1";
const TERMINAL_RUN_STATUSES = new Set([
  "FINISHED",
  "ERROR",
  "CANCELLED",
  "EXPIRED",
]);
const POLL_INTERVAL_MS = 3000;
const MAX_POLL_MS = 240000;

export interface GenerateCaseOptions {
  apiKey: string;
  dateId: string;
}

interface CreateAgentResponse {
  agent: {id: string};
  run: {id: string};
}

interface GetRunResponse {
  status: string;
  result?: string;
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function cursorRequest<T>(
  apiKey: string,
  path: string,
  init?: RequestInit,
): Promise<T> {
  const response = await fetch(`${CURSOR_API_BASE}${path}`, {
    ...init,
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
      ...(init?.headers ?? {}),
    },
  });

  if (!response.ok) {
    const body = await response.text();
    throw new Error(
      `Cursor API ${init?.method ?? "GET"} ${path} failed (${response.status}): ${body}`,
    );
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return response.json() as Promise<T>;
}

async function createNoRepoAgent(
  apiKey: string,
  dateId: string,
  promptText: string,
): Promise<{agentId: string; runId: string}> {
  const response = await cursorRequest<CreateAgentResponse>(apiKey, "/agents", {
    method: "POST",
    body: JSON.stringify({
      name: `Detective case ${dateId}`,
      prompt: {text: promptText},
      model: {id: getCursorModel()},
    }),
  });

  return {
    agentId: response.agent.id,
    runId: response.run.id,
  };
}

async function waitForRunResult(
  apiKey: string,
  agentId: string,
  runId: string,
): Promise<string> {
  const startedAt = Date.now();

  while (Date.now() - startedAt < MAX_POLL_MS) {
    const run = await cursorRequest<GetRunResponse>(
      apiKey,
      `/agents/${agentId}/runs/${runId}`,
    );

    if (TERMINAL_RUN_STATUSES.has(run.status)) {
      if (run.status !== "FINISHED") {
        throw new Error(`Cursor run ended with status ${run.status}`);
      }

      if (!run.result?.trim()) {
        throw new CaseValidationError("Cursor run finished without result text");
      }

      return run.result;
    }

    await sleep(POLL_INTERVAL_MS);
  }

  throw new Error(`Cursor run timed out after ${MAX_POLL_MS}ms`);
}

async function archiveAgent(apiKey: string, agentId: string): Promise<void> {
  try {
    await cursorRequest(apiKey, `/agents/${agentId}/archive`, {
      method: "POST",
    });
  } catch (error) {
    console.warn(JSON.stringify({
      event: "cursor_agent_archive_failed",
      agentId,
      error: error instanceof Error ? error.message : String(error),
    }));
  }
}

async function callCursorAgent(
  apiKey: string,
  dateId: string,
  userPrompt: string,
): Promise<string> {
  const promptText = buildAgentPrompt(dateId, userPrompt);
  const {agentId, runId} = await createNoRepoAgent(apiKey, dateId, promptText);

  try {
    return await waitForRunResult(apiKey, agentId, runId);
  } finally {
    await archiveAgent(apiKey, agentId);
  }
}

export async function generateCaseWithCursor(
  options: GenerateCaseOptions,
): Promise<DetectiveCasePayload> {
  let lastError = "Unknown validation error";

  for (let attempt = 1; attempt <= MAX_GENERATION_ATTEMPTS; attempt++) {
    const userPrompt = attempt === 1 ?
      buildUserPrompt(options.dateId) :
      buildRetryPrompt(options.dateId, lastError);

    try {
      const responseText = await callCursorAgent(
        options.apiKey,
        options.dateId,
        userPrompt,
      );
      return parseCaseResponse(responseText, options.dateId);
    } catch (error) {
      lastError = error instanceof Error ? error.message : String(error);
      console.error(
        JSON.stringify({
          event: "generate_case_attempt_failed",
          dateId: options.dateId,
          attempt,
          provider: "cursor",
          error: lastError,
        }),
      );

      if (attempt === MAX_GENERATION_ATTEMPTS) {
        throw new Error(
          `Failed to generate valid case after ${MAX_GENERATION_ATTEMPTS} attempts: ${lastError}`,
        );
      }
    }
  }

  throw new Error("Unexpected generation failure");
}

export {parseCaseResponse} from "./parseCase";
