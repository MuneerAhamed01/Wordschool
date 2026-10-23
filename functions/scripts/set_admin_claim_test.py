from scripts.set_admin_claim import next_claims


def test_grant_keeps_other_claims():
    assert next_claims({"beta": True}, grant=True) == {"beta": True, "admin": True}
    assert next_claims(None, grant=True) == {"admin": True}


def test_revoke_removes_only_admin():
    assert next_claims({"admin": True, "beta": True}, grant=False) == {"beta": True}
    assert next_claims(None, grant=False) == {}
