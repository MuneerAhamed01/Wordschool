"""Pure parsing of the `crossword_hint_penalties` Remote Config value (CW-026).

The server reads the **client** template's default value, so one console change applies
to the app and to `submitCrossword`. Conditional values are ignored (the server has no
app context to evaluate them). Fetching and caching are in `crossword.remote_config`.
"""

import json
from typing import TypedDict, cast

HINT_PENALTIES_KEY = "crossword_hint_penalties"


class HintPenalties(TypedDict):
    """XP deducted per revealed letter and per revealed word."""

    letter: int
    word: int


# Same as the app's `HintPenalties.fallback` / Remote Config in-app default (CW-005).
DEFAULT_HINT_PENALTIES: HintPenalties = {"letter": 5, "word": 15}


def parse_hint_penalties(raw: object) -> HintPenalties:
    """Parse `{"letter":5,"word":15}` like the app does; defaults for bad input."""
    if not isinstance(raw, str):
        return DEFAULT_HINT_PENALTIES
    try:
        value = json.loads(raw)
    except ValueError:
        return DEFAULT_HINT_PENALTIES
    if not isinstance(value, dict):
        return DEFAULT_HINT_PENALTIES
    fields = cast(dict[str, object], value)
    letter, word = fields.get("letter"), fields.get("word")
    if (
        not isinstance(letter, int)
        or not isinstance(word, int)
        or isinstance(letter, bool)
        or isinstance(word, bool)
        or letter < 0
        or word < 0
    ):
        return DEFAULT_HINT_PENALTIES
    return {"letter": letter, "word": word}


def penalties_from_template(template: object) -> HintPenalties:
    """Hint penalties from a Remote Config template (REST `RemoteConfig` JSON).

    The parameter may sit at the top level or inside a parameter group.
    """
    if not isinstance(template, dict):
        return DEFAULT_HINT_PENALTIES
    body = cast(dict[str, object], template)
    groups = body.get("parameterGroups")
    scopes: list[object] = [body.get("parameters")]
    if isinstance(groups, dict):
        scopes += [group.get("parameters") for group in groups.values() if isinstance(group, dict)]
    for parameters in scopes:
        if isinstance(parameters, dict) and HINT_PENALTIES_KEY in parameters:
            parameter = parameters[HINT_PENALTIES_KEY]
            default = parameter.get("defaultValue") if isinstance(parameter, dict) else None
            return parse_hint_penalties(default.get("value") if isinstance(default, dict) else None)
    return DEFAULT_HINT_PENALTIES
