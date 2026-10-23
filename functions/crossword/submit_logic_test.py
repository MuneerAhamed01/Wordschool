from datetime import UTC, datetime, timedelta

import pytest

from crossword.errors import InputError, RateLimitError
from crossword.puzzle_logic import parse_puzzle, puzzle_doc, solution_doc
from crossword.submit_logic import (
    completed_progress,
    merge_with_progress,
    next_rate_limit,
    next_stats,
    parse_submit,
    revision_fields,
    score_puzzle,
    typed_word,
)
from crossword.validate_puzzle import word_cells

NOW = datetime(2026, 10, 23, 6, 30, tzinfo=UTC)
PID = "kerala-history-0012"


@pytest.fixture
def puzzle_and_answers(example_puzzle_input, example_questions):
    parsed = parse_puzzle(example_puzzle_input)
    puzzle = puzzle_doc(
        parsed,
        puzzle_id=PID,
        number=12,
        questions=example_questions,
        admin_uid="a",
        existing=None,
        now=NOW,
    )
    return puzzle, solution_doc(parsed, now=NOW)["answers"], parsed


def _letters(parsed, overrides=None):
    cells = list(parsed["layout"])
    for word in parsed["words"]:
        answer = (overrides or {}).get(word["id"], word["answer"])
        for (r, c), letter in zip(word_cells(word), answer, strict=True):
            cells[r * parsed["cols"] + c] = letter
    return "".join(cells)


def _submit(letters, *, elapsed=120, letter=0, word=0, revealed=None):
    return parse_submit(
        {
            "puzzleId": PID,
            "letters": letters,
            "elapsedSec": elapsed,
            "hintsUsed": {"letter": letter, "word": word, "clue": 1},
            "revealedWordIds": revealed or [],
        }
    )


def test_perfect_score(puzzle_and_answers):
    puzzle, answers, parsed = puzzle_and_answers
    result = score_puzzle(puzzle, answers, _submit(_letters(parsed)))
    assert result == {
        "score": 100,
        "correctWords": 7,
        "totalWords": 7,
        "xpEarned": 50,
        "timeSec": 120,
        "wrongWordIds": [],
        "revealedWordIds": [],
    }


def test_wrong_word_scores_and_scales_xp(puzzle_and_answers):
    puzzle, answers, parsed = puzzle_and_answers
    # VAIKAM: the typo is in 2D only (row 6 is not crossed by an across word).
    letters = _letters(parsed, {"2D": "VAIKAM"})
    assert typed_word(letters, puzzle["cols"], puzzle["words"][2]) == "VAIKAM"
    result = score_puzzle(puzzle, answers, _submit(letters))
    assert result["wrongWordIds"] == ["2D"]
    assert result["correctWords"] == 6
    assert result["score"] == 86
    assert result["xpEarned"] == 43  # round(50 * 6/7)


def test_empty_grid_earns_nothing(puzzle_and_answers):
    puzzle, answers, parsed = puzzle_and_answers
    result = score_puzzle(puzzle, answers, _submit(parsed["layout"]))
    assert result["correctWords"] == 0
    assert result["xpEarned"] == 0
    assert result["score"] == 0


def test_penalties_and_revealed_words_count_as_wrong(puzzle_and_answers):
    puzzle, answers, parsed = puzzle_and_answers
    result = score_puzzle(
        puzzle, answers, _submit(_letters(parsed), letter=1, word=1, revealed=["3D", "9A"])
    )
    assert result["revealedWordIds"] == ["3D"]
    assert result["wrongWordIds"] == ["3D"]
    assert result["xpEarned"] == 43 - 5 - 15


def test_penalties_come_from_remote_config(puzzle_and_answers):
    puzzle, answers, parsed = puzzle_and_answers
    submit = _submit(_letters(parsed), letter=2, word=1)
    assert score_puzzle(puzzle, answers, submit)["xpEarned"] == 50 - 10 - 15
    changed = score_puzzle(puzzle, answers, submit, {"letter": 1, "word": 20})
    assert changed["xpEarned"] == 50 - 2 - 20


def test_xp_floor_is_zero(puzzle_and_answers):
    puzzle, answers, parsed = puzzle_and_answers
    result = score_puzzle(puzzle, answers, _submit(_letters(parsed), word=10))
    assert result["xpEarned"] == 0


def test_rejects_implausible_time(puzzle_and_answers):
    puzzle, answers, parsed = puzzle_and_answers
    score_puzzle(puzzle, answers, _submit(_letters(parsed), elapsed=14))
    with pytest.raises(InputError) as error:
        score_puzzle(puzzle, answers, _submit(_letters(parsed), elapsed=13))
    assert error.value.problems == ["elapsedSec is too short for this puzzle"]


def test_rejects_letters_of_the_wrong_size(puzzle_and_answers):
    puzzle, answers, parsed = puzzle_and_answers
    with pytest.raises(InputError):
        score_puzzle(puzzle, answers, _submit(_letters(parsed) + "."))


