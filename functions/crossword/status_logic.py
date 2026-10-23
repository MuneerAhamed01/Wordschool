"""Pure logic for `adminSetPuzzleStatus`, `adminScheduleDaily` and the daily rollover (CW-018)."""

from datetime import date, datetime, time
from typing import NotRequired, TypedDict

from crossword.errors import InputError, PreconditionError
from crossword.input_reader import InputReader
from crossword.puzzle_logic import PUZZLE_ID_RE
from crossword.types import (
    PUZZLE_STATUSES,
    SCHEMA_VERSION,
    CrosswordDaily,
    CrosswordPuzzle,
    PuzzleStatus,
)
from utils.date_id import IST, is_valid_date_id, to_ist

# draft → in_review → scheduled → published → archived, plus in_review → draft,
# in_review → published (publish now) and scheduled → scheduled (change publishAt).
TRANSITIONS: dict[PuzzleStatus, tuple[PuzzleStatus, ...]] = {
    "draft": ("in_review",),
    "in_review": ("draft", "scheduled", "published"),
    "scheduled": ("scheduled", "published"),
    "published": ("archived",),
    "archived": (),
}
DAILY_STATUSES: tuple[PuzzleStatus, ...] = ("scheduled", "published")


class StatusInput(TypedDict):
    """Validated `adminSetPuzzleStatus` input."""

    puzzleId: str
    status: PuzzleStatus
    publishAt: NotRequired[datetime]


class StatusChange(TypedDict):
    """Fields to update on the puzzle, and how `publishedPuzzleCount` changes."""

    updates: dict[str, object]
    countDelta: int


class DailyInput(TypedDict):
    """Validated `adminScheduleDaily` input."""

    dateId: str
    puzzleId: str


def parse_status(data: object) -> StatusInput:
    """Validate `{puzzleId, status, publishAt?}`; `publishAt` is ISO 8601 with a timezone.

    Raises:
        InputError: Listing every problem.
    """
    reader = InputReader(data)
    puzzle_id = reader.string("puzzleId", pattern=PUZZLE_ID_RE, max_length=70)
    status = reader.choice("status", PUZZLE_STATUSES)
    raw_publish_at = reader.string("publishAt", required=status == "scheduled", max_length=40)
    publish_at: datetime | None = None
    if raw_publish_at is not None:
        if status != "scheduled":
            reader.problem("publishAt is only allowed with status scheduled")
        else:
            try:
                publish_at = datetime.fromisoformat(raw_publish_at)
            except ValueError:
                reader.problem(f"publishAt {raw_publish_at!r} is not an ISO 8601 date-time")
            else:
                if publish_at.tzinfo is None:
                    reader.problem("publishAt needs a timezone, e.g. 2026-11-01T00:00:00+05:30")
                    publish_at = None
    reader.raise_if_problems()
    assert puzzle_id and status
    result: StatusInput = {"puzzleId": puzzle_id, "status": status}
    if publish_at is not None:
        result["publishAt"] = publish_at
    return result


def status_change(
    current: PuzzleStatus,
    request: StatusInput,
    *,
    admin_uid: str,
    now: datetime,
) -> StatusChange:
    """Check the transition and work out the writes.

    Raises:
        PreconditionError: The transition is not allowed.
        InputError: `publishAt` is not in the future.
    """
    target = request["status"]
    allowed = TRANSITIONS[current]
    if target not in allowed:
        options = ", ".join(allowed) or "nothing (archived is final)"
        raise PreconditionError(
            f"Can't move a puzzle from {current} to {target}; allowed: {options}"
        )
    updates: dict[str, object] = {"status": target, "updatedAt": now, "updatedBy": admin_uid}
    delta = 0
    if target == "scheduled":
        publish_at = request["publishAt"]
        if publish_at <= now:
            raise InputError(["publishAt must be in the future"])
        updates["publishAt"] = publish_at
    elif target == "published":
        updates.update(publish_updates(now))
        delta = 1
    elif target == "archived":
        delta = -1
    return {"updates": updates, "countDelta": delta}


def publish_updates(now: datetime) -> dict[str, object]:
    """Puzzle fields set when it goes live (by an admin or the rollover)."""
    return {"status": "published", "publishedAt": now, "updatedAt": now}


def is_due(puzzle: CrosswordPuzzle, now: datetime) -> bool:
    """True for a scheduled puzzle whose `publishAt` has passed."""
    publish_at = puzzle.get("publishAt")
    return (
        puzzle["status"] == "scheduled" and isinstance(publish_at, datetime) and publish_at <= now
    )


def select_due(puzzles: dict[str, CrosswordPuzzle], now: datetime) -> list[str]:
    """Ids of the puzzles the rollover should publish, oldest `publishAt` first."""
    due = [(pid, puzzle) for pid, puzzle in puzzles.items() if is_due(puzzle, now)]
    due.sort(key=lambda item: (item[1].get("publishAt"), item[0]))
    return [pid for pid, _ in due]


def parse_daily(data: object) -> DailyInput:
    """Validate `{dateId, puzzleId}`.

    Raises:
        InputError: Listing every problem.
    """
    reader = InputReader(data)
    date_id = reader.string("dateId", max_length=10)
    if date_id is not None and not is_valid_date_id(date_id):
        reader.problem(f"dateId {date_id!r} must be a real date as YYYY-MM-DD")
    puzzle_id = reader.string("puzzleId", pattern=PUZZLE_ID_RE, max_length=70)
    reader.raise_if_problems()
    assert date_id and puzzle_id
    return {"dateId": date_id, "puzzleId": puzzle_id}


def start_of_ist_day(date_id: str) -> datetime:
    """00:00 in India on `date_id`."""
    return datetime.combine(date.fromisoformat(date_id), time(0, 0), tzinfo=IST)


def daily_doc(
    request: DailyInput, puzzle: CrosswordPuzzle, *, admin_uid: str, now: datetime
) -> CrosswordDaily:
    """The `crosswordDaily/{dateId}` doc, after checking the puzzle can be the daily one.

    Raises:
        InputError: The date is in the past (IST).
        PreconditionError: The puzzle is not scheduled/published, or goes live too late.
    """
    if request["dateId"] < to_ist(now).strftime("%Y-%m-%d"):
        raise InputError([f"{request['dateId']} is in the past (IST)"])
    if puzzle["status"] not in DAILY_STATUSES:
        raise PreconditionError(
            f"Puzzle is {puzzle['status']}; only scheduled or published puzzles can be daily"
        )
    publish_at = puzzle.get("publishAt")
    day_start = start_of_ist_day(request["dateId"])
    if puzzle["status"] == "scheduled" and (
        not isinstance(publish_at, datetime) or publish_at > day_start
    ):
        raise PreconditionError(
            f"Puzzle goes live after {request['dateId']} starts — set publishAt to "
            f"{day_start.isoformat()} or earlier"
        )
    return {
        "puzzleId": request["puzzleId"],
        "categoryId": puzzle["categoryId"],
        "title": puzzle["title"],
        "difficulty": puzzle["difficulty"],
        "wordCount": puzzle.get("wordCount", len(puzzle["words"])),
        "xpReward": puzzle["xpReward"],
        "estimatedMinutes": puzzle["estimatedMinutes"],
        "schemaVersion": SCHEMA_VERSION,
        "updatedAt": now,
        "updatedBy": admin_uid,
    }
