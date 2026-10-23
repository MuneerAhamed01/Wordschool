from firebase_admin import firestore
from google.cloud.firestore import Client


def db() -> Client:
    """Return the default Firestore database of the current project."""
    return firestore.client()
