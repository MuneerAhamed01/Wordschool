"""Grant or revoke the `admin` custom claim (CW-024).

Usage (from functions/):
    venv/bin/python -m scripts.set_admin_claim you@example.com            # grant
    venv/bin/python -m scripts.set_admin_claim you@example.com --revoke
    venv/bin/python -m scripts.set_admin_claim you@example.com --project <id>

Credentials: Application Default Credentials (`gcloud auth application-default login`)
or `GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json`. The user must have signed in to
the app once. They get the claim on their next token refresh (sign out and in again).
"""

import argparse
import json
import os
import sys
from typing import Any

DEFAULT_PROJECT = "kerala-pcs-dev"


def next_claims(existing: dict[str, Any] | None, *, grant: bool) -> dict[str, Any]:
    """Existing custom claims with `admin` set or removed (other claims kept)."""
    claims = dict(existing or {})
    if grant:
        claims["admin"] = True
    else:
        claims.pop("admin", None)
    return claims


def _help(project: str, error: Exception) -> str:
    return f"""
Failed to access Firebase Auth for project {project}: {error}

Fix options (pick one):
1) Set the ADC quota project (recommended for local dev):
   gcloud auth application-default set-quota-project {project}
2) Run with an explicit quota project:
   GOOGLE_CLOUD_QUOTA_PROJECT={project} venv/bin/python -m scripts.set_admin_claim <email>
3) Use a service account with the Firebase Authentication Admin role:
   GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json \\
     venv/bin/python -m scripts.set_admin_claim <email>

Also check the user exists in Firebase Console → Authentication (sign in to the app once).
"""


def main(argv: list[str] | None = None) -> int:
    """Run the script.

    Returns:
        Process exit code.
    """
    parser = argparse.ArgumentParser(description="Grant or revoke the admin custom claim.")
    parser.add_argument("email")
    parser.add_argument("--revoke", action="store_true", help="remove the claim")
    parser.add_argument(
        "--project",
        default=os.environ.get("FIREBASE_PROJECT_ID", DEFAULT_PROJECT),
        help=f"Firebase project id (default {DEFAULT_PROJECT})",
    )
    args = parser.parse_args(argv)

    import firebase_admin
    from firebase_admin import auth, credentials

    os.environ.setdefault("GOOGLE_CLOUD_QUOTA_PROJECT", args.project)
    try:
        firebase_admin.initialize_app(
            credentials.ApplicationDefault(), options={"projectId": args.project}
        )
        try:
            user = auth.get_user_by_email(args.email)
        except auth.UserNotFoundError:
            print(
                f"No user {args.email} in {args.project}. Sign in to the app once with that "
                "account, then run this again.",
                file=sys.stderr,
            )
            return 1
        claims = next_claims(user.custom_claims, grant=not args.revoke)
        auth.set_custom_user_claims(user.uid, claims or None)
    except Exception as error:  # Any ADC/Auth failure: show the setup help.
        print(_help(args.project, error), file=sys.stderr)
        return 1
    event = "admin_claim_revoked" if args.revoke else "admin_claim_granted"
    print(
        json.dumps({"event": event, "uid": user.uid, "email": args.email, "project": args.project})
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
