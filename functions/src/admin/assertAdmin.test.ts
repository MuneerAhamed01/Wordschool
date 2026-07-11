import {HttpsError} from "firebase-functions/v2/https";
import {assertAdmin, parseDatabaseId} from "./assertAdmin";

describe("assertAdmin", () => {
  it("throws when unauthenticated", () => {
    expect(() => assertAdmin({auth: undefined} as never)).toThrow(HttpsError);
  });

  it("throws when missing admin claim", () => {
    expect(() =>
      assertAdmin({
        auth: {uid: "u1", token: {}},
      } as never),
    ).toThrow(HttpsError);
  });

  it("returns uid for admin users", () => {
    const uid = assertAdmin({
      auth: {uid: "admin1", token: {admin: true}},
    } as never);
    expect(uid).toBe("admin1");
  });
});

describe("parseDatabaseId", () => {
  it("accepts development", () => {
    expect(parseDatabaseId("development")).toBe("development");
  });

  it("maps default to undefined", () => {
    expect(parseDatabaseId("(default)")).toBeUndefined();
  });

  it("rejects unknown databases", () => {
    expect(() => parseDatabaseId("staging")).toThrow(HttpsError);
  });
});
