---
name: cloud-function
description: Add or change a Kerala PSC app Cloud Function in Python (functions/crossword/) — admin callable (assert_admin, audit log), player callable (auth, blocked check, idempotent), scheduled job (Asia/Kolkata) or Firestore trigger — with a pure logic module, pytest tests and emulator tests, then import it in functions/main.py. Use for any new or changed backend function, e.g. adminSaveQuestion, submitCrossword, crosswordDailyRollover.
---

# Cloud Function (Python 3.12, DEC-010)

There is no generator: **copy the closest existing function** and rename. Every function is split so the important part is testable without Firestore.

| File | Holds | Example to copy |
| --- | --- | --- |
| `functions/crossword/<name>_logic.py` | Pure decisions: parse input with `InputReader` (collects every problem), build docs, score. No Firestore / `firebase_functions` imports. | `category_logic.py` |
| `functions/crossword/<name>_logic_test.py` | pytest: happy path + every rejection | `category_logic_test.py` |
| `functions/crossword/<name>.py` | `do_thing(client, uid, data)` that reads/writes in **one** `run_transaction`, and the thin `@https_fn.on_call` handler | `save_category.py` |
| `functions/crossword/<name>_test.py` | Emulator tests with the `emulator_db` fixture (skipped without the emulator) | `save_category_test.py` |

Pick the example by kind:

| Kind | Copy | Must have |
| --- | --- | --- |
| Admin callable | `save_category.py` (write), `admin_reads.py` (read) | Name starts with `admin`; `admin_uid = assert_admin(req)` first, `write_audit_log(...)` last (writes only) |
| Player callable | `submit.py` | `req.auth` check; `users/{uid}.blockedAt` → `PermissionDeniedError`; idempotent (return the stored result if already done) |
| Scheduled job | `daily_rollover.py`, `leaderboard_top.py` | `scheduler_fn.on_schedule(..., timezone=scheduler_fn.Timezone("Asia/Kolkata"))`; bounded reads (`limit`); log what changed |
| Trigger | — (none yet) | `firestore_fn.on_document_*`; idempotent (triggers can fire twice) |

## Handler shape

```python
@https_fn.on_call()
def adminSaveCategory(req: https_fn.CallableRequest[Any]) -> dict[str, object]:  # noqa: N802
    """Admin: create or edit a crossword category (CW-015)."""
    admin_uid = assert_admin(req)
    with callable_errors():                      # InputError/NotFoundError/... → HttpsError
        result = save_category(db(), admin_uid, req.data)
    write_audit_log(action="crossword.saveCategory", admin_uid=admin_uid,
                    target_id=str(result["id"]), payload={"created": result["created"]})
    return result
```

## Rules

1. Collection names from `crossword/collections.py`; types from `crossword/types.py`; field names exactly as `docs/firebase/FIREBASE_DESIGN.md` (camelCase).
2. Raise the domain errors from `crossword/errors.py` (`InputError` with a `problems` list, `NotFoundError`, `PreconditionError`, `PermissionDeniedError`, `RateLimitError`); `callable_errors()` maps them. Messages are what an admin or player will read.
3. Writes: one transaction (`run_transaction` from `firestore_client.py`); set `updatedAt`/`updatedBy`. Pass `now=` in so tests control time.
4. Deployed name camelCase with `# noqa: N802`; everything else snake_case; type hints everywhere; Google-style docstrings on public functions. Region comes from `set_global_options` in `main.py`.
5. No `databaseId` parameter (DEC-002).
6. New function → import it in `functions/main.py`; new callable or schema change → add it to `docs/firebase/FIREBASE_DESIGN.md` in the same change.
7. Emulator tests call real handlers with `inspect.unwrap(handler)(callable_request(data))` (`callable_request` in `conftest.py`).

## Verify

```bash
cd functions && venv/bin/ruff check . && venv/bin/ruff format --check . && venv/bin/pytest
firebase emulators:exec --only firestore --project demo-kerala-pcs "cd functions && venv/bin/pytest"   # + emulator tests
```

Then give the user the deploy command (don't deploy unless asked) and note it in `docs/STATUS.md` → "Deployed":

```bash
firebase deploy --only functions:<name> --project kerala-pcs-dev
```

## Checklist

- [ ] Logic module is pure and tested (happy path + every rejection)
- [ ] Admin: `assert_admin` + `write_audit_log`; player: auth + blocked check + idempotent
- [ ] Imported in `functions/main.py`; design doc updated
- [ ] ruff + pytest green (and emulator tests if it touches Firestore)
- [ ] `docs/STATUS.md` lists it as pending deploy (or deployed)
