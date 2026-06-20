# Phase 1 — Backend: Daily Case Generation

> **Status:** Not started  
> **Last updated:** —  
> **Owner:** —  
> **Depends on:** Phase 0  
> **Blocks:** Phase 2  

## Goal

Automatically generate one detective case per day via Claude API, persist it to Firestore, and expose it for the Flutter app to consume.

## Scope

### In scope

- Firebase Cloud Functions project
- Scheduled daily job
- Claude API integration with validation
- Firestore write pipeline
- Dev seed / manual fallback case
- Remote Config feature flag (optional v1)

### Out of scope (deferred)

- Flutter UI (Phase 2+)
- Leaderboard aggregation (Phase 6)
- Analytics events (Phase 10)

## Steps checklist

- [ ] **Step 1.1** — Initialize `functions/` (Node/TypeScript), wire to Firebase project
- [ ] **Step 1.2** — Scheduled cron job (e.g. daily midnight UTC) for case generation
- [ ] **Step 1.3** — Claude API integration: prompt template + response parsing
- [ ] **Step 1.4** — Validate generated content (5-letter answers, dictionary-safe, 3 distinct clues)
- [ ] **Step 1.5** — Idempotent Firestore write by date (skip if case already exists)
- [ ] **Step 1.6** — Manual seed script / hardcoded dev case for local testing

## Technical decisions

| Decision | Choice | Rationale | Date |
| -------- | ------ | --------- | ---- |
| AI provider | Claude API | Per fulldoc.md | — |
| Trigger | Cloud Scheduler + Pub/Sub | Reliable daily execution | — |
| Case ID | `yyyy-MM-dd` in UTC | Global shared daily case | — |
| Idempotency | Check doc exists before write | Safe cron retries | — |

## Content generation pipeline

```
Cloud Scheduler (daily)
    ↓
Cloud Function: generateDailyCase
    ↓
Claude API (structured prompt)
    ↓
Validate answers + narrative fields
    ↓
Firestore: detectiveCases/{date}
    ↓
(Optional) Remote Config: story_mode_enabled
    ↓
Flutter App reads case
```

## Claude prompt requirements

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
| `functions/` | New — Cloud Functions project |
| `functions/src/generateDailyCase.ts` | New — scheduled generator |
| `functions/src/claude/` | New — API client + prompts |
| `functions/src/seedCase.ts` | New — manual dev seed |
| `firestore.rules` | From Phase 0 |

## Environment / secrets

- `CLAUDE_API_KEY` — Firebase Functions secret or env config
- Firebase Admin SDK for Firestore writes

## Acceptance criteria

- [ ] Cron runs without duplicate cases on retry
- [ ] Invalid AI output is rejected and logged (no partial write)
- [ ] Dev seed populates a readable case in Firestore emulator or staging
- [ ] Generated case matches Phase 0 schema

## Testing notes

- Run function locally with Firebase emulator
- Test idempotency: run twice for same date → single document
- Test validation failure path with malformed Claude response

## Completion log

| Date | Step completed | Notes |
| ---- | -------------- | ----- |
| — | — | — |

## Open questions / blockers

- Which Claude model and max tokens for cost/latency balance?
- Fallback if generation fails — retry, use yesterday's template, or alert?
