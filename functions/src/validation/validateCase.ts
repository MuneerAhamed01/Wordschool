import {
  CLUE_TYPES_IN_ORDER,
  DetectiveCasePayload,
  DetectiveClue,
  MAX_NARRATIVE_LENGTH,
} from "../types/detectiveCase";
import {loadAnswerWords} from "./loadAnswerWords";

const WORD_ANSWER_PATTERN = /^[A-Z]{5}$/;

export class CaseValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "CaseValidationError";
  }
}

function assertNonEmptyString(
  value: unknown,
  fieldName: string,
): asserts value is string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new CaseValidationError(`${fieldName} must be a non-empty string`);
  }
  if (value.length > MAX_NARRATIVE_LENGTH) {
    throw new CaseValidationError(
      `${fieldName} must be at most ${MAX_NARRATIVE_LENGTH} characters`,
    );
  }
}

function validateClue(clue: DetectiveClue, expectedIndex: number): void {
  if (clue.index !== expectedIndex) {
    throw new CaseValidationError(
      `Clue index must be ${expectedIndex}, got ${clue.index}`,
    );
  }

  const expectedType = CLUE_TYPES_IN_ORDER[expectedIndex];
  if (clue.type !== expectedType) {
    throw new CaseValidationError(
      `Clue ${expectedIndex} type must be ${expectedType}, got ${clue.type}`,
    );
  }

  assertNonEmptyString(clue.hint, `clues[${expectedIndex}].hint`);
  assertNonEmptyString(clue.reaction, `clues[${expectedIndex}].reaction`);
  assertNonEmptyString(
    clue.investigatePrompt,
    `clues[${expectedIndex}].investigatePrompt`,
  );

  if (!WORD_ANSWER_PATTERN.test(clue.answer)) {
    throw new CaseValidationError(
      `Clue answer must be 5 uppercase letters, got "${clue.answer}"`,
    );
  }

  const answerWords = loadAnswerWords();
  if (!answerWords.has(clue.answer.toLowerCase())) {
    throw new CaseValidationError(
      `Clue answer "${clue.answer}" is not in the Wordle answer list`,
    );
  }
}

export function validateCase(payload: DetectiveCasePayload): DetectiveCasePayload {
  assertNonEmptyString(payload.title, "title");
  assertNonEmptyString(payload.introduction, "introduction");
  assertNonEmptyString(payload.resolution, "resolution");

  if (!Array.isArray(payload.clues) || payload.clues.length !== 3) {
    throw new CaseValidationError(
      `Detective case must have exactly 3 clues, got ${payload.clues?.length ?? 0}`,
    );
  }

  const answers = new Set<string>();
  for (let i = 0; i < payload.clues.length; i++) {
    validateClue(payload.clues[i], i);
    if (answers.has(payload.clues[i].answer)) {
      throw new CaseValidationError(
        `Clue answers must be distinct, duplicate "${payload.clues[i].answer}"`,
      );
    }
    answers.add(payload.clues[i].answer);
  }

  return payload;
}
