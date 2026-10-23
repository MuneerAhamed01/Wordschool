import {CallableRequest, HttpsError} from "firebase-functions/v2/https";

/**
 * Throws unless the caller has the `admin` custom claim.
 * @param {CallableRequest<unknown>} request Callable request.
 * @return {string} The admin's uid.
 */
export function assertAdmin(request: CallableRequest<unknown>): string {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required");
  }
  if (request.auth?.token?.admin !== true) {
    throw new HttpsError("permission-denied", "Admin access required");
  }
  return uid;
}
