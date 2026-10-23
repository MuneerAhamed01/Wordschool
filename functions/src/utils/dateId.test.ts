import {isValidDateId, todayIstDateId} from "./dateId";

describe("todayIstDateId", () => {
  it("uses the IST day after 18:30 UTC", () => {
    expect(todayIstDateId(new Date("2026-10-23T18:30:00Z"))).toBe("2026-10-24");
  });

  it("stays on the IST day just before midnight IST", () => {
    expect(todayIstDateId(new Date("2026-10-23T18:29:59Z"))).toBe("2026-10-23");
  });

  it("rolls over the year at IST midnight", () => {
    expect(todayIstDateId(new Date("2026-12-31T18:30:00Z"))).toBe("2027-01-01");
  });
});

describe("isValidDateId", () => {
  it.each(["2026-10-23", "2028-02-29", "2026-12-31"])("accepts %s", (value) => {
    expect(isValidDateId(value)).toBe(true);
  });

  it.each([
    "2026-02-30",
    "2027-02-29",
    "2026-13-01",
    "2026-00-10",
    "2026-1-5",
    "26-10-23",
    "2026-10-23T00:00",
    "",
  ])("rejects %s", (value) => {
    expect(isValidDateId(value)).toBe(false);
  });
});
