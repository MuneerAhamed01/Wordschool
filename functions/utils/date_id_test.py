from datetime import datetime

import pytest

from utils.date_id import is_valid_date_id, today_ist_date_id


@pytest.mark.parametrize(
    ("utc", "expected"),
    [
        ("2026-10-23T18:30:00+00:00", "2026-10-24"),  # 00:00 IST
        ("2026-10-23T18:29:59+00:00", "2026-10-23"),  # 23:59:59 IST
        ("2026-12-31T18:30:00+00:00", "2027-01-01"),  # new year in India
    ],
)
def test_today_ist_date_id(utc, expected):
    assert today_ist_date_id(datetime.fromisoformat(utc)) == expected


def test_today_ist_date_id_rejects_naive_datetimes():
    with pytest.raises(ValueError):
        today_ist_date_id(datetime(2026, 10, 23, 12))


@pytest.mark.parametrize("value", ["2026-10-23", "2028-02-29", "2026-12-31"])
def test_accepts_real_dates(value):
    assert is_valid_date_id(value)


@pytest.mark.parametrize(
    "value",
    [
        "2026-02-30",
        "2027-02-29",
        "2026-13-01",
        "2026-00-10",
        "2026-1-5",
        "26-10-23",
        "2026-10-23T00:00",
        "20261023",
        "２０２６-10-23",
        "",
    ],
)
def test_rejects_invalid_date_ids(value):
    assert not is_valid_date_id(value)
