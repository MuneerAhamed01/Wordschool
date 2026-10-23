import {getIsoWeekId, istIsoWeekId} from "./isoWeekId";

describe("getIsoWeekId", () => {
  it.each([
    ["2026-10-23T12:00:00Z", "2026-W43"],
    ["2026-01-01T12:00:00Z", "2026-W01"],
    ["2027-01-01T12:00:00Z", "2026-W53"],
    ["2024-12-30T12:00:00Z", "2025-W01"],
    ["2026-10-19T00:00:00Z", "2026-W43"],
    ["2026-10-18T23:59:59Z", "2026-W42"],
  ])("%s is %s", (iso, expected) => {
    expect(getIsoWeekId(new Date(iso))).toBe(expected);
  });
});

describe("istIsoWeekId", () => {
  it("starts the new week at Monday 00:00 IST", () => {
    // Sunday 18:30 UTC = Monday 00:00 IST.
    expect(istIsoWeekId(new Date("2026-10-25T18:30:00Z"))).toBe("2026-W44");
  });

  it("keeps the old week until then", () => {
    expect(istIsoWeekId(new Date("2026-10-25T18:29:59Z"))).toBe("2026-W43");
  });
});
