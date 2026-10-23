"""Errors raised by pure crossword logic; `utils.callable_errors` maps them to `HttpsError`."""


class InputError(ValueError):
    """The request data is invalid. Lists every problem, not just the first."""

    def __init__(self, problems: list[str]) -> None:
        """Create the error.

        Args:
            problems: Readable problems, e.g. `"name.en is required"`.
        """
        self.problems = problems
        super().__init__("; ".join(problems))


class NotFoundError(LookupError):
    """A document the request refers to does not exist."""


class PreconditionError(RuntimeError):
    """The request is valid but the current state does not allow it."""


class PermissionDeniedError(PermissionError):
    """The caller may not do this (e.g. a blocked player)."""


class RateLimitError(RuntimeError):
    """The caller has made too many requests."""
