from collections.abc import Callable

from firebase_admin import firestore
from google.cloud.firestore import Client, Transaction, transactional


def db() -> Client:
    """Return the default Firestore database of the current project."""
    return firestore.client()


def run_transaction[T](client: Client, body: Callable[[Transaction], T]) -> T:
    """Run `body` in a Firestore transaction (retried on contention).

    All reads in `body` must come before its writes.

    Returns:
        Whatever `body` returns.
    """

    @transactional
    def _run(transaction: Transaction) -> T:
        return body(transaction)

    return _run(client.transaction())
