from scripts.set_admin_claim import MIN_PASSWORD_LENGTH, next_claims, password_problem


def test_grant_keeps_other_claims():
    assert next_claims({"beta": True}, grant=True) == {"beta": True, "admin": True}
    assert next_claims(None, grant=True) == {"admin": True}


def test_revoke_removes_only_admin():
    assert next_claims({"admin": True, "beta": True}, grant=False) == {"beta": True}
    assert next_claims(None, grant=False) == {}


def test_password_problem():
    ok = "x" * MIN_PASSWORD_LENGTH
    assert password_problem(ok, ok) is None
    assert password_problem("short", "short") == f"Use at least {MIN_PASSWORD_LENGTH} characters."
    assert password_problem(ok, ok + "y") == "The two passwords don't match."
