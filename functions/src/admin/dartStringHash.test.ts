import {dartStringHashCode} from "../admin/dartStringHash";
import {loadAnswerWordsList} from "../admin/answerWordsList";

describe("dartStringHashCode", () => {
  it("is deterministic for date ids", () => {
    const a = dartStringHashCode("2026-07-11");
    const b = dartStringHashCode("2026-07-11");
    expect(a).toBe(b);
    expect(a).not.toBe(dartStringHashCode("2026-07-12"));
  });

  it("selects valid answer words for known dates", () => {
    const words = loadAnswerWordsList();
    expect(words.length).toBeGreaterThan(0);

    const dateId = "2026-07-11";
    const index = Math.abs(dartStringHashCode(dateId)) % words.length;
    const word = words[index];
    expect(word).toHaveLength(5);
  });
});
