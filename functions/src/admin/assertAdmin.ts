import {CallableRequest, HttpsError} from "firebase-functions/v2/https";

export function assertAdmin(request: CallableRequest<unknown>): string {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required");
  }

  const isAdmin = request.auth?.token?.admin === true;
  if (!isAdmin) {
    throw new HttpsError("permission-denied", "Admin access required");
  }

  return uid;
}

export function parseDatabaseId(raw?: string): string | undefined {
  if (!raw || raw === "(default)") {
    return undefined;
  }
  if (raw === "development") {
    return raw;
  }
  throw new HttpsError(
    "invalid-argument",
    "databaseId must be 'development' or '(default)'",
  );
}
