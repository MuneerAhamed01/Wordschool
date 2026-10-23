import {initializeApp, getApps} from "firebase-admin/app";
import {setGlobalOptions} from "firebase-functions/v2";

if (getApps().length === 0) {
  initializeApp();
}
setGlobalOptions({region: "asia-south1", maxInstances: 10});

// Crossword exports go here (CW-015 onwards), kept together.
