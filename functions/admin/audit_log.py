from typing import Any

from firebase_admin import firestore

from firestore_client import db


def write_audit_log(
    *,
    action: str,
    admin_uid: str,
    target_id: str | None = None,
    payload: dict[str, Any] | None = None,
) -> None:
    """Append an entry to `adminAuditLog`.

    Args:
        action: What was done, e.g. `saveQuestion`.
        admin_uid: Who did it.
        target_id: The document that changed, if any.
        payload: Extra details worth keeping.
    """
    entry: dict[str, Any] = {
        "action": action,
        "adminUid": admin_uid,
        "timestamp": firestore.SERVER_TIMESTAMP,
    }
    if target_id is not None:
        entry["targetId"] = target_id
    if payload is not None:
        entry["payload"] = payload
    db().collection("adminAuditLog").add(entry)
