from datetime import UTC, datetime

import pytest

from crossword.errors import InputError, PreconditionError
from crossword.report_logic import parse_list, parse_resolve, report_json, resolve_updates

NOW = datetime(2026, 10, 23, tzinfo=UTC)


def test_list_defaults():
    assert parse_list(None) == {"status": "open", "limit": 20}
    assert parse_list({"status": "fixed", "limit": 5, "startAfterId": "r1"}) == {
        "status": "fixed",
        "limit": 5,
        "startAfterId": "r1",
    }


def test_list_rejects_bad_limit_and_status():
    with pytest.raises(InputError) as error:
        parse_list({"status": "closed", "limit": 1000})
    assert len(error.value.problems) == 2


def test_resolve_only_to_fixed_or_rejected():
    assert parse_resolve({"reportId": "r1", "status": "fixed", "note": "Answer corrected"}) == {
        "reportId": "r1",
        "status": "fixed",
        "note": "Answer corrected",
    }
    with pytest.raises(InputError):
        parse_resolve({"reportId": "r1", "status": "open"})


def test_resolve_updates():
    updates = resolve_updates(
        {"status": "open"},
        {"reportId": "r1", "status": "rejected", "note": "Answer is right"},
        admin_uid="admin1",
        now=NOW,
    )
    assert updates == {
        "status": "rejected",
        "resolvedBy": "admin1",
        "resolvedAt": NOW,
        "resolutionNote": "Answer is right",
    }


def test_already_resolved_refused():
    with pytest.raises(PreconditionError):
        resolve_updates(
            {"status": "fixed"}, {"reportId": "r1", "status": "rejected"}, admin_uid="a", now=NOW
        )


def test_report_json_serializes_timestamps():
    assert report_json("r1", {"status": "open", "createdAt": NOW}) == {
        "id": "r1",
        "status": "open",
        "createdAt": "2026-10-23T00:00:00+00:00",
    }
