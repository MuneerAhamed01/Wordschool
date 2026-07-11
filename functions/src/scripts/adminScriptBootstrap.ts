import {applicationDefault, initializeApp, getApps} from "firebase-admin/app";

export const DEFAULT_FIREBASE_PROJECT_ID = "wordschool-dev";

/**
 * Initializes firebase-admin for local maintenance scripts.
 *
 * Local `gcloud auth application-default login` credentials require a quota
 * project for Identity Toolkit (Firebase Auth). This helper sets
 * `GOOGLE_CLOUD_QUOTA_PROJECT` when it is missing.
 */
export function initializeAdminScript(
  projectId = process.env.FIREBASE_PROJECT_ID ||
    process.env.GCLOUD_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    DEFAULT_FIREBASE_PROJECT_ID,
): string {
  if (!process.env.GOOGLE_CLOUD_QUOTA_PROJECT) {
    process.env.GOOGLE_CLOUD_QUOTA_PROJECT = projectId;
  }

  if (getApps().length === 0) {
    initializeApp({
      credential: applicationDefault(),
      projectId,
    });
  }

  return projectId;
}

export function printAdminAuthHelp(projectId: string, error: unknown): void {
  const message = error instanceof Error ? error.message : String(error);
  console.error("\nFailed to access Firebase Auth for project:", projectId);
  console.error(message);
  console.error(`
Fix options (pick one):

1) Set ADC quota project (recommended for local dev):
   gcloud auth application-default set-quota-project ${projectId}

2) Run the script with an explicit quota project:
   GOOGLE_CLOUD_QUOTA_PROJECT=${projectId} npm run admin:claim -- your@email.com

3) Use a service account with Firebase Auth Admin role:
   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \\
   GOOGLE_CLOUD_QUOTA_PROJECT=${projectId} \\
   npm run admin:claim -- your@email.com

Also ensure the admin user exists in Firebase Console → Authentication.
`);
}
