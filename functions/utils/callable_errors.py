from collections.abc import Iterator
from contextlib import contextmanager

from firebase_functions import https_fn

from crossword.errors import (
    InputError,
    NotFoundError,
    PermissionDeniedError,
    PreconditionError,
    RateLimitError,
)

_CODES: list[tuple[type[Exception], https_fn.FunctionsErrorCode]] = [
    (InputError, https_fn.FunctionsErrorCode.INVALID_ARGUMENT),
    (NotFoundError, https_fn.FunctionsErrorCode.NOT_FOUND),
    (PreconditionError, https_fn.FunctionsErrorCode.FAILED_PRECONDITION),
    (RateLimitError, https_fn.FunctionsErrorCode.RESOURCE_EXHAUSTED),
    (PermissionDeniedError, https_fn.FunctionsErrorCode.PERMISSION_DENIED),
]
_DOMAIN_ERRORS = tuple(kind for kind, _ in _CODES)


@contextmanager
def callable_errors() -> Iterator[None]:
    """Turn crossword domain errors raised inside the block into `HttpsError`s.

    Raises:
        https_fn.HttpsError: With the matching code and the original message.
    """
    try:
        yield
    except _DOMAIN_ERRORS as error:
        code = next(code for kind, code in _CODES if isinstance(error, kind))
        raise https_fn.HttpsError(code, str(error)) from error