@pytest.mark.parametrize(
    ("changes", "problem"),
    [
        ({"letters": "AB1"}, "letters may only contain A-Z"),
        ({"elapsedSec": -1}, "elapsedSec must be at least 0"),
        (
            {"hintsUsed": {"letter": -1, "word": 0, "clue": 0}},
            "hintsUsed.letter must be at least 0",
        ),
        ({"hintsUsed": None}, "hintsUsed must be an object"),
        ({"revealedWordIds": ["two down"]}, "revealedWordIds[0]"),
        ({"puzzleId": "../users"}, "puzzleId"),
    ],
)
def test_parse_rejections(changes, problem):
    data = {
        "puzzleId": PID,
        "letters": "ab.#",
        "elapsedSec": 30,
        "hintsUsed": {"letter": 0, "word": 0, "clue": 0},
        **changes,
    }
    with pytest.raises(InputError) as error:
        parse_submit(data)
    assert error.value.problems[0].startswith(problem)


def test_parse_uppercases_letters():
    assert _submit("ab.#")["letters"] == "AB.#"


def test_saved_progress_wins_for_time_and_hints():
    submit = _submit("AB", elapsed=10, letter=0, word=0)
    progress = {"elapsedSec": 300, "hintsUsed": {"letter": 2, "word": 1, "clue": 0}}
    merged = merge_with_progress(submit, progress)
    assert merged["elapsedSec"] == 300
    assert merged["hintsUsed"] == {"letter": 2, "word": 1, "clue": 1}


def _result(correct=7, total=7, time_sec=120):
    return {"correctWords": correct, "totalWords": total, "timeSec": time_sec}


def test_first_puzzle_starts_a_streak():
    assert next_stats(None, _result(), "2026-10-23") == {
        "played": 1,
        "solved": 1,
        "currentStreak": 1,
        "longestStreak": 1,
        "lastSolvedDate": "2026-10-23",
        "bestTimeSec": 120,
    }


def _stats(streak=4, longest=9, last="2026-10-22", best=100):
    return {
        "played": 10,
        "solved": 8,
        "currentStreak": streak,
        "longestStreak": longest,
        "lastSolvedDate": last,
        "bestTimeSec": best,
    }


def test_streak_continues_from_yesterday():
    stats = next_stats(_stats(), _result(), "2026-10-23")
    assert stats["currentStreak"] == 5
    assert stats["longestStreak"] == 9
    assert stats["bestTimeSec"] == 100


def test_streak_continues_across_month_end():
    assert next_stats(_stats(last="2026-10-31"), _result(), "2026-11-01")["currentStreak"] == 5


def test_second_puzzle_same_day_keeps_streak():
    stats = next_stats(_stats(last="2026-10-23"), _result(), "2026-10-23")
    assert stats["currentStreak"] == 4
    assert stats["played"] == 11


def test_streak_resets_after_a_missed_day():
    stats = next_stats(_stats(last="2026-10-21"), _result(), "2026-10-23")
    assert stats["currentStreak"] == 1
    assert stats["longestStreak"] == 9


def test_streak_sets_new_longest():
    assert next_stats(_stats(streak=9), _result(), "2026-10-23")["longestStreak"] == 10


def test_imperfect_puzzle_is_played_not_solved():
    stats = next_stats(_stats(), _result(correct=5, time_sec=50), "2026-10-23")
    assert stats["played"] == 11
    assert stats["solved"] == 8
    assert stats["bestTimeSec"] == 100


def test_rate_limit_window():
    first = next_rate_limit(None, NOW)
    assert first == {"submitWindowStart": NOW, "submitCount": 1}
    assert next_rate_limit(first, NOW + timedelta(minutes=5))["submitCount"] == 2
    full = {"submitWindowStart": NOW, "submitCount": 30}
    with pytest.raises(RateLimitError):
        next_rate_limit(full, NOW + timedelta(minutes=59))
    assert next_rate_limit(full, NOW + timedelta(hours=1)) == {
        "submitWindowStart": NOW + timedelta(hours=1),
        "submitCount": 1,
    }


def test_completed_progress_without_saved_progress():
    progress = completed_progress(None, _submit("AB"), _result(), now=NOW)
    assert progress["status"] == "completed"
    assert progress["startedAt"] == NOW
    assert progress["checksUsed"] == 0


def test_revision_fields(puzzle_and_answers, example_questions):
    puzzle, _, _ = puzzle_and_answers
    word = puzzle["words"][2]
    fields = revision_fields(word, "VAIKOM", example_questions["q-vaikom"], puzzle_id=PID, now=NOW)
    assert fields["source"] == {"game": "crossword", "puzzleId": PID}
    assert fields["mastered"] is False
    assert fields["subject"] == "kerala_history"
    assert fields["clue"] == word["clue"]
