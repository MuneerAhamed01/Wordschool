"""Emulator tests (skipped without FIRESTORE_EMULATOR_HOST)."""

from crossword.collections import ADMIN_AUDIT_LOG, CROSSWORD_CATEGORIES
from crossword.save_category import save_category

DATA = {
    "id": "kerala-history",
    "name": {"en": "Kerala History"},
    "icon": "landmark",
    "color": "#6AAA64",
    "order": 10,
    "isActive": True,
}


def test_creates_then_updates_keeping_counters(emulator_db):
    assert save_category(emulator_db, "admin1", DATA) == {"id": "kerala-history", "created": True}
    ref = emulator_db.collection(CROSSWORD_CATEGORIES).document("kerala-history")
    ref.update({"publishedPuzzleCount": 3})

    result = save_category(emulator_db, "admin2", {**DATA, "isActive": False})

    assert result == {"id": "kerala-history", "created": False}
    doc = ref.get().to_dict()
    assert doc["isActive"] is False
    assert doc["publishedPuzzleCount"] == 3
    assert doc["createdBy"] == "admin1"
    assert doc["updatedBy"] == "admin2"
    assert doc["createdAt"] is not None


def test_audit_log_goes_to_emulator(emulator_db):
    from admin.audit_log import write_audit_log

    write_audit_log(action="crossword.saveCategory", admin_uid="admin1", target_id="x")
    assert len(list(emulator_db.collection(ADMIN_AUDIT_LOG).stream())) == 1
