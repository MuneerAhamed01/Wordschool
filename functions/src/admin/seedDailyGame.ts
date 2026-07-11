import {FieldValue} from "firebase-admin/firestore";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {assertAdmin, parseDatabaseId} from "./assertAdmin";
import {writeAuditLog} from "./auditLog";
import {loadAnswerWordsList} from "./answerWordsList";
import {dartStringHashCode} from "./dartStringHash";
import {dbForDatabaseId} from "../firestore";
import {isValidDateId} from "../utils/dateId";

interface SeedDailyGameRequest {
  dateId: string;
  todayWord?: string;
  force?: boolean;
  databaseId?: string;
}

function hashWordForDate(dateId: string): string {
  const words = loadAnswerWordsList();
  const index = Math.abs(dartStringHashCode(dateId)) % words.length;
  return words[index];
}

export const adminSeedDailyGame = onCall(async (request) => {
  const adminUid = assertAdmin(request);
  const data = (request.data ?? {}) as SeedDailyGameRequest;
  const databaseId = parseDatabaseId(data.databaseId);
  const dbLabel = databaseId ?? "(default)";

  if (!data.dateId || !isValidDateId(data.dateId)) {
    throw new HttpsError("invalid-argument", "dateId must be YYYY-MM-DD");
  }

  const docRef = dbForDatabaseId(databaseId).collection("games").doc(data.dateId);
  const existing = await docRef.get();

  if (existing.exists && data.force !== true) {
    throw new HttpsError(
      "already-exists",
      `Game for ${data.dateId} already exists. Pass force=true to override.`,
    );
  }

  const todayWord = (data.todayWord ?? hashWordForDate(data.dateId)).toLowerCase();
  const answers = new Set(loadAnswerWordsList());
  if (!answers.has(todayWord) || todayWord.length !== 5) {
    throw new HttpsError(
      "invalid-argument",
      "todayWord must be a 5-letter word from answers.txt",
    );
  }

  const payload = {
    id: data.dateId,
    todayWord,
    isCompleted: false,
    createdDate: existing.exists ?
      existing.data()?.createdDate ?? FieldValue.serverTimestamp() :
      FieldValue.serverTimestamp(),
    updatedDate: FieldValue.serverTimestamp(),
  };

  await docRef.set(payload, {merge: false});

  await writeAuditLog({
    action: "seed_daily_game",
    adminUid,
    databaseId: dbLabel,
    targetId: data.dateId,
    payload: {todayWord, force: data.force === true},
  }, databaseId);

  return {dateId: data.dateId, todayWord, status: "created"};
});

interface SeedMissingGamesRequest {
  startDateId: string;
  endDateId: string;
  databaseId?: string;
}

export const adminSeedMissingGames = onCall(async (request) => {
  const adminUid = assertAdmin(request);
  const data = (request.data ?? {}) as SeedMissingGamesRequest;
  const databaseId = parseDatabaseId(data.databaseId);
  const dbLabel = databaseId ?? "(default)";

  if (!isValidDateId(data.startDateId) || !isValidDateId(data.endDateId)) {
    throw new HttpsError("invalid-argument", "Invalid date range");
  }

  const db = dbForDatabaseId(databaseId);
  const created: string[] = [];
  const skipped: string[] = [];

  const current = new Date(`${data.startDateId}T00:00:00Z`);
  const end = new Date(`${data.endDateId}T00:00:00Z`);

  while (current <= end) {
    const dateId = current.toISOString().slice(0, 10);
    const docRef = db.collection("games").doc(dateId);
    const existing = await docRef.get();

    if (existing.exists) {
      skipped.push(dateId);
    } else {
      const todayWord = hashWordForDate(dateId);
      await docRef.set({
        id: dateId,
        todayWord,
        isCompleted: false,
        createdDate: FieldValue.serverTimestamp(),
        updatedDate: FieldValue.serverTimestamp(),
      });
      created.push(dateId);
    }

    current.setUTCDate(current.getUTCDate() + 1);
  }

  await writeAuditLog({
    action: "seed_missing_games",
    adminUid,
    databaseId: dbLabel,
    payload: {
      startDateId: data.startDateId,
      endDateId: data.endDateId,
      createdCount: created.length,
    },
  }, databaseId);

  return {created, skipped};
});

interface ListGamesRequest {
  startDateId: string;
  endDateId: string;
  databaseId?: string;
}

export const adminListGames = onCall(async (request) => {
  assertAdmin(request);
  const data = (request.data ?? {}) as ListGamesRequest;
  const databaseId = parseDatabaseId(data.databaseId);

  if (!isValidDateId(data.startDateId) || !isValidDateId(data.endDateId)) {
    throw new HttpsError("invalid-argument", "Invalid date range");
  }

  const db = dbForDatabaseId(databaseId);
  const games: Array<{dateId: string; todayWord: string; exists: boolean}> = [];

  const current = new Date(`${data.startDateId}T00:00:00Z`);
  const end = new Date(`${data.endDateId}T00:00:00Z`);

  while (current <= end) {
    const dateId = current.toISOString().slice(0, 10);
    const doc = await db.collection("games").doc(dateId).get();
    games.push({
      dateId,
      todayWord: doc.exists ? (doc.data()?.todayWord as string) ?? "" : "",
      exists: doc.exists,
    });
    current.setUTCDate(current.getUTCDate() + 1);
  }

  return {games};
});

interface DeleteGameRequest {
  dateId: string;
  databaseId?: string;
}

export const adminDeleteGame = onCall(async (request) => {
  const adminUid = assertAdmin(request);
  const data = (request.data ?? {}) as DeleteGameRequest;
  const databaseId = parseDatabaseId(data.databaseId);
  const dbLabel = databaseId ?? "(default)";

  if (!data.dateId || !isValidDateId(data.dateId)) {
    throw new HttpsError("invalid-argument", "dateId must be YYYY-MM-DD");
  }

  await dbForDatabaseId(databaseId).collection("games").doc(data.dateId).delete();

  await writeAuditLog({
    action: "delete_daily_game",
    adminUid,
    databaseId: dbLabel,
    targetId: data.dateId,
  }, databaseId);

  return {dateId: data.dateId, status: "deleted"};
});
