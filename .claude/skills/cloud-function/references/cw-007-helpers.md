# CW-007 starter: shared helpers

Verified to type-check, lint (google style) and test with the generated functions. Copy into `functions/src/` when doing CW-007, together with `package.json`, `tsconfig*.json`, `.eslintrc.js` and `jest.config.js` from the `development` branch's `functions/` folder (remove ` && cp -r src/data lib/data` from the `build` script).

## `src/index.ts`

```ts
import {initializeApp, getApps} from "firebase-admin/app";
import {setGlobalOptions} from "firebase-functions/v2";

if (getApps().length === 0) {
  initializeApp();
}
setGlobalOptions({region: "asia-south1", maxInstances: 10});
export {adminSaveCategory} from "./crossword/adminSaveCategory";
export {submitCrossword} from "./crossword/submitCrossword";
export {crosswordDailyRollover} from "./crossword/crosswordDailyRollover";
export {onProgressWrite} from "./crossword/onProgressWrite";
```

## `src/firestore.ts`

```ts
import {getFirestore, Firestore} from "firebase-admin/firestore";

/** Default Firestore database of the current project. */
export const db = (): Firestore => getFirestore();
```

## `src/admin/assertAdmin.ts`

```ts
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
```

## `src/admin/auditLog.ts`

```ts
import {FieldValue} from "firebase-admin/firestore";
import {db} from "../firestore";

export interface AuditLogEntry {
  action: string;
  adminUid: string;
  targetId?: string;
  payload?: Record<string, unknown>;
}

/**
 * Appends an entry to `adminAuditLog`.
 * @param {AuditLogEntry} entry What changed and who changed it.
 */
export async function writeAuditLog(entry: AuditLogEntry): Promise<void> {
  await db().collection("adminAuditLog").add({...entry, timestamp: FieldValue.serverTimestamp()});
}
```

Still to add in CW-007: `src/utils/dateId.ts` (`todayIstDateId()`, `isValidDateId()`), `src/utils/isoWeekId.ts` (port from `development`), tests for all of them, and `"functions": [{"source": "functions", "codebase": "default"}]` in `firebase.json`.
