import {
  getPlannedCase,
  listPlannedCaseDateIds,
  resetPlannedCaseCatalogForTests,
} from "./localCaseCatalog";

describe("localCaseCatalog", () => {
  afterEach(() => {
    resetPlannedCaseCatalogForTests();
  });

  it("loads 30 planned cases with valid structure", () => {
    const dateIds = listPlannedCaseDateIds();
    expect(dateIds).toHaveLength(30);
    expect(dateIds[0]).toBe("2026-06-28");
    expect(dateIds[29]).toBe("2026-07-27");
  });

  it("returns vocabulary-based clues without repeating answers within a case", () => {
    for (const dateId of listPlannedCaseDateIds()) {
      const payload = getPlannedCase(dateId);
      expect(payload).not.toBeNull();

      const answers = payload!.clues.map((clue) => clue.answer);
      expect(new Set(answers).size).toBe(3);
      expect(payload!.clues[2].type).toBe("suspect");
    }
  });

  it("includes murder and theft themed cases", () => {
    const titles = listPlannedCaseDateIds()
      .map((dateId) => getPlannedCase(dateId)!.title.toLowerCase());

    expect(titles.some((title) => title.includes("ledger") || title.includes("midnight"))).toBe(true);
    expect(titles.some((title) => title.includes("glass") || title.includes("theft") || title.includes("snatch"))).toBe(true);
  });
});
