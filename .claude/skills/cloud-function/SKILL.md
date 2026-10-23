---
name: cloud-function
description: Scaffold a Kerala PSC app Cloud Function in functions/src — admin callable (assertAdmin, audit log), player callable, scheduled job (Asia/Kolkata) or Firestore trigger — with a pure-logic file and Jest tests, then export it. Use for any new or changed backend function, e.g. adminSaveQuestion, submitCrossword, crosswordDailyRollover.
---

# Cloud Function generator

> **⚠ Outdated — functions are Python now (DEC-010).** The steps and `scripts/scaffold_function.py` below still generate TypeScript. Until this skill is ported, write functions by hand following `CLAUDE.md` → "Cloud Functions" and `.cursor/rules/cloud-functions.mdc` (handler + `<name>_logic.py` + `<name>_logic_test.py`). Do **not** run the scaffold script.

> **Prerequisite:** task CW-007 (the `functions/` codebase with `src/firestore.ts` → `db()`, `src/admin/assertAdmin.ts`, `src/admin/auditLog.ts`). Starter code: `references/cw-007-helpers.md`.

Every function is split in two so the important part is testable:

- `<name>.ts` — thin handler: auth → parse → read → call pure logic → one batch write → audit log.
- `<name>.logic.ts` — pure functions (validation, scoring, planning). No Firestore, no `firebase-functions`.
- `<name>.logic.test.ts` — Jest tests for every rule and every rejection.

## Step 1 — Generate

From the repo root:

```bash
python3 .claude/skills/cloud-function/scripts/scaffold_function.py \
  --name adminSaveQuestion --kind admin-callable --dir crossword
```

| `--kind` | Use for | Generated shape |
| --- | --- | --- |
| `admin-callable` | Anything the admin panel changes | `assertAdmin` → parse/validate → `db().batch()` → `writeAuditLog` |
| `player-callable` | Player actions the server must own (`submitCrossword`) | auth check → blocked check → parse → (TODO) |
| `scheduled` | Daily rollover, leaderboard refresh | `onSchedule` with `timeZone: "Asia/Kolkata"`; `--schedule "every 15 minutes"` |
| `trigger` | Reacting to a document write | `onDocumentWritten`; `--doc "path/{id}"` |

Names: admin callables **must** start with `admin`. Region is `asia-south1`.

Paste the printed export line into `functions/src/index.ts` (keep crossword exports together).

## Step 2 — Fill it in

1. Collection names from `functions/src/crossword/collections.ts` (CW-004) — never string literals.
2. Types from `functions/src/crossword/types.ts` (CW-012); field names exactly as `docs/firebase/FIREBASE_DESIGN.md`.
3. Put **all** decisions in the `.logic.ts` file. Validators collect every problem, then throw one error with a `problems` list.
4. Writes: one `WriteBatch` (or `runTransaction` when you read-then-write a counter). Set `updatedAt: FieldValue.serverTimestamp()` and `updatedBy`.
5. Errors to clients: `HttpsError("invalid-argument" | "not-found" | "failed-precondition" | "permission-denied", message)`. Messages are what an admin will read.
6. Player callables are **idempotent**: if the work is already done (e.g. progress `completed`), return the stored result.

## Step 3 — Verify

```bash
cd functions
npm run lint      # google style: double quotes, 2 spaces, max-len 100, JSDoc on exports
npm run build
npm test
firebase emulators:start --only functions,firestore   # then call from the admin panel / app
```

## Reference: what each crossword function must do

See `docs/firebase/FIREBASE_DESIGN.md` → "Flows" and the task cards CW-015 – CW-022 in `TASKS.md`. Key rules:

- **adminSaveCrosswordPuzzle** writes the puzzle (`draft`) and `crosswordSolutions/{id}` in the same batch; refuses unverified questions; runs the grid validator.
- **adminSetPuzzleStatus** only allows `draft→in_review→scheduled→published→archived`, `in_review→draft` and `in_review→published`; publish/archive update `publishedPuzzleCount` in a transaction.
- **submitCrossword** reads `crosswordSolutions` + progress, scores with pure functions, then one batch: progress result, `users/{uid}.xp` + `crossword` stats, `leaderboards/crossword-{isoWeek}/entries/{uid}`, `revisionItems`.
- Scheduled jobs keep reads bounded (`limit`) and log what they changed.

## Checklist

- [ ] Handler is thin; logic is pure and tested (happy path + every rejection)
- [ ] Admin: `assertAdmin` and `writeAuditLog` present; no `databaseId` parameter (DEC-002)
- [ ] Player: auth + blocked check + idempotent
- [ ] Exported from `src/index.ts`
- [ ] `npm run lint && npm run build && npm test` green
