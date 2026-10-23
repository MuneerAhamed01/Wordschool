"""Pure logic for `adminListReports` and `adminResolveReport` (CW-022)."""

import re
from datetime import datetime
from typing import NotRequired, TypedDict

from crossword.errors import PreconditionError
from crossword.input_reader import InputReader
from crossword.question_logic import DOC_ID_RE
from crossword.types import REPORT_STATUSES, ContentReport, ReportStatus

DEFAULT_PAGE_SIZE = 20
MAX_PAGE_SIZE = 100
RESOLVED_STATUSES: tuple[ReportStatus, ...] = ("fixed", "rejected")
_REPORT_ID_RE = re.compile(r"[A-Za-z0-9_-]{1,100}")


class ListInput(TypedDict):
    """Validated `adminListReports` input."""

    status: ReportStatus
    limit: int
    startAfterId: NotRequired[str]


class ResolveInput(TypedDict):
    """Validated `adminResolveReport` input."""

    reportId: str
    status: ReportStatus
    note: NotRequired[str]


def parse_list(data: object) -> ListInput:
    """Validate `{status?, limit?, startAfterId?}` (defaults: `open`, 20).

    Raises:
        InputError: Listing every problem.
    """
    reader = InputReader(data if data is not None else {})
    status = reader.choice("status", REPORT_STATUSES, required=False) or "open"
    limit = reader.integer("limit", required=False, minimum=1, maximum=MAX_PAGE_SIZE)
    start_after = reader.string("startAfterId", required=False, pattern=DOC_ID_RE)
    reader.raise_if_problems()
    request: ListInput = {"status": status, "limit": limit or DEFAULT_PAGE_SIZE}
    if start_after:
        request["startAfterId"] = start_after
    return request


def parse_resolve(data: object) -> ResolveInput:
    """Validate `{reportId, status: fixed|rejected, note?}`.

    Raises:
        InputError: Listing every problem.
    """
    reader = InputReader(data)
    report_id = reader.string("reportId", pattern=_REPORT_ID_RE)
    status = reader.choice("status", RESOLVED_STATUSES)
    note = reader.string("note", required=False, max_length=500)
    reader.raise_if_problems()
    assert report_id and status
    request: ResolveInput = {"reportId": report_id, "status": status}
    if note:
        request["note"] = note
    return request


def resolve_updates(
    report: ContentReport, request: ResolveInput, *, admin_uid: str, now: datetime
) -> dict[str, object]:
    """Fields that close an open report.

    Raises:
        PreconditionError: The report is already resolved.
    """
    if report["status"] != "open":
        raise PreconditionError(f"Report is already {report['status']}")
    updates: dict[str, object] = {
        "status": request["status"],
        "resolvedBy": admin_uid,
        "resolvedAt": now,
    }
    if "note" in request:
        updates["resolutionNote"] = request["note"]
    return updates


def report_json(report_id: str, report: ContentReport) -> dict[str, object]:
    """A report as JSON for the admin panel (timestamps as ISO 8601 strings)."""
    result: dict[str, object] = {"id": report_id}
    for key, value in report.items():
        result[key] = value.isoformat() if isinstance(value, datetime) else value
    return result
