"""Read untyped callable request data field by field, collecting every problem.

Usage:
    reader = InputReader(req.data)
    slug = reader.string("id", pattern=SLUG_RE)
    order = reader.integer("order", minimum=0)
    reader.raise_if_problems()   # InputError listing all problems
"""

import re
from collections.abc import Sequence
from typing import cast

from crossword.errors import InputError
from crossword.types import LocalizedText

_MAX_TEXT = 2000


class InputReader:
    """Reads fields of a JSON object; child readers share the parent's problem list."""

    def __init__(self, data: object, *, path: str = "", problems: list[str] | None = None) -> None:
        """Create a reader.

        Args:
            data: The value to read; anything but a dict is reported as a problem.
            path: Prefix for problem messages, e.g. `words[2].`.
            problems: Shared problem list (child readers).
        """
        self.problems: list[str] = [] if problems is None else problems
        self._path = path
        # A reader over a non-object reports that once and skips its field checks.
        self._valid = isinstance(data, dict)
        if isinstance(data, dict):
            self._data: dict[str, object] = cast(dict[str, object], data)
        else:
            self._data = {}
            self.problems.append(f"{path.rstrip('.') or 'request data'} must be an object")

    def _name(self, key: str) -> str:
        return f"{self._path}{key}"

    def _missing(self, key: str, required: bool) -> None:
        if required and self._valid:
            self.problems.append(f"{self._name(key)} is required")

    def has(self, key: str) -> bool:
        """True when `key` is present and not null."""
        return self._data.get(key) is not None

    def problem(self, message: str) -> None:
        """Record a problem that is not tied to one field's type."""
        self.problems.append(message)

    def string(
        self,
        key: str,
        *,
        required: bool = True,
        pattern: re.Pattern[str] | None = None,
        max_length: int = _MAX_TEXT,
        strip: bool = True,
    ) -> str | None:
        """Read a string field."""
        value = self._data.get(key)
        if value is None:
            self._missing(key, required)
            return None
        if not isinstance(value, str):
            self.problems.append(f"{self._name(key)} must be a string")
            return None
        if strip:
            value = value.strip()
        if required and not value:
            self.problems.append(f"{self._name(key)} is required")
            return None
        if len(value) > max_length:
            self.problems.append(f"{self._name(key)} must be at most {max_length} characters")
            return None
        if pattern is not None and not pattern.fullmatch(value):
            self.problems.append(f"{self._name(key)} {value!r} must match {pattern.pattern}")
            return None
        return value

    def integer(
        self,
        key: str,
        *,
        required: bool = True,
        minimum: int | None = None,
        maximum: int | None = None,
    ) -> int | None:
        """Read an integer field (bools are refused)."""
        value = self._data.get(key)
        if value is None:
            self._missing(key, required)
            return None
        if isinstance(value, float) and value.is_integer():
            value = int(value)
        if not isinstance(value, int) or isinstance(value, bool):
            self.problems.append(f"{self._name(key)} must be a whole number")
            return None
        if minimum is not None and value < minimum:
            self.problems.append(f"{self._name(key)} must be at least {minimum}")
            return None
        if maximum is not None and value > maximum:
            self.problems.append(f"{self._name(key)} must be at most {maximum}")
            return None
        return value

    def boolean(self, key: str, *, required: bool = True) -> bool | None:
        """Read a boolean field."""
        value = self._data.get(key)
        if value is None:
            self._missing(key, required)
            return None
        if not isinstance(value, bool):
            self.problems.append(f"{self._name(key)} must be true or false")
            return None
        return value

    def choice[T: str](self, key: str, options: Sequence[T], *, required: bool = True) -> T | None:
        """Read a string that must be one of `options`."""
        value = self.string(key, required=required)
        if value is None:
            return None
        for option in options:
            if value == option:
                return option
        self.problems.append(f"{self._name(key)} must be one of {', '.join(options)}")
        return None

    def localized(
        self, key: str, *, required: bool = True, max_length: int = _MAX_TEXT
    ) -> LocalizedText | None:
        """Read `{en, ml?}`; `en` is required when the field is."""
        if self._data.get(key) is None:
            self._missing(f"{key}.en", required)
            return None
        child = self.child(key)
        en = child.string("en", max_length=max_length)
        ml = child.string("ml", required=False, max_length=max_length)
        if en is None:
            return None
        text: LocalizedText = {"en": en}
        if ml:
            text["ml"] = ml
        return text

    def string_list(
        self,
        key: str,
        *,
        required: bool = True,
        pattern: re.Pattern[str] | None = None,
        max_items: int = 50,
    ) -> list[str] | None:
        """Read a list of non-empty strings."""
        value = self._data.get(key)
        if value is None:
            self._missing(key, required)
            return None
        if not isinstance(value, list) or len(value) > max_items:
            self.problems.append(f"{self._name(key)} must be a list of at most {max_items} items")
            return None
        items: list[str] = []
        for index, item in enumerate(cast(list[object], value)):
            if not isinstance(item, str) or not item.strip():
                self.problems.append(f"{self._name(key)}[{index}] must be a non-empty string")
            elif pattern is not None and not pattern.fullmatch(item.strip()):
                self.problems.append(
                    f"{self._name(key)}[{index}] {item!r} must match {pattern.pattern}"
                )
            else:
                items.append(item.strip())
        return items

    def child(self, key: str) -> "InputReader":
        """Reader for a nested object; problems go to the same list."""
        return InputReader(self._data.get(key), path=f"{self._name(key)}.", problems=self.problems)

    def children(
        self, key: str, *, min_items: int = 0, max_items: int = 200
    ) -> list["InputReader"]:
        """Readers for each object of a list field."""
        value = self._data.get(key)
        if not isinstance(value, list):
            self.problems.append(f"{self._name(key)} must be a list")
            return []
        items = cast(list[object], value)
        if not min_items <= len(items) <= max_items:
            self.problems.append(
                f"{self._name(key)} must have {min_items}–{max_items} items, got {len(items)}"
            )
            return []
        return [
            InputReader(item, path=f"{self._name(key)}[{index}].", problems=self.problems)
            for index, item in enumerate(items)
        ]

    def raise_if_problems(self) -> None:
        """Raise one `InputError` listing every problem found so far.

        Raises:
            InputError: When any problem was recorded.
        """
        if self.problems:
            raise InputError(list(self.problems))
