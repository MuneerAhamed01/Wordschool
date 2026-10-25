"""Grant or revoke the `admin` custom claim (CW-024), and set an admin's password (CW-037).

Usage (from functions/):
    venv/bin/python -m scripts.set_admin_claim you@example.com --password  # + set password
    venv/bin/python -m scripts.set_admin_claim you@example.com            # grant
    venv/bin/python -m scripts.set_admin_claim you@example.com --revoke
    venv/bin/python -m scripts.set_admin_claim you@example.com --project <id>

The admin panel signs in with email + password (Firebase Auth "Email/Password" provider must be
enabled). `--password` asks for a password twice (never on the command line): it creates the
account if the email has none, or adds/replaces the password on an existing account (e.g. one
made by Google sign-in in the player app). Without `--password` the account must already exist.

Credentials: Application Default Credentials (`gcloud auth application-default login`)
or `GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json`. An admin who is already signed in gets
the claim on their next token refresh (sign out and in again).
"""

import argparse
import getpass
import json
import os
import sys
from typing import Any

DEFAULT_PROJECT = "kerala-pcs-dev"
MIN_PASSWORD_LENGTH = 8


def next_claims(existing: dict[str, Any] | None, *, grant: bool) -> dict[str, Any]:
    """Existing custom claims with `admin` set or removed (other claims kept)."""
    claims = dict(existing or {})
    if grant:
        claims["admin"] = True
    else:
        claims.pop("admin", None)
    return claims


def password_problem(password: str, repeat: str) -> str | None:
    """Why a new admin password can't be used, or None when it can."""
    if len(password) < MIN_PASSWORD_LENGTH:
        return f"Use at least {MIN_PASSWORD_LENGTH} characters."
    if password != repeat:
        return "The two passwords don't match."
    return None


def _ask_password() -> str | None:
    password = getpass.getpass("New admin password: ")
    problem = password_problem(password, getpass.getpass("Repeat it: "))
    if problem:
        print(problem, file=sys.stderr)
        return None
    return password


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

Also check the user exists in Firebase Console → Authentication (or pass --password).
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
        "--password",
        action="store_true",
        help="ask for a password; create the account if missing, else set its password",
    )
    parser.add_argument(
        "--project",
        default=os.environ.get("FIREBASE_PROJECT_ID", DEFAULT_PROJECT),
        help=f"Firebase project id (default {DEFAULT_PROJECT})",
    )
    args = parser.parse_args(argv)
    if args.password and args.revoke:
        parser.error("--password and --revoke can't be used together")
    password = _ask_password() if args.password else None
    if args.password and password is None:
        return 1

    import firebase_admin
    from firebase_admin import auth, credentials

    os.environ.setdefault("GOOGLE_CLOUD_QUOTA_PROJECT", args.project)
    try:
        firebase_admin.initialize_app(
            credentials.ApplicationDefault(), options={"projectId": args.project}
        )
        try:
            user = auth.get_user_by_email(args.email)
            if password:
                user = auth.update_user(user.uid, password=password)
        except auth.UserNotFoundError:
            if not password:
                print(
                    f"No user {args.email} in {args.project}. Run again with --password to "
                    "create the account.",
                    file=sys.stderr,
                )
                return 1
            user = auth.create_user(email=args.email, password=password)
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
