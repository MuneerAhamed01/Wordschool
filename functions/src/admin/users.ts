import {FieldValue} from "firebase-admin/firestore";
import {getAuth} from "firebase-admin/auth";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {assertAdmin, parseDatabaseId} from "./assertAdmin";
import {writeAuditLog} from "./auditLog";
import {dbForDatabaseId} from "../firestore";

interface BlockUserRequest {
  uid: string;
  reason?: string;
  disableAuth?: boolean;
  databaseId?: string;
}

export const adminBlockUser = onCall(async (request) => {
  const adminUid = assertAdmin(request);
  const data = (request.data ?? {}) as BlockUserRequest;
  const databaseId = parseDatabaseId(data.databaseId);
  const dbLabel = databaseId ?? "(default)";

  if (!data.uid?.trim()) {
    throw new HttpsError("invalid-argument", "uid is required");
  }

  const uid = data.uid.trim();
  const db = dbForDatabaseId(databaseId);
  const docRef = db.collection("userGameStates").doc(uid);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new HttpsError("not-found", `No userGameState for uid ${uid}`);
  }

  await docRef.update({
    blockedAt: FieldValue.serverTimestamp(),
    blockedReason: data.reason?.trim() || "Blocked by admin",
    blockedBy: adminUid,
    updatedDate: FieldValue.serverTimestamp(),
  });

  if (data.disableAuth === true) {
    await getAuth().updateUser(uid, {disabled: true});
  }

  await writeAuditLog({
    action: "block_user",
    adminUid,
    databaseId: dbLabel,
    targetId: uid,
    payload: {reason: data.reason, disableAuth: data.disableAuth === true},
  }, databaseId);

  return {uid, status: "blocked"};
});

interface UnblockUserRequest {
  uid: string;
  enableAuth?: boolean;
  databaseId?: string;
}

export const adminUnblockUser = onCall(async (request) => {
  const adminUid = assertAdmin(request);
  const data = (request.data ?? {}) as UnblockUserRequest;
  const databaseId = parseDatabaseId(data.databaseId);
  const dbLabel = databaseId ?? "(default)";

  if (!data.uid?.trim()) {
    throw new HttpsError("invalid-argument", "uid is required");
  }

  const uid = data.uid.trim();
  const db = dbForDatabaseId(databaseId);
  const docRef = db.collection("userGameStates").doc(uid);
  const doc = await docRef.get();

  if (!doc.exists) {
    throw new HttpsError("not-found", `No userGameState for uid ${uid}`);
  }

  await docRef.update({
    blockedAt: FieldValue.delete(),
    blockedReason: FieldValue.delete(),
    blockedBy: FieldValue.delete(),
    updatedDate: FieldValue.serverTimestamp(),
  });

  if (data.enableAuth === true) {
    try {
      await getAuth().updateUser(uid, {disabled: false});
    } catch {
      // User may not exist in Auth (edge case).
    }
  }

  await writeAuditLog({
    action: "unblock_user",
    adminUid,
    databaseId: dbLabel,
    targetId: uid,
  }, databaseId);

  return {uid, status: "unblocked"};
});

interface SearchUsersRequest {
  query: string;
  databaseId?: string;
}

export const adminSearchUsers = onCall(async (request) => {
  assertAdmin(request);
  const data = (request.data ?? {}) as SearchUsersRequest;
  const databaseId = parseDatabaseId(data.databaseId);
  const query = data.query?.trim();

  if (!query) {
    throw new HttpsError("invalid-argument", "query is required");
  }

  const db = dbForDatabaseId(databaseId);
  const auth = getAuth();

  let uid = query;
  let email: string | undefined;
  let displayName: string | undefined;
  let authDisabled = false;

  if (query.includes("@")) {
    try {
      const user = await auth.getUserByEmail(query);
      uid = user.uid;
      email = user.email;
      displayName = user.displayName;
      authDisabled = user.disabled;
    } catch {
      throw new HttpsError("not-found", `No user found for email ${query}`);
    }
  } else {
    try {
      const user = await auth.getUser(query);
      email = user.email;
      displayName = user.displayName;
      authDisabled = user.disabled;
    } catch {
      // UID may exist only in Firestore (anonymous edge cases).
    }
  }

  const stateDoc = await db.collection("userGameStates").doc(uid).get();
  if (!stateDoc.exists) {
    throw new HttpsError("not-found", `No userGameState for uid ${uid}`);
  }

  const state = stateDoc.data() ?? {};

  return {
    uid,
    email,
    displayName,
    authDisabled,
    streak: state.streak ?? 0,
    completedGames: state.completedGames ?? 0,
    detectivePoints: state.detectivePoints ?? 0,
    blockedAt: state.blockedAt ?? null,
    blockedReason: state.blockedReason ?? null,
    blockedBy: state.blockedBy ?? null,
    updatedDate: state.updatedDate ?? null,
  };
});
