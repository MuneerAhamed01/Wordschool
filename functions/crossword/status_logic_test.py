from datetime import UTC, datetime, timedelta
from itertools import product

import pytest

from crossword.errors import InputError, PreconditionError
from crossword.status_logic import (
    daily_doc,
    parse_daily,
    parse_status,
    select_due,
    status_change,
)
from crossword.types import PUZZLE_STATUSES

NOW = datetime(2026, 10, 23, 6, 30, tzinfo=UTC)  # 12:00 IST
LATER = "2026-11-01T00:00:00+05:30"

ALLOWED = {
    ("draft", "in_review"),
    ("in_review", "draft"),
    ("in_review", "scheduled"),
    ("in_review", "published"),
    ("scheduled", "scheduled"),
    ("scheduled", "published"),
    ("published", "archived"),
}


def _request(status):
    data = {"puzzleId": "kerala-history-0012", "status": status}
    if status == "scheduled":
        data["publishAt"] = LATER
    return parse_status(data)


@pytest.mark.parametrize(("current", "target"), sorted(ALLOWED))
def test_allowed_transitions(current, target):
    change = status_change(current, _request(target), admin_uid="admin1", now=NOW)
    assert change["updates"]["status"] == target
    assert change["updates"]["updatedBy"] == "admin1"


REFUSED = sorted(set(product(PUZZLE_STATUSES, repeat=2)) - ALLOWED)


@pytest.mark.parametrize(("current", "target"), REFUSED)
def test_refused_transitions(current, target):
    with pytest.raises(PreconditionError) as error:
        status_change(current, _request(target), admin_uid="admin1", now=NOW)
    assert f"from {current} to {target}" in str(error.value)


def test_every_pair_is_covered():
    assert len(ALLOWED) + len(REFUSED) == 25


def test_publish_sets_published_at_and_counts():
    change = status_change("in_review", _request("published"), admin_uid="a", now=NOW)
    assert change["updates"]["publishedAt"] == NOW
    assert change["countDelta"] == 1


def test_archive_decrements_count():
    assert (
        status_change("published", _request("archived"), admin_uid="a", now=NOW)["countDelta"] == -1
    )


def test_schedule_sets_publish_at():
    change = status_change("in_review", _request("scheduled"), admin_uid="a", now=NOW)
    assert change["updates"]["publishAt"] == datetime.fromisoformat(LATER)
    assert change["countDelta"] == 0


def test_schedule_in_the_past_refused():
    request = parse_status(
        {"puzzleId": "kerala-history-0012", "status": "scheduled", "publishAt": "2026-10-01T00:00Z"}
    )
    with pytest.raises(InputError):
        status_change("in_review", request, admin_uid="a", now=NOW)


@pytest.mark.parametrize(
    ("data", "problem"),
    [
        ({"puzzleId": "kerala-history-0012", "status": "scheduled"}, "publishAt is required"),
        (
            {"puzzleId": "kerala-history-0012", "status": "published", "publishAt": LATER},
            "publishAt is only allowed with status scheduled",
        ),
        (
            {"puzzleId": "kerala-history-0012", "status": "scheduled", "publishAt": "tomorrow"},
            "publishAt 'tomorrow' is not an ISO 8601 date-time",
        ),
        (
            {"puzzleId": "kerala-history-0012", "status": "scheduled", "publishAt": "2026-11-01"},
            "publishAt needs a timezone, e.g. 2026-11-01T00:00:00+05:30",
        ),
        ({"puzzleId": "kerala-history", "status": "draft"}, "puzzleId 'kerala-history' must"),
        ({"puzzleId": "kerala-history-0012", "status": "live"}, "status must be one of"),
    ],
)
def test_parse_status_problems(data, problem):
    with pytest.raises(InputError) as error:
        parse_status(data)
    assert error.value.problems[0].startswith(problem)


def _puzzle(status, publish_at=None):
    puzzle = {
        "status": status,
        "categoryId": "kerala-history",
        "title": {"en": "Kerala Renaissance"},
        "difficulty": "medium",
        "words": [{}] * 7,
        "wordCount": 7,
        "xpReward": 50,
        "estimatedMinutes": 6,
    }
    if publish_at is not None:
        puzzle["publishAt"] = publish_at
    return puzzle


def test_select_due_oldest_first():
    puzzles = {
        "a": _puzzle("scheduled", NOW - timedelta(minutes=1)),
        "b": _puzzle("scheduled", NOW - timedelta(days=1)),
        "c": _puzzle("scheduled", NOW + timedelta(minutes=1)),
        "d": _puzzle("published", NOW - timedelta(days=2)),
        "e": _puzzle("scheduled", NOW),
        "f": _puzzle("scheduled"),
    }
    assert select_due(puzzles, NOW) == ["b", "a", "e"]


DAILY = {"dateId": "2026-10-24", "puzzleId": "kerala-history-0012"}


def test_daily_doc_for_published_puzzle():
    doc = daily_doc(DAILY, _puzzle("published"), admin_uid="admin1", now=NOW)
    assert doc["puzzleId"] == "kerala-history-0012"
    assert doc["wordCount"] == 7
    assert doc["xpReward"] == 50


def test_daily_accepts_puzzle_live_by_midnight_ist():
    midnight = datetime.fromisoformat("2026-10-24T00:00:00+05:30")
    daily_doc(DAILY, _puzzle("scheduled", midnight), admin_uid="a", now=NOW)
    with pytest.raises(PreconditionError):
        daily_doc(
            DAILY, _puzzle("scheduled", midnight + timedelta(seconds=1)), admin_uid="a", now=NOW
        )


@pytest.mark.parametrize("status", ["draft", "in_review", "archived"])
def test_daily_refuses_puzzles_not_going_live(status):
    with pytest.raises(PreconditionError):
        daily_doc(DAILY, _puzzle(status), admin_uid="a", now=NOW)


def test_daily_refuses_past_dates_but_allows_today_ist():
    daily_doc({**DAILY, "dateId": "2026-10-23"}, _puzzle("published"), admin_uid="a", now=NOW)
    with pytest.raises(InputError):
        daily_doc({**DAILY, "dateId": "2026-10-22"}, _puzzle("published"), admin_uid="a", now=NOW)


def test_parse_daily_rejects_bad_dates():
    with pytest.raises(InputError) as error:
        parse_daily({"dateId": "2026-02-30", "puzzleId": "kerala-history-0012"})
    assert error.value.problems == ["dateId '2026-02-30' must be a real date as YYYY-MM-DD"]
