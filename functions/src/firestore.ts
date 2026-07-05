import {getApp} from "firebase-admin/app";
import {Firestore, getFirestore} from "firebase-admin/firestore";

export const DEV_DATABASE_ID = "development";

/** Production Firestore database `(default)`. Used by schedulers and triggers. */
export function prodDb(): Firestore {
  return getFirestore(getApp());
}

/** Dev/staging Firestore database. Use only for seeds and manual testing. */
export function devDb(): Firestore {
  return getFirestore(getApp(), DEV_DATABASE_ID);
}

export function dbForDatabaseId(databaseId?: string): Firestore {
  if (databaseId === DEV_DATABASE_ID) {
    return devDb();
  }
  return prodDb();
}

/** Resolves DB from `FIRESTORE_DATABASE_ID` env var (e.g. `dev` for local seed scripts). */
export function dbFromEnv(): Firestore {
  return dbForDatabaseId(process.env.FIRESTORE_DATABASE_ID);
}

export function configureEmulatorIfNeeded(db: Firestore): void {
  if (process.env.FIRESTORE_EMULATOR_HOST) {
    db.settings({
      host: process.env.FIRESTORE_EMULATOR_HOST,
      ssl: false,
    });
  }
}
