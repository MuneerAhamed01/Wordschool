import {FieldValue, Firestore} from "firebase-admin/firestore";
import {prodDb} from "./firestore";
import {DetectiveCasePayload} from "./types/detectiveCase";

const COLLECTION = "detectiveCases";

export async function caseExists(
  dateId: string,
  db: Firestore = prodDb(),
): Promise<boolean> {
  const doc = await db.collection(COLLECTION).doc(dateId).get();
  return doc.exists;
}

export async function writeDetectiveCase(
  dateId: string,
  payload: DetectiveCasePayload,
  options?: {force?: boolean; db?: Firestore},
): Promise<"created" | "skipped"> {
  const db = options?.db ?? prodDb();
  const docRef = db.collection(COLLECTION).doc(dateId);

  if (!options?.force) {
    const existing = await docRef.get();
    if (existing.exists) {
      return "skipped";
    }
  }

  const data = {
    id: dateId,
    title: payload.title,
    introduction: payload.introduction,
    resolution: payload.resolution,
    clues: payload.clues.map((clue) => ({
      index: clue.index,
      type: clue.type,
      hint: clue.hint,
      answer: clue.answer,
      reaction: clue.reaction,
      investigatePrompt: clue.investigatePrompt,
    })),
    createdAt: FieldValue.serverTimestamp(),
  };

  if (options?.force) {
    await docRef.set(data);
    return "created";
  }

  try {
    await docRef.create(data);
    return "created";
  } catch (error) {
    const err = error as {code?: number | string};
    if (err.code === 6 || err.code === "already-exists") {
      return "skipped";
    }
    throw error;
  }
}
