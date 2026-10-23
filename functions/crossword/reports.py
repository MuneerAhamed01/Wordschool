from datetime import UTC, datetime
from typing import Any, cast

from firebase_functions import https_fn
from google.cloud.firestore import Client, FieldFilter, Query, Transaction

from admin.assert_admin import assert_admin
from admin.audit_log import write_audit_log
from crossword.collections import CONTENT_REPORTS
from crossword.errors import NotFoundError
from crossword.report_logic import parse_list, parse_resolve, report_json, resolve_updates
from crossword.types import ContentReport
from firestore_client import db, run_transaction
from utils.callable_errors import callable_errors


def list_reports(client: Client, data: object) -> dict[str, object]:
    """One page of reports with a status, newest first.

    Returns:
        `{"reports": [...], "nextStartAfterId": id | None}`.

    Raises:
        InputError: Invalid data.
        NotFoundError: `startAfterId` does not exist.
    """
    request = parse_list(data)
    collection = client.collection(CONTENT_REPORTS)
    query = (
        collection.where(filter=FieldFilter("status", "==", request["status"]))
        .order_by("createdAt", direction=Query.DESCENDING)
        .limit(request["limit"])
    )
    if "startAfterId" in request:
        cursor = collection.document(request["startAfterId"]).get()
        if not cursor.exists:
            raise NotFoundError(f"Report {request['startAfterId']} not found")
        query = query.start_after(cursor)
    snapshots = list(query.stream())
    reports = [report_json(s.id, cast(ContentReport, s.to_dict())) for s in snapshots]
    full_page = len(snapshots) == request["limit"]
    return {"reports": reports, "nextStartAfterId": snapshots[-1].id if full_page else None}


def resolve_report(
    client: Client, admin_uid: str, data: object, *, now: datetime | None = None
) -> dict[str, object]:
    """Mark an open report `fixed` or `rejected`.

    Returns:
        `{"id", "status"}`.

    Raises:
        InputError: Invalid data.
        NotFoundError: No such report.
        PreconditionError: Already resolved.
    """
    request = parse_resolve(data)
    at = now or datetime.now(UTC)
    ref = client.collection(CONTENT_REPORTS).document(request["reportId"])

    def body(transaction: Transaction) -> None:
        snapshot = ref.get(transaction=transaction)
        if not snapshot.exists:
            raise NotFoundError(f"Report {request['reportId']} not found")
        report = cast(ContentReport, snapshot.to_dict())
        transaction.update(ref, resolve_updates(report, request, admin_uid=admin_uid, now=at))

    run_transaction(client, body)
    return {"id": request["reportId"], "status": request["status"]}


@https_fn.on_call()
def adminListReports(req: https_fn.CallableRequest[Any]) -> dict[str, object]:  # noqa: N802
    """Admin: page through player reports by status (CW-022)."""
    assert_admin(req)
    with callable_errors():
        return list_reports(db(), req.data)


@https_fn.on_call()
def adminResolveReport(req: https_fn.CallableRequest[Any]) -> dict[str, object]:  # noqa: N802
    """Admin: close a player report as fixed or rejected (CW-022)."""
    admin_uid = assert_admin(req)
    with callable_errors():
        result = resolve_report(db(), admin_uid, req.data)
    write_audit_log(
        action="crossword.resolveReport",
        admin_uid=admin_uid,
        target_id=str(result["id"]),
        payload={"status": result["status"]},
    )
    return result
