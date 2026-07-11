import {getAuth} from "firebase-admin/auth";
import {
  initializeAdminScript,
  printAdminAuthHelp,
} from "./adminScriptBootstrap";

async function main(): Promise<void> {
  const email = process.argv[2];
  const action = process.argv[3] ?? "grant";

  if (!email) {
    console.error("Usage: node lib/scripts/setAdminClaim.js <email> [grant|revoke]");
    process.exit(1);
  }

  const projectId = initializeAdminScript();
  const auth = getAuth();

  let user;
  try {
    user = await auth.getUserByEmail(email);
  } catch (error) {
    printAdminAuthHelp(projectId, error);
    process.exit(1);
  }

  if (action === "revoke") {
    await auth.setCustomUserClaims(user.uid, {admin: false});
    console.log(JSON.stringify({
      event: "admin_claim_revoked",
      uid: user.uid,
      email,
      projectId,
    }));
    return;
  }

  await auth.setCustomUserClaims(user.uid, {admin: true});
  console.log(JSON.stringify({
    event: "admin_claim_granted",
    uid: user.uid,
    email,
    projectId,
  }));
}

main().catch((error) => {
  const projectId = process.env.GOOGLE_CLOUD_QUOTA_PROJECT ||
    process.env.FIREBASE_PROJECT_ID ||
    "wordschool-dev";
  printAdminAuthHelp(projectId, error);
  process.exit(1);
});
