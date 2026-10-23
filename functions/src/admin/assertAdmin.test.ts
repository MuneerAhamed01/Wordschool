import {HttpsError} from "firebase-functions/v2/https";
import {assertAdmin} from "./assertAdmin";

describe("assertAdmin", () => {
  it("rejects unauthenticated callers", () => {
    expect(() => assertAdmin({auth: undefined} as never)).toThrow(
      expect.objectContaining({code: "unauthenticated"}),
    );
  });

  it("rejects callers without the admin claim", () => {
    expect(() => assertAdmin({auth: {uid: "u1", token: {}}} as never)).toThrow(
      expect.objectContaining({code: "permission-denied"}),
    );
  });

  it("rejects a truthy but non-boolean admin claim", () => {
    expect(() =>
      assertAdmin({auth: {uid: "u1", token: {admin: "true"}}} as never),
    ).toThrow(HttpsError);
  });

  it("returns the uid for admins", () => {
    expect(assertAdmin({auth: {uid: "admin1", token: {admin: true}}} as never))
      .toBe("admin1");
  });
});
