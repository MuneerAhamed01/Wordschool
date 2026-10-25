from typing import Any, cast

from firebase_admin import firestore
from firebase_functions import https_fn
from google.cloud.firestore import Client, Transaction

from admin.assert_admin import assert_admin
from admin.audit_log import write_audit_log
from crossword.category_logic import category_doc
from crossword.collections import CROSSWORD_CATEGORIES, PSC_QUESTIONS
from crossword.errors import NotFoundError
from crossword.question_logic import (
    auto_category,
    category_id_for_subject,
    parse_question,
    parse_question_id,
    question_doc,
    verify_updates,
)
from crossword.types import PscQuestion, Timestamp
from firestore_client import db, run_transaction
from utils.callable_errors import callable_errors


def save_question(
    client: Client, admin_uid: str, data: object, *, now: Timestamp = firestore.SERVER_TIMESTAMP
) -> dict[str, object]:
    """Create a question (no `id`) or replace an existing one; the result is a draft.

    In the same transaction, creates the question's category (hidden) when no category
    matches its subject (CW-064). An existing category is never changed.

    Returns:
        `{"id", "created", "status", "createdCategoryId"}` (`createdCategoryId` is `None`
        unless a category was created).

    Raises:
        InputError: Invalid data.
        NotFoundError: `id` given but no such question.
        PreconditionError: The question is retired.
    """
    question = parse_question(data)
    questions = client.collection(PSC_QUESTIONS)
    ref = questions.document(question["id"]) if "id" in question else questions.document()
    category_ref = client.collection(CROSSWORD_CATEGORIES).document(
        category_id_for_subject(question["subject"])
    )

    def body(transaction: Transaction) -> tuple[bool, bool]:
        existing: PscQuestion | None = None
        if "id" in question:
            snapshot = ref.get(transaction=transaction)
            if not snapshot.exists:
                raise NotFoundError(f"Question {ref.id} not found")
            existing = cast(PscQuestion, snapshot.to_dict())
        category_missing = not category_ref.get(transaction=transaction).exists
        doc = question_doc(question, admin_uid=admin_uid, existing=existing, now=now)
        transaction.set(ref, doc)
        if category_missing:
            category = auto_category(question["subject"])
            transaction.set(
                category_ref, category_doc(category, admin_uid=admin_uid, existing=None, now=now)
            )
        return existing is None, category_missing

    created, category_created = run_transaction(client, body)
    return {
        "id": ref.id,
        "created": created,
        "status": "draft",
        "createdCategoryId": category_ref.id if category_created else None,
    }


def verify_question(
    client: Client, admin_uid: str, data: object, *, now: Timestamp = firestore.SERVER_TIMESTAMP
) -> dict[str, object]:
    """Mark a draft question verified (idempotent).

    Returns:
        `{"id", "status": "verified", "changed"}`.

    Raises:
        InputError: Bad id, or the source is a placeholder.
        NotFoundError: No such question.
        PreconditionError: The question is retired.
    """
    question_id = parse_question_id(data)
    ref = client.collection(PSC_QUESTIONS).document(question_id)

    def body(transaction: Transaction) -> bool:
        snapshot = ref.get(transaction=transaction)
        if not snapshot.exists:
            raise NotFoundError(f"Question {question_id} not found")
        updates = verify_updates(
            cast(PscQuestion, snapshot.to_dict()), admin_uid=admin_uid, now=now
        )
        if updates is not None:
            transaction.update(ref, updates)
        return updates is not None

    changed = run_transaction(client, body)
    return {"id": question_id, "status": "verified", "changed": changed}


@https_fn.on_call()
def adminSaveQuestion(req: https_fn.CallableRequest[Any]) -> dict[str, object]:  # noqa: N802
    """Admin: create or edit a PSC question; edits reset it to `draft` (CW-016)."""
    admin_uid = assert_admin(req)
    with callable_errors():
        result = save_question(db(), admin_uid, req.data)
    write_audit_log(
        action="crossword.saveQuestion",
        admin_uid=admin_uid,
        target_id=str(result["id"]),
        payload={"created": result["created"]},
    )
    category_id = result["createdCategoryId"]
    if category_id is not None:
        write_audit_log(
            action="crossword.autoCreateCategory",
            admin_uid=admin_uid,
            target_id=str(category_id),
            # Subjects are snake_case without hyphens, so this is exact.
            payload={"subject": str(category_id).replace("-", "_"), "questionId": result["id"]},
        )
    return result


@https_fn.on_call()
def adminVerifyQuestion(req: https_fn.CallableRequest[Any]) -> dict[str, object]:  # noqa: N802
    """Admin: mark a question verified so it can go into puzzles (CW-016)."""
    admin_uid = assert_admin(req)
    with callable_errors():
        result = verify_question(db(), admin_uid, req.data)
    if result["changed"]:
        write_audit_log(
            action="crossword.verifyQuestion", admin_uid=admin_uid, target_id=str(result["id"])
        )
    return result
