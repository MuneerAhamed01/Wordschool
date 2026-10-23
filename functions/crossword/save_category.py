from typing import Any, cast

from firebase_admin import firestore
from firebase_functions import https_fn
from google.cloud.firestore import Client, Transaction

from admin.assert_admin import assert_admin
from admin.audit_log import write_audit_log
from crossword.category_logic import category_doc, parse_category
from crossword.collections import CROSSWORD_CATEGORIES
from crossword.types import CrosswordCategory, Timestamp
from firestore_client import db, run_transaction
from utils.callable_errors import callable_errors


def save_category(
    client: Client, admin_uid: str, data: object, *, now: Timestamp = firestore.SERVER_TIMESTAMP
) -> dict[str, object]:
    """Create or update a category, keyed by its slug.

    Returns:
        `{"id": slug, "created": bool}`.

    Raises:
        InputError: Invalid data.
    """
    category = parse_category(data)
    ref = client.collection(CROSSWORD_CATEGORIES).document(category["id"])

    def body(transaction: Transaction) -> bool:
        snapshot = ref.get(transaction=transaction)
        existing = cast(CrosswordCategory, snapshot.to_dict()) if snapshot.exists else None
        transaction.set(
            ref, category_doc(category, admin_uid=admin_uid, existing=existing, now=now)
        )
        return existing is None

    created = run_transaction(client, body)
    return {"id": category["id"], "created": created}


@https_fn.on_call()
def adminSaveCategory(req: https_fn.CallableRequest[Any]) -> dict[str, object]:  # noqa: N802
    """Admin: create or edit a crossword category (CW-015)."""
    admin_uid = assert_admin(req)
    with callable_errors():
        result = save_category(db(), admin_uid, req.data)
    write_audit_log(
        action="crossword.saveCategory",
        admin_uid=admin_uid,
        target_id=str(result["id"]),
        payload={"created": result["created"]},
    )
    return result
