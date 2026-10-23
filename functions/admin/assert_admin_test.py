from types import SimpleNamespace

import pytest
from firebase_functions import https_fn

from admin.assert_admin import assert_admin


def _request(auth):
    return SimpleNamespace(auth=auth)


def _auth(uid, token):
    return SimpleNamespace(uid=uid, token=token)


def test_rejects_unauthenticated_callers():
    with pytest.raises(https_fn.HttpsError) as error:
        assert_admin(_request(None))
    assert error.value.code == https_fn.FunctionsErrorCode.UNAUTHENTICATED


def test_rejects_callers_without_admin_claim():
    with pytest.raises(https_fn.HttpsError) as error:
        assert_admin(_request(_auth("u1", {})))
    assert error.value.code == https_fn.FunctionsErrorCode.PERMISSION_DENIED


@pytest.mark.parametrize("claim", ["true", 1, False, None])
def test_rejects_non_true_admin_claim(claim):
    with pytest.raises(https_fn.HttpsError) as error:
        assert_admin(_request(_auth("u1", {"admin": claim})))
    assert error.value.code == https_fn.FunctionsErrorCode.PERMISSION_DENIED


def test_returns_uid_for_admins():
    assert assert_admin(_request(_auth("admin1", {"admin": True}))) == "admin1"
