import {validateCase, CaseValidationError} from "../validation/validateCase";
import {DetectiveCasePayload} from "../types/detectiveCase";

const validCase: DetectiveCasePayload = {
  title: "The Midnight Ledger",
  introduction: "Rain hammers the precinct windows.",
  resolution: "The case is closed.",
  clues: [
    {
      index: 0,
      type: "location",
      hint: "Where contracts are signed.",
      answer: "STUDY",
      reaction: "The study was locked.",
      investigatePrompt: "Search the crime scene.",
    },
    {
      index: 1,
      type: "weapon",
      hint: "A narrow puncture wound.",
      answer: "KNIFE",
      reaction: "A knife is missing.",
      investigatePrompt: "Identify the weapon.",
    },
    {
      index: 2,
      type: "suspect",
      hint: "Who inherits the firm.",
      answer: "HEIRS",
      reaction: "The heir had motive.",
      investigatePrompt: "Name the suspect.",
    },
  ],
};

describe("validateCase", () => {
  it("accepts a valid seed-style case", () => {
    expect(() => validateCase(validCase)).not.toThrow();
  });

  it("rejects wrong clue count", () => {
    expect(() => validateCase({...validCase, clues: validCase.clues.slice(0, 2)}))
      .toThrow(CaseValidationError);
  });

  it("rejects invalid answer length", () => {
    const badCase: DetectiveCasePayload = {
      ...validCase,
      clues: [
        {...validCase.clues[0], answer: "STUD"},
        validCase.clues[1],
        validCase.clues[2],
      ],
    };
    expect(() => validateCase(badCase)).toThrow(CaseValidationError);
  });

  it("rejects duplicate answers", () => {
    const badCase: DetectiveCasePayload = {
      ...validCase,
      clues: [
        validCase.clues[0],
        {...validCase.clues[1], answer: "STUDY"},
        validCase.clues[2],
      ],
    };
    expect(() => validateCase(badCase)).toThrow(CaseValidationError);
  });

  it("rejects unknown answer words", () => {
    const badCase: DetectiveCasePayload = {
      ...validCase,
      clues: [
        {...validCase.clues[0], answer: "ZZZZZ"},
        validCase.clues[1],
        validCase.clues[2],
      ],
    };
    expect(() => validateCase(badCase)).toThrow(CaseValidationError);
  });

  it("rejects wrong clue type order", () => {
    const badCase: DetectiveCasePayload = {
      ...validCase,
      clues: [
        {...validCase.clues[0], type: "weapon"},
        validCase.clues[1],
        validCase.clues[2],
      ],
    };
    expect(() => validateCase(badCase)).toThrow(CaseValidationError);
  });
});
