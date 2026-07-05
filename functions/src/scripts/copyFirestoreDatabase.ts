import {initializeApp, getApps} from "firebase-admin/app";
import {
  CollectionReference,
  Firestore,
  getFirestore,
} from "firebase-admin/firestore";

const SOURCE_DATABASE_ID = "(default)";
const DEST_DATABASE_ID = "development";
const PROJECT_ID =
  process.env.GCLOUD_PROJECT ||
  process.env.GOOGLE_CLOUD_PROJECT ||
  "wordschool-dev";

async function copyCollectionRecursive(
  sourceCollection: CollectionReference,
  destDb: Firestore,
): Promise<number> {
  const snapshot = await sourceCollection.get();
  let copied = 0;

  for (const doc of snapshot.docs) {
    await destDb.doc(doc.ref.path).set(doc.data());
    copied++;

    const subcollections = await doc.ref.listCollections();
    for (const subcollection of subcollections) {
      copied += await copyCollectionRecursive(subcollection, destDb);
    }
  }

  return copied;
}

async function copyDatabase(
  sourceDb: Firestore,
  destDb: Firestore,
): Promise<number> {
  const collections = await sourceDb.listCollections();
  let copied = 0;

  for (const collection of collections) {
    console.log(`Copying collection: ${collection.id}`);
    copied += await copyCollectionRecursive(collection, destDb);
  }

  return copied;
}

async function main(): Promise<void> {
  if (getApps().length === 0) {
    initializeApp({projectId: PROJECT_ID});
  }

  const sourceDb = getFirestore(getApps()[0], SOURCE_DATABASE_ID);
  const destDb = getFirestore(getApps()[0], DEST_DATABASE_ID);

  console.log(
    `Copying Firestore data: ${SOURCE_DATABASE_ID} -> ${DEST_DATABASE_ID} (${PROJECT_ID})`,
  );

  const copied = await copyDatabase(sourceDb, destDb);

  console.log(
    JSON.stringify({
      event: "firestore_copy_complete",
      sourceDatabaseId: SOURCE_DATABASE_ID,
      destDatabaseId: DEST_DATABASE_ID,
      documentsCopied: copied,
      projectId: PROJECT_ID,
    }),
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
