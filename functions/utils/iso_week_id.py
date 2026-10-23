from datetime import date, datetime

from utils.date_id import to_ist


def iso_week_id(day: date) -> str:
    """ISO 8601 week id `YYYY-Www` (Monday to Sunday) for a calendar day."""
    year, week, _ = day.isocalendar()
    return f"{year}-W{week:02d}"


def ist_iso_week_id(now: datetime | None = None) -> str:
    """ISO week id of the current day in India.

    Weekly leaderboards roll over at Monday 00:00 IST, like the daily keys (DEC-001).
    """
    return iso_week_id(to_ist(now).date())
