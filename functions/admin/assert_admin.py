from typing import Any

from firebase_functions import https_fn


def assert_admin(request: https_fn.CallableRequest[Any]) -> str:
    """Raise unless the caller has the `admin` custom claim.

    Args:
        request: The callable request.

    Returns:
        The admin's uid.

    Raises:
        https_fn.HttpsError: `unauthenticated` or `permission-denied`.
    """
    auth = request.auth
    if auth is None or not auth.uid:
        raise https_fn.HttpsError(
            https_fn.FunctionsErrorCode.UNAUTHENTICATED, "Sign in required"
        )
    if auth.token.get("admin") is not True:
        raise https_fn.HttpsError(
            https_fn.FunctionsErrorCode.PERMISSION_DENIED, "Admin access required"
        )
    return auth.uid
