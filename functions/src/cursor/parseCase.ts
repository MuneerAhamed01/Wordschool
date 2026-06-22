import {DetectiveCasePayload} from "../types/detectiveCase";
import {CaseValidationError, validateCase} from "../validation/validateCase";

function stripMarkdownFences(text: string): string {
  const trimmed = text.trim();
  if (trimmed.startsWith("```")) {
    return trimmed
      .replace(/^```(?:json)?\s*/i, "")
      .replace(/\s*```$/, "")
      .trim();
  }
  return trimmed;
}

function normalizeCasePayload(
  raw: unknown,
  dateId: string,
): DetectiveCasePayload {
  if (!raw || typeof raw !== "object") {
    throw new CaseValidationError("Cursor response must be a JSON object");
  }

  const payload = raw as Record<string, unknown>;
  const clues = payload.clues;

  if (!Array.isArray(clues)) {
    throw new CaseValidationError("Cursor response missing clues array");
  }

  const normalizedClues = clues.map((clue, index) => {
    if (!clue || typeof clue !== "object") {
      throw new CaseValidationError(`clues[${index}] must be an object`);
    }
    const clueRecord = clue as Record<string, unknown>;
    const answer = String(clueRecord.answer ?? "").trim().toUpperCase();

    return {
      index: Number(clueRecord.index),
      type: String(clueRecord.type).trim().toLowerCase(),
      hint: String(clueRecord.hint ?? "").trim(),
      answer,
      reaction: String(clueRecord.reaction ?? "").trim(),
      investigatePrompt: String(clueRecord.investigatePrompt ?? "").trim(),
    };
  });

  return {
    id: dateId,
    title: String(payload.title ?? "").trim(),
    introduction: String(payload.introduction ?? "").trim(),
    resolution: String(payload.resolution ?? "").trim(),
    clues: normalizedClues as DetectiveCasePayload["clues"],
  };
}

export function parseCaseResponse(
  responseText: string,
  dateId: string,
): DetectiveCasePayload {
  const jsonText = stripMarkdownFences(responseText);
  let parsed: unknown;

  try {
    parsed = JSON.parse(jsonText);
  } catch (error) {
    throw new CaseValidationError(
      `Cursor response is not valid JSON: ${(error as Error).message}`,
    );
  }

  const normalized = normalizeCasePayload(parsed, dateId);
  return validateCase(normalized);
}
