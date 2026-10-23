import {getFirestore, Firestore} from "firebase-admin/firestore";

/** Default Firestore database of the current project. */
export const db = (): Firestore => getFirestore();
