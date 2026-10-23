import json

from crossword.hint_penalties import DEFAULT_HINT_PENALTIES
from crossword.remote_config import CACHE_SECONDS, HintPenaltiesSource


def _template(letter, word):
    value = json.dumps({"letter": letter, "word": word})
    return {"parameters": {"crossword_hint_penalties": {"defaultValue": {"value": value}}}}


class _Fake:
    def __init__(self, *results):
        self.results = list(results)
        self.calls = 0
        self.now = 0.0

    def fetch(self):
        self.calls += 1
        result = self.results.pop(0)
        if isinstance(result, Exception):
            raise result
        return result

    def clock(self):
        return self.now


def test_caches_then_picks_up_a_change():
    fake = _Fake(_template(2, 8), _template(1, 4))
    source = HintPenaltiesSource(fake.fetch, clock=fake.clock)
    assert source.get() == {"letter": 2, "word": 8}
    fake.now = CACHE_SECONDS - 1
    assert source.get() == {"letter": 2, "word": 8}
    assert fake.calls == 1
    fake.now = CACHE_SECONDS
    assert source.get() == {"letter": 1, "word": 4}
    assert fake.calls == 2


def test_failed_first_fetch_uses_defaults():
    fake = _Fake(OSError("offline"))
    source = HintPenaltiesSource(fake.fetch, clock=fake.clock)
    assert source.get() == DEFAULT_HINT_PENALTIES


def test_failed_refresh_keeps_last_good_value_and_retries_later():
    fake = _Fake(_template(2, 8), OSError("offline"), _template(1, 4))
    source = HintPenaltiesSource(fake.fetch, clock=fake.clock)
    source.get()
    fake.now = CACHE_SECONDS
    assert source.get() == {"letter": 2, "word": 8}
    fake.now = CACHE_SECONDS + 1
    assert source.get() == {"letter": 2, "word": 8}
    assert fake.calls == 2
    fake.now = 2 * CACHE_SECONDS
    assert source.get() == {"letter": 1, "word": 4}
