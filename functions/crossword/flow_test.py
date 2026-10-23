"""End-to-end smoke test of the deployed callables on the emulator (CW-023).

Admin: category → questions → verify → puzzle → review → publish → daily.
Player: submit → result. Calls the real handlers (`inspect.unwrap`) with fake requests.
"""

import inspect

import pytest
from firebase_functions import https_fn

import main
from conftest import callable_request
from crossword.collections import ADMIN_AUDIT_LOG, CROSSWORD_DAILY, USERS
from crossword.validate_puzzle import word_cells
from utils.date_id import today_ist_date_id

QUESTION_FIELDS = (
    "answer",
    "answerDisplay",
    "clues",
    "fact",
    "subject",
    "examTags",
    "difficulty",
    "source",
)


def _call(handler, data, **auth):
    return inspect.unwrap(handler)(callable_request(data, **auth))


def test_admin_flow_then_player_submit(emulator_db, example_puzzle_input, example_questions):
    _call(
        main.adminSaveCategory,
        {
            "id": "kerala-history",
            "name": {"en": "Kerala History"},
            "icon": "landmark",
            "color": "#6AAA64",
            "order": 10,
            "isActive": True,
        },
    )

    question_ids = {}
    for old_id, question in example_questions.items():
        data = {key: question[key] for key in QUESTION_FIELDS}
        saved = _call(main.adminSaveQuestion, data)
        assert saved["status"] == "draft"
        _call(main.adminVerifyQuestion, {"id": saved["id"]})
        question_ids[old_id] = saved["id"]
    for word in example_puzzle_input["words"]:
        word["questionId"] = question_ids[word["questionId"]]

    puzzle = _call(main.adminSaveCrosswordPuzzle, example_puzzle_input)
    pid = puzzle["id"]
    assert pid == "kerala-history-0001"
    _call(main.adminSetPuzzleStatus, {"puzzleId": pid, "status": "in_review"})
    _call(main.adminSetPuzzleStatus, {"puzzleId": pid, "status": "published"})
    today = today_ist_date_id()
    _call(main.adminScheduleDaily, {"dateId": today, "puzzleId": pid})
    assert emulator_db.collection(CROSSWORD_DAILY).document(today).get().get("puzzleId") == pid

    cells = list(example_puzzle_input["layout"])
    for word in example_puzzle_input["words"]:
        for (r, c), letter in zip(word_cells(word), word["answer"], strict=True):
            cells[r * example_puzzle_input["cols"] + c] = letter
    submit = {
        "puzzleId": pid,
        "letters": "".join(cells),
        "elapsedSec": 240,
        "hintsUsed": {"letter": 0, "word": 0, "clue": 1},
    }
    response = _call(main.submitCrossword, submit, uid="player1", admin=False)

    assert response["result"]["score"] == 100
    assert response["result"]["xpEarned"] == 50
    assert response["xp"] == 50
    assert emulator_db.collection(USERS).document("player1").get().get("xp") == 50
    # 1 category + 7 saves + 7 verifies + 1 puzzle + 2 status + 1 daily
    assert len(list(emulator_db.collection(ADMIN_AUDIT_LOG).stream())) == 19


def test_players_cannot_call_admin_functions(emulator_db):
    with pytest.raises(https_fn.HttpsError) as error:
        _call(main.adminSaveCategory, {}, uid="player1", admin=False)
    assert error.value.code == https_fn.FunctionsErrorCode.PERMISSION_DENIED


def test_submit_requires_sign_in(emulator_db):
    with pytest.raises(https_fn.HttpsError) as error:
        _call(main.submitCrossword, {}, uid=None)
    assert error.value.code == https_fn.FunctionsErrorCode.UNAUTHENTICATED


def test_invalid_input_is_invalid_argument(emulator_db):
    with pytest.raises(https_fn.HttpsError) as error:
        _call(main.adminSaveCategory, {"id": "Bad Slug"})
    assert error.value.code == https_fn.FunctionsErrorCode.INVALID_ARGUMENT
    assert "id 'Bad Slug' must match" in error.value.message
