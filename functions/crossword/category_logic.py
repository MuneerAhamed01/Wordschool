"""Pure logic for `adminSaveCategory` (CW-015)."""

import re
from typing import NotRequired, TypedDict

from crossword.input_reader import InputReader
from crossword.types import SCHEMA_VERSION, CrosswordCategory, LocalizedText, Timestamp

SLUG_RE = re.compile(r"[a-z0-9-]+")
ICON_RE = re.compile(r"[a-z0-9_-]+")
COLOR_RE = re.compile(r"#[0-9A-Fa-f]{6}")


class CategoryInput(TypedDict):
    """Validated `adminSaveCategory` input."""

    id: str
    name: LocalizedText
    description: NotRequired[LocalizedText]
    icon: str
    color: str
    order: int
    isActive: bool


def parse_category(data: object) -> CategoryInput:
    """Validate the request data.

    Raises:
        InputError: Listing every problem.
    """
    reader = InputReader(data)
    slug = reader.string("id", pattern=SLUG_RE, max_length=60)
    name = reader.localized("name", max_length=60)
    description = reader.localized("description", required=False, max_length=200)
    icon = reader.string("icon", pattern=ICON_RE, max_length=40)
    color = reader.string("color", pattern=COLOR_RE)
    order = reader.integer("order", minimum=0, maximum=100_000)
    is_active = reader.boolean("isActive")
    reader.raise_if_problems()
    assert slug and name and icon and color and order is not None and is_active is not None
    category: CategoryInput = {
        "id": slug,
        "name": name,
        "icon": icon,
        "color": color.upper(),
        "order": order,
        "isActive": is_active,
    }
    if description:
        category["description"] = description
    return category


def category_doc(
    category: CategoryInput,
    *,
    admin_uid: str,
    existing: CrosswordCategory | None,
    now: Timestamp,
) -> CrosswordCategory:
    """The full document to write; keeps counters and creation fields of an existing one."""
    doc: CrosswordCategory = {
        "name": category["name"],
        "icon": category["icon"],
        "color": category["color"],
        "order": category["order"],
        "isActive": category["isActive"],
        "publishedPuzzleCount": existing["publishedPuzzleCount"] if existing else 0,
        "lastPuzzleNumber": existing.get("lastPuzzleNumber", 0) if existing else 0,
        "schemaVersion": SCHEMA_VERSION,
        "createdAt": existing["createdAt"] if existing else now,
        "createdBy": existing["createdBy"] if existing else admin_uid,
        "updatedAt": now,
        "updatedBy": admin_uid,
    }
    if "description" in category:
        doc["description"] = category["description"]
    return doc
