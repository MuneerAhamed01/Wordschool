import {parseCaseResponse} from "../cursor/parseCase";
import {CaseValidationError} from "../validation/validateCase";

describe("parseCaseResponse", () => {
  it("parses fenced JSON and normalizes answers", () => {
    const response = "```json\n" + JSON.stringify({
      title: "Case Title",
      introduction: "Intro text",
      resolution: "Final resolution",
      clues: [
        {
          index: 0,
          type: "location",
          hint: "Hint one",
          answer: "study",
          reaction: "Reaction one",
          investigatePrompt: "Prompt one",
        },
        {
          index: 1,
          type: "weapon",
          hint: "Hint two",
          answer: "knife",
          reaction: "Reaction two",
          investigatePrompt: "Prompt two",
        },
        {
          index: 2,
          type: "suspect",
          hint: "Hint three",
          answer: "heirs",
          reaction: "Reaction three",
          investigatePrompt: "Prompt three",
        },
      ],
    }) + "\n```";

    const parsed = parseCaseResponse(response, "2026-06-21");
    expect(parsed.id).toBe("2026-06-21");
    expect(parsed.clues[0].answer).toBe("STUDY");
    expect(parsed.clues[1].answer).toBe("KNIFE");
    expect(parsed.clues[2].answer).toBe("HEIRS");
  });

  it("rejects invalid JSON", () => {
    expect(() => parseCaseResponse("not-json", "2026-06-21"))
      .toThrow(CaseValidationError);
  });
});
