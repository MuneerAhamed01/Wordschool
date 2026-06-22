# Phase 1 — Backend: Daily Case Generation

> **Status:** Complete  
> **Last updated:** 2026-06-21  
> **Owner:** —  
> **Depends on:** Phase 0  
> **Blocks:** Phase 2  

## Goal

Automatically generate one detective case per day via the Cursor Cloud Agents API, persist it to Firestore, and expose it for the Flutter app to consume.

## Scope

### In scope

- Firebase Cloud Functions project
- Scheduled daily job
- Cursor API integration with validation
- Firestore write pipeline
- Dev seed / manual fallback case
- Remote Config feature flag (optional v1) — **deferred to Phase 10**

### Out of scope (deferred)

- Flutter UI (Phase 2+)
- Leaderboard aggregation (Phase 6)
- Analytics events (Phase 10)
- Remote Config `story_mode_enabled` (Phase 10)

## Steps checklist

- [x] **Step 1.1** — Initialize `functions/` (Node/TypeScript), wire to Firebase project
- [x] **Step 1.2** — Scheduled cron job (e.g. daily midnight UTC) for case generation
- [x] **Step 1.3** — Cursor API integration: prompt template + response parsing
- [x] **Step 1.4** — Validate generated content (5-letter answers, dictionary-safe, 3 distinct clues)
- [x] **Step 1.5** — Idempotent Firestore write by date (skip if case already exists)
- [x] **Step 1.6** — Manual seed script / hardcoded dev case for local testing

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| AI provider | Cursor Cloud Agents API | User has Cursor API key; no separate Claude key | 2026-06-21 |
| Agent mode | No-repo cloud agent (`POST /v1/agents` without `repos`) | JSON generation only; no codebase needed | 2026-06-21 |
| Trigger | Cloud Scheduler + Pub/Sub | Reliable daily execution | — |
| Case ID | `yyyy-MM-dd` in UTC | Global shared daily case | — |
| Idempotency | Check doc exists before write; `create()` catches `already-exists` | Safe cron retries | 2026-06-21 |
| Cursor model | `composer-2.5` (override via `CURSOR_MODEL`) | Default Cursor agent model | 2026-06-21 |
| Generation failure | Up to 3 retries, no partial write, Cloud Logging | Manual seed as fallback | 2026-06-21 |
| Answer word list | Shared `assets/words/answers.txt` (loaded at runtime) | Same source as Flutter `ValidWords` | 2026-06-21 |
| Seed auth | `SEED_SECRET` Firebase secret on callable | Separate from Cursor key | 2026-06-21 |
| Function timeout | 540s on scheduled + callable | Cursor agent polling can take several minutes | 2026-06-21 |
| Remote Config | Deferred to Phase 10 | Optional v1; not blocking Phase 2 | 2026-06-21 |

## Content generation pipeline

```
Cloud Scheduler (daily)
    ↓
Cloud Function: generateDailyCase
    ↓
Cursor Cloud Agents API (no-repo agent, structured prompt)
    ↓
Validate answers + narrative fields
    ↓
Firestore: detectiveCases/{date}
    ↓
Flutter App reads case (Phase 2)
```

## Prompt requirements

Generated content must include:

- Case title and introduction
- 3 clues: location, weapon, suspect
- Per clue: hint, 5-letter answer, investigate prompt, reaction text
- Final resolution narrative

Validation rules:

- Each answer exactly 5 letters, A–Z only
- Answers distinct from each other
- Answers exist in app word list (`assets/words/answers.txt`) or approved dictionary

## Files / modules touched

| Path | Change |
| ---- | ------ |
| `.firebaserc` | New — default project `wordschool-dev` |
| `firebase.json` | Updated — functions, firestore rules, emulators |
| `functions/` | New — Cloud Functions project |
| `functions/src/index.ts` | Exports scheduled + callable functions |
| `functions/src/generateDailyCase.ts` | Scheduled `generateDailyCase` |
| `functions/src/generateDailyCaseCore.ts` | Shared generation + idempotency logic |
| `functions/src/caseWriter.ts` | Firestore read/write |
| `functions/src/cursor/` | Cursor API client, prompts, JSON parsing |
| `functions/src/validation/` | Case validation + answer word loader |
| `functions/src/seedCase.ts` | Callable `seedDetectiveCase` |
| `functions/src/scripts/seed.ts` | Local `npm run seed` script |
| `firestore.rules` | From Phase 0 (unchanged) |

## Environment / secrets

- `CURSOR_API_KEY` — Firebase Functions secret (Cursor Dashboard → API Keys)
- `SEED_SECRET` — Firebase Functions secret (callable seed auth)
- `CURSOR_MODEL` — optional env override (default `composer-2.5`)
- Firebase Admin SDK for Firestore writes

## Deploy and local testing

**Prerequisites:**
- Node.js 20+ (`brew install node@20`)
- Firebase CLI: `npx -y firebase-tools@latest login`
- **Billing enabled** on `wordschool-dev` (required for Cloud Functions / Artifact Registry)
- Firestore emulator requires **JDK 21+** if testing locally with emulators
- Secrets: `CURSOR_API_KEY`, `SEED_SECRET`

```bash
# Install and verify
cd functions
npm install
npm test
npm run build

# Set secrets (once per project)
npx -y firebase-tools@latest functions:secrets:set CURSOR_API_KEY --project wordschool-dev
npx -y firebase-tools@latest functions:secrets:set SEED_SECRET --project wordschool-dev

# Emulator
npx -y firebase-tools@latest emulators:start --only functions,firestore
# In another terminal:
cd functions && FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm run seed -- --date 2026-06-21

# Deploy (requires billing on Firebase project)
npx -y firebase-tools@latest deploy --only functions,firestore:rules --project wordschool-dev
```

**Deploy note (2026-06-21):** Deploy to `wordschool-dev` failed with `Billing account for project is not open`. Enable billing in Firebase/GCP console, then re-run deploy.

Callable seed (example):

```bash
# After deploy, from client or REST with secret in request data
{ "secret": "<SEED_SECRET>", "useExample": true, "dateId": "2026-06-21" }
# Or live generation via Cursor:
{ "secret": "<SEED_SECRET>", "dateId": "2026-06-21" }
```

## Acceptance criteria

- [x] Cron runs without duplicate cases on retry (idempotent `caseExists` + `create()`)
- [x] Invalid AI output is rejected and logged (no partial write)
- [x] Dev seed populates a readable case in Firestore emulator or staging (`npm run seed`)
- [x] Generated case matches Phase 0 schema (validated before write)

## Testing notes

- `npm test` — Jest unit tests for validation and JSON parsing
- Run function locally with Firebase emulator
- Test idempotency: run seed twice for same date → single document (second run `skipped`)
- Test validation failure path with malformed Cursor response (unit tests)

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| 2026-06-21 | Steps 1.1–1.6 | Functions scaffold, Cursor API pipeline, validation, scheduled job, seed script/callable |
| 2026-06-21 | Provider switch | Replaced Claude/Anthropic with Cursor Cloud Agents API (`CURSOR_API_KEY`) |

## Open questions / blockers

_Resolved:_

- **AI provider:** Cursor Cloud Agents API with `CURSOR_API_KEY`
- **Cursor model:** `composer-2.5`, overridable via `CURSOR_MODEL`
- **Fallback if generation fails:** 3 retries, no write, Cloud Logging; use `npm run seed` or callable with `useExample: true`
