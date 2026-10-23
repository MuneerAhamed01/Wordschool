"""Emulator tests (skipped without FIRESTORE_EMULATOR_HOST)."""

import inspect
from datetime import UTC, datetime, timedelta

import pytest
from firebase_functions import https_fn

from conftest import callable_request
from crossword.collections import ADMIN_AUDIT_LOG, CONTENT_REPORTS
from crossword.errors import PreconditionError
from crossword.reports import adminListReports, adminResolveReport, list_reports, resolve_report

NOW = datetime(2026, 10, 23, tzinfo=UTC)


def _seed(db, count):
    for i in range(count):
        db.collection(CONTENT_REPORTS).document(f"r{i:02d}").set(
            {
                "uid": "alice",
                "puzzleId": "kerala-history-0001",
                "wordId": "2D",
                "questionId": "q-vaikom",
                "reason": "wrong_answer",
                "message": f"report {i}",
                "status": "open",
                "createdAt": NOW + timedelta(minutes=i),
            }
        )


def test_pages_newest_first(emulator_db):
    _seed(emulator_db, 5)
    first = list_reports(emulator_db, {"limit": 2})
    assert [r["id"] for r in first["reports"]] == ["r04", "r03"]
    assert first["reports"][0]["createdAt"].startswith("2026-10-23T00:04")
    second = list_reports(emulator_db, {"limit": 2, "startAfterId": first["nextStartAfterId"]})
    assert [r["id"] for r in second["reports"]] == ["r02", "r01"]
    last = list_reports(emulator_db, {"limit": 2, "startAfterId": second["nextStartAfterId"]})
    assert [r["id"] for r in last["reports"]] == ["r00"]
    assert last["nextStartAfterId"] is None


def test_resolve_then_listed_under_new_status(emulator_db):
    _seed(emulator_db, 2)
    assert resolve_report(emulator_db, "admin1", {"reportId": "r01", "status": "fixed"}) == {
        "id": "r01",
        "status": "fixed",
    }
    assert [r["id"] for r in list_reports(emulator_db, {"status": "fixed"})["reports"]] == ["r01"]
    assert [r["id"] for r in list_reports(emulator_db, {})["reports"]] == ["r00"]
    with pytest.raises(PreconditionError):
        resolve_report(emulator_db, "admin1", {"reportId": "r01", "status": "rejected"})


def test_audit_log_written_on_resolve(emulator_db):
    _seed(emulator_db, 1)
    request = callable_request({"reportId": "r00", "status": "rejected", "note": "Correct"})

    assert inspect.unwrap(adminResolveReport)(request) == {"id": "r00", "status": "rejected"}

    logs = [doc.to_dict() for doc in emulator_db.collection(ADMIN_AUDIT_LOG).stream()]
    assert len(logs) == 1
    assert logs[0]["action"] == "crossword.resolveReport"
    assert logs[0]["adminUid"] == "admin1"
    assert logs[0]["targetId"] == "r00"


def test_list_requires_admin(emulator_db):
    with pytest.raises(https_fn.HttpsError):
        inspect.unwrap(adminListReports)(callable_request({}, admin=False))
