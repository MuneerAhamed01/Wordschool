"""Entry point for the Kerala PSC Cloud Functions.

Every deployed function must be importable from this module.
"""

import firebase_admin
from firebase_functions.options import set_global_options

try:
    firebase_admin.get_app()
except ValueError:
    firebase_admin.initialize_app()

set_global_options(region="asia-south1", max_instances=10)

# Crossword functions are imported here from CW-015 onwards, kept together.
