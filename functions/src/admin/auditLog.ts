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
  await db().collection("adminAuditLog").add({
    ...entry,
    timestamp: FieldValue.serverTimestamp(),
  });
}
