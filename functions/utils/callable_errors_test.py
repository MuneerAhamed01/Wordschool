import pytest
from firebase_functions import https_fn

from crossword.errors import (
    InputError,
    NotFoundError,
    PermissionDeniedError,
    PreconditionError,
    RateLimitError,
)
from utils.callable_errors import callable_errors


@pytest.mark.parametrize(
    ("error", "code"),
    [
        (
            InputError(["a is required", "b is too long"]),
            https_fn.FunctionsErrorCode.INVALID_ARGUMENT,
        ),
        (NotFoundError("no such puzzle"), https_fn.FunctionsErrorCode.NOT_FOUND),
        (PreconditionError("already published"), https_fn.FunctionsErrorCode.FAILED_PRECONDITION),
        (RateLimitError("slow down"), https_fn.FunctionsErrorCode.RESOURCE_EXHAUSTED),
        (PermissionDeniedError("blocked"), https_fn.FunctionsErrorCode.PERMISSION_DENIED),
    ],
)
def test_maps_domain_errors(error, code):
    with pytest.raises(https_fn.HttpsError) as raised:
        with callable_errors():
            raise error
    assert raised.value.code == code
    assert raised.value.message == str(error)


def test_input_error_lists_every_problem():
    assert str(InputError(["a is required", "b is too long"])) == "a is required; b is too long"


def test_other_errors_pass_through():
    with pytest.raises(KeyError):
        with callable_errors():
            raise KeyError("bug")
