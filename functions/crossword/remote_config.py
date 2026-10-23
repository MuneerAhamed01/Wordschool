"""Fetch the client Remote Config template and cache hint penalties (CW-026)."""

import time
from collections.abc import Callable

import firebase_admin
from firebase_functions import logger
from google.auth.transport.requests import AuthorizedSession

from crossword.hint_penalties import DEFAULT_HINT_PENALTIES, HintPenalties, penalties_from_template

CACHE_SECONDS = 300
_TEMPLATE_URL = "https://firebaseremoteconfig.googleapis.com/v1/projects/{project}/remoteConfig"
_FETCH_TIMEOUT_SECONDS = 5


def fetch_template() -> object:
    """GET the project's client Remote Config template with the app's credentials.

    Raises:
        requests.RequestException: Network or HTTP error.
    """
    app = firebase_admin.get_app()
    session = AuthorizedSession(app.credential.get_credential())
    response = session.get(
        _TEMPLATE_URL.format(project=app.project_id), timeout=_FETCH_TIMEOUT_SECONDS
    )
    response.raise_for_status()
    return response.json()


class HintPenaltiesSource:
    """Hint penalties cached for `CACHE_SECONDS` per function instance.

    On a failed fetch it keeps the last good value (or the defaults) and retries after
    the next cache period, so Remote Config trouble never fails a submit.
    """

    def __init__(
        self,
        fetch: Callable[[], object] = fetch_template,
        *,
        clock: Callable[[], float] = time.monotonic,
    ) -> None:
        """Create a source.

        Args:
            fetch: Returns the Remote Config template JSON.
            clock: Seconds, monotonic.
        """
        self._fetch = fetch
        self._clock = clock
        self._value: HintPenalties = DEFAULT_HINT_PENALTIES
        self._expires_at: float | None = None

    def get(self) -> HintPenalties:
        """The current penalties, fetching the template when the cache has expired."""
        now = self._clock()
        if self._expires_at is not None and now < self._expires_at:
            return self._value
        try:
            self._value = penalties_from_template(self._fetch())
        except Exception as error:  # noqa: BLE001 - any failure falls back, never fails a submit
            logger.warn("Remote Config fetch failed; using cached hint penalties", error=str(error))
        self._expires_at = now + CACHE_SECONDS
        return self._value


_source = HintPenaltiesSource()


def current_hint_penalties() -> HintPenalties:
    """Hint penalties for this function instance (cached Remote Config value)."""
    return _source.get()
