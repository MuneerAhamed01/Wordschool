import re
from pathlib import Path

from crossword import collections

_DART_FILE = Path(__file__).parents[2] / "lib" / "core" / "firebase" / "collections.dart"
_DART_CONST = re.compile(r"static const String (\w+) = '([^']+)';")


def _to_upper_snake(camel: str) -> str:
    return re.sub(r"(?<!^)(?=[A-Z])", "_", camel).upper()


def _python_constants() -> dict[str, str]:
    return {
        name: value
        for name, value in vars(collections).items()
        if name.isupper() and isinstance(value, str)
    }


def test_matches_dart_constants() -> None:
    dart = {
        _to_upper_snake(name): value for name, value in _DART_CONST.findall(_DART_FILE.read_text())
    }
    assert dart, f"no constants parsed from {_DART_FILE}"
    assert _python_constants() == dart


def test_names_are_unique() -> None:
    values = list(_python_constants().values())
    assert len(values) == len(set(values))
