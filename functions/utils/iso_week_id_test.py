from datetime import date, datetime

import pytest

from utils.iso_week_id import iso_week_id, ist_iso_week_id


@pytest.mark.parametrize(
    ("day", "expected"),
    [
        (date(2026, 10, 23), "2026-W43"),
        (date(2026, 1, 1), "2026-W01"),
        (date(2027, 1, 1), "2026-W53"),
        (date(2024, 12, 30), "2025-W01"),
        (date(2026, 10, 19), "2026-W43"),  # Monday
        (date(2026, 10, 18), "2026-W42"),  # Sunday
    ],
)
def test_iso_week_id(day, expected):
    assert iso_week_id(day) == expected


def test_new_week_starts_at_monday_midnight_ist():
    # Sunday 18:30 UTC = Monday 00:00 IST.
    assert ist_iso_week_id(datetime.fromisoformat("2026-10-25T18:30:00+00:00")) == "2026-W44"


def test_keeps_old_week_until_monday_midnight_ist():
    assert ist_iso_week_id(datetime.fromisoformat("2026-10-25T18:29:59+00:00")) == "2026-W43"
