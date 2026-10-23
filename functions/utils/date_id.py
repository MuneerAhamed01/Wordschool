import re
from datetime import UTC, date, datetime, timedelta, timezone

# Asia/Kolkata is UTC+05:30 all year (no daylight saving).
IST = timezone(timedelta(hours=5, minutes=30), "IST")

_DATE_ID = re.compile(r"[0-9]{4}-[0-9]{2}-[0-9]{2}")


def to_ist(now: datetime | None = None) -> datetime:
    """Convert an aware datetime (default: now) to IST.

    Raises:
        ValueError: If `now` has no timezone.
    """
    if now is None:
        now = datetime.now(UTC)
    if now.tzinfo is None:
        raise ValueError("now must be timezone-aware")
    return now.astimezone(IST)


def today_ist_date_id(now: datetime | None = None) -> str:
    """Daily key `YYYY-MM-DD` for the calendar day in India (DEC-001)."""
    return to_ist(now).strftime("%Y-%m-%d")


def is_valid_date_id(value: str) -> bool:
    """True when `value` is `YYYY-MM-DD` and a real calendar date."""
    if not _DATE_ID.fullmatch(value):
        return False
    try:
        date.fromisoformat(value)
    except ValueError:
        return False
    return True


def add_days(date_id: str, days: int) -> str:
    """`add_days("2026-10-31", 1)` → `"2026-11-01"`."""
    return (date.fromisoformat(date_id) + timedelta(days=days)).isoformat()
