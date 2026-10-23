"""Shared pytest fixtures.

Emulator tests use `emulator_db` and are skipped unless the Firestore emulator runs:
    firebase emulators:exec --only firestore --project demo-kerala-pcs "venv/bin/pytest"
"""

import json
import os
import sys
import urllib.request
from collections.abc import Iterator
from datetime import UTC, datetime
from pathlib import Path
from types import SimpleNamespace
from typing import Any

import pytest
from google.auth.credentials import AnonymousCredentials
from google.cloud.firestore import Client

import firestore_client
from crossword import remote_config
from crossword.collections import CROSSWORD_CATEGORIES, PSC_QUESTIONS

EMULATOR_PROJECT = "demo-kerala-pcs"


@pytest.fixture(autouse=True)
def no_remote_config(monkeypatch: pytest.MonkeyPatch) -> None:
    """Handlers use the default hint penalties instead of fetching Remote Config."""
    monkeypatch.setattr(remote_config, "_source", remote_config.HintPenaltiesSource(lambda: {}))


@pytest.fixture
def emulator_db(monkeypatch: pytest.MonkeyPatch) -> Iterator[Client]:
    """Firestore client for the emulator, emptied before each test.

    Also points every module's `db()` (handlers, `write_audit_log`) at the emulator.
    """
    host = os.environ.get("FIRESTORE_EMULATOR_HOST")
    if not host:
        pytest.skip("Firestore emulator not running")
    request = urllib.request.Request(
        f"http://{host}/emulator/v1/projects/{EMULATOR_PROJECT}/databases/(default)/documents",
        method="DELETE",
    )
    urllib.request.urlopen(request).close()
    client = Client(project=EMULATOR_PROJECT, credentials=AnonymousCredentials())
    # Every module that imported `db` from firestore_client gets the emulator client.
    original_db = firestore_client.db
    for module in list(sys.modules.values()):
        if getattr(module, "db", None) is original_db:
            monkeypatch.setattr(module, "db", lambda: client)
    yield client


def callable_request(data: object, *, uid: str | None = "admin1", admin: bool = True) -> Any:
    """Stand-in for `https_fn.CallableRequest`; call a handler as `inspect.unwrap(handler)(req)`."""
    auth = None if uid is None else SimpleNamespace(uid=uid, token={"admin": True} if admin else {})
    return SimpleNamespace(auth=auth, data=data)


_EXAMPLE_PUZZLE = (
    Path(__file__).parents[1]
    / ".claude/skills/crossword-content/examples/kerala-history-0012.puzzle.json"
)


@pytest.fixture
def example_puzzle_input() -> dict[str, Any]:
    """The skill's example puzzle as new admin input; question ids are `q-<answer>`."""
    puzzle = json.loads(_EXAMPLE_PUZZLE.read_text())
    del puzzle["id"], puzzle["number"]
    for word in puzzle["words"]:
        word["questionId"] = f"q-{word['answer'].lower()}"
    return puzzle


@pytest.fixture
def example_questions(example_puzzle_input: dict[str, Any]) -> dict[str, dict[str, Any]]:
    """Verified `pscQuestions` docs for every word of the example puzzle."""
    now = datetime(2026, 10, 1, tzinfo=UTC)
    return {
        word["questionId"]: {
            "answer": word["answer"],
            "answerDisplay": {"en": word["answer"].title()},
            "clues": [{"en": word["clue"]["en"], "level": "medium"}],
            "fact": word["fact"],
            "subject": "kerala_history",
            "examTags": ["ldc"],
            "difficulty": "medium",
            "source": {"type": "pyq", "ref": "LDC 2017"},
            "status": "verified",
            "verifiedBy": "admin0",
            "verifiedAt": now,
            "usedInPuzzles": [],
            "schemaVersion": 1,
            "createdAt": now,
            "updatedAt": now,
            "createdBy": "admin0",
            "updatedBy": "admin0",
        }
        for word in example_puzzle_input["words"]
    }


@pytest.fixture
def seeded_example(emulator_db: Client, example_questions: dict[str, dict[str, Any]]) -> Client:
    """Emulator with the `kerala-history` category and the example's verified questions."""
    now = datetime(2026, 10, 1, tzinfo=UTC)
    emulator_db.collection(CROSSWORD_CATEGORIES).document("kerala-history").set(
        {
            "name": {"en": "Kerala History"},
            "icon": "landmark",
            "color": "#6AAA64",
            "order": 10,
            "isActive": True,
            "publishedPuzzleCount": 0,
            "lastPuzzleNumber": 0,
            "schemaVersion": 1,
            "createdAt": now,
            "updatedAt": now,
            "createdBy": "admin0",
            "updatedBy": "admin0",
        }
    )
    for qid, question in example_questions.items():
        emulator_db.collection(PSC_QUESTIONS).document(qid).set(question)
    return emulator_db
