import {FieldValue} from "firebase-admin/firestore";
import {dbForDatabaseId} from "../firestore";

const COLLECTION = "adminAuditLog";

export interface AuditLogEntry {
  action: string;
  adminUid: string;
  databaseId: string;
  targetId?: string;
  payload?: Record<string, unknown>;
}

export async function writeAuditLog(
  entry: AuditLogEntry,
  databaseId?: string,
): Promise<void> {
  const db = dbForDatabaseId(databaseId);
  await db.collection(COLLECTION).add({
    ...entry,
    databaseId: entry.databaseId,
    timestamp: FieldValue.serverTimestamp(),
  });
}
