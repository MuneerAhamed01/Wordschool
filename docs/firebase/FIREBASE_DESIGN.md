# Firebase Design — PSC Crossword (Phase 1)

> **Status:** Approved for build · **Branch:** `psc-dev` · **Project (dev):** `kerala-pcs-dev` · **Last updated:** 2026-10-23 · **Tasks:** CW-004 – CW-024, CW-055 in `TASKS.md`
> This file is the source of truth. The older shared doc (https://claude.ai/artifact/MFySVtYQEnWF5U3QF94bMH) was written for the `development` branch (`userGameStates`, `databaseId`) — where they differ, this file wins.

PSC Crossword adds **9 Firestore collections** to the Kerala PSC Firebase project. Only admins can create or change content, scores are computed on the server, and the cost is **$0 up to ~2,000 daily players** and **under $5/month at 10,000**.

**Contents:** [Decisions](#decisions) · [Design rules](#design-rules) · [At a glance](#at-a-glance) · [Collections](#collections) · [Flows](#flows) · [Security rules](#security-rules) · [Indexes](#indexes) · [Cloud Functions](#cloud-functions) · [Cost](#cost) · [Later phases](#later-phases)

---

## Decisions

1. **Content is written only by Cloud Functions.** The admin panel calls admin callables (`admin` custom claim → `assertAdmin`); every change goes to `adminAuditLog`. Rules say `allow write: if false` on content. Admins sign in to the panel with **email + password** (Auth Email/Password provider, CW-037); there is no sign-up — accounts, passwords and the claim come from `functions/scripts/set_admin_claim.py --password`. Players sign in with Google or as a guest (anonymous).
2. **A question bank sits under puzzles.** Each PSC fact lives once in `pscQuestions`, is verified, then copied into puzzles. Later games reuse it.
3. **One puzzle = one document.** Opening a puzzle costs 1 read. Answers ship **encoded** for offline Check/Reveal; the real key is in private `crosswordSolutions`.
4. **Scores are server-side.** The app saves in-progress letters; finishing goes through `submitCrossword`, which scores, gives XP, updates the leaderboard and saves mistakes in one batch.
5. **One project per environment.** Dev = `kerala-pcs-dev`, prod = a separate project (CW-076), both on the `(default)` database — so functions never take a `databaseId` (DEC-002). The player root is `users/{uid}` (DEC-006).
6. **Everything lives in Mumbai (`asia-south1`).** Firestore `(default)` and all Cloud Functions run in `asia-south1`, close to players in Kerala. Firestore's location can't change after creation, so prod (CW-076) must also pick `asia-south1` when its database is created. (`kerala-pcs-dev` was first created in `nam5` on 2026-10-22 and recreated in `asia-south1` under CW-008.)

---

## Design rules

Apply these to every future collection too.

| Rule | What it means | Why |
| --- | --- | --- |
| Content is admin-only | App reads content, never writes it. Only functions write. | Players can't tamper; every change is logged |
| Read the way the screen needs it | Each screen loads in 1–3 reads; copy (denormalize) data into the doc the screen reads | Firestore bills per document read |
| Server owns scores | XP, streaks, leaderboard, results written only by functions | No cheating; trustworthy numbers |
| Batch progress saves | Save on pause, on leave, or every 30 s — never per keystroke | Per-keystroke saving = 50–100 writes per puzzle |
| Never hard-delete content | `status: "archived"` | Results and revision items still point to it |
| Bilingual text | Every visible text is `{ "en": "…", "ml": "…" }` | Malayalam later without schema change |
| Version content docs | `schemaVersion: 1` | Handle old + new shapes during upgrades |
| Standard metadata | `createdAt`, `updatedAt` (server time), `createdBy`, `updatedBy` (admin uid) | Debugging and audits |
| Naming | Collections plural camelCase; fields camelCase; enum values `snake_case`; readable IDs | Matches current code; readable in console |
| Dates | Crossword daily keys `YYYY-MM-DD` in **Asia/Kolkata**; weeks ISO (`2026-W43`) | Same puzzle for everyone at Indian midnight (DEC-001) |
| Free tools first | Flags, level formula, min version in **Remote Config** | Saves a read on every app open |

---

## At a glance

```mermaid
flowchart LR
  AP[Admin panel<br/>admin claim] -->|calls| AF[Admin functions<br/>save · verify · publish<br/>→ adminAuditLog]
  AF -->|writes| C[(Content<br/>crosswordCategories<br/>crosswordPuzzles<br/>crosswordDaily<br/>pscQuestions · private<br/>crosswordSolutions · private)]
  PA[Player app] -->|reads published| C
  PA -->|on finish| SC[submitCrossword<br/>reads crosswordSolutions<br/>scores · one batch]
  SC -->|writes| P[(Player data<br/>users · xp, stats<br/>crosswordProgress<br/>revisionItems<br/>leaderboards<br/>contentReports)]
  PA -->|saves progress, files reports| P
  SJ[Scheduled jobs<br/>daily rollover 00:05 IST<br/>top50 every 15 min] -->|writes| C
  SJ -->|writes| P
```

| # | Collection | Who writes | App reads? |
| --- | --- | --- | --- |
| 1 | `crosswordCategories/{categoryId}` | Admin functions | Active only |
| 2 | `pscQuestions/{questionId}` | Admin functions | **No** |
| 3 | `crosswordPuzzles/{puzzleId}` | Admin functions | Published only |
| 4 | `crosswordSolutions/{puzzleId}` | Admin functions | **No** |
| 5 | `crosswordDaily/{YYYY-MM-DD}` | Scheduled job / admin | Yes |
| 6 | `users/{uid}/crosswordProgress/{puzzleId}` | Player (in progress) + `submitCrossword` | Own |
| 7 | `users/{uid}/revisionItems/{questionId}` | `submitCrossword` (+ player toggles `mastered`) | Own |
| 8 | `leaderboards/{boardId}/entries/{uid}` | `submitCrossword` + scheduled job | Signed-in |
| 9 | `contentReports/{reportId}` | Player (create only) | **No** |

Plus the player root `users/{uid}`: profile fields written by the app, `xp` / `crossword` / `rateLimit` / `blockedAt` written only by the server.

---

## Collections

Every content document also has `schemaVersion`, `createdAt`, `updatedAt`, `createdBy`, `updatedBy` (not repeated below).

### 1. `crosswordCategories/{categoryId}` — Home categories

ID = slug (`kerala-history`). A question's `subject` is its category: `kerala_history` ↔ `kerala-history` (`_` → `-`).

| Field | Type | Example / notes |
| --- | --- | --- |
| `name` | map | `{ "en": "Kerala History", "ml": "കേരള ചരിത്രം" }` |
| `description` | map | Short line under the name |
| `icon` | string | Icon key mapped to an asset, e.g. `landmark` |
| `color` | string | Hex accent, e.g. `#6AAA64` |
| `order` | number | Sort on Home (10, 20, 30…) |
| `isActive` | bool | Hide without deleting |
| `publishedPuzzleCount` | number | Maintained by `adminSetPuzzleStatus` and the daily rollover |
| `lastPuzzleNumber` | number | Highest puzzle `number` used; `adminSaveCrosswordPuzzle` takes the next one in a transaction |

### 2. `pscQuestions/{questionId}` — Verified fact bank (private)

Auto ID. Never read by the app.

| Field | Type | Example / notes |
| --- | --- | --- |
| `answer` | string | `VAIKOM` — uppercase A–Z, no spaces |
| `answerDisplay` | map | `{ "en": "Vaikom", "ml": "വൈക്കം" }` |
| `clues` | array<map> | `[{ "en": "1924–25 satyagraha for temple road entry", "level": "medium" }]` |
| `fact` | map | Learn-card text |
| `subject` | string | `kerala_history` |
| `topic` | string | `renaissance` |
| `examTags` | array | `["ldc", "lgs", "degree_level"]` |
| `difficulty` | string | `easy` · `medium` · `hard` |
| `source` | map | `{ "type": "pyq", "ref": "LDC 2017, Q42" }` |
| `status` | string | `draft` → `verified` → `retired` |
| `verifiedBy` / `verifiedAt` | string / timestamp | |
| `usedInPuzzles` | array | Puzzle ids |

### 3. `crosswordPuzzles/{puzzleId}` — One playable puzzle

ID `{categoryId}-{0000}` (`kerala-history-0012`). Typical size 5–10 KB.

| Field | Type | Example / notes |
| --- | --- | --- |
| `categoryId` | string | `kerala-history` |
| `number` | number | `12` |
| `title` | map | `{ "en": "Kerala Renaissance and Trade" }` |
| `difficulty` | string | `easy` · `medium` · `hard` |
| `rows`, `cols` | number | `8`, `8` (max 15) |
| `layout` | string | `rows × cols` chars row by row; `.` letter, `#` block |
| `words` | array<map> | Below |
| `wordCount` | number | `7` — `words.length`, copied into `crosswordDaily` |
| `xpReward` | number | `50` |
| `estimatedMinutes` | number | `6` |
| `status` | string | `draft` · `in_review` · `scheduled` · `published` · `archived` |
| `publishAt` | timestamp | For `scheduled` |
| `publishedAt` | timestamp | Set on publish |

Each `words` item:

| Field | Type | Example |
| --- | --- | --- |
| `id` | string | `2D` |
| `number`, `direction` | number, string | `2`, `down` |
| `row`, `col`, `length` | number | `2`, `2`, `6` |
| `clue` | map | `{ "en": "1924–25 satyagraha for the right to use temple roads" }` |
| `extraClue` | map | Free "Show a clue" hint |
| `fact` | map | Copied from the question |
| `answerEnc` | string | See [Answer encoding](#answer-encoding) |
| `questionId` | string | Link to `pscQuestions` |

Full example (admin input form, before encoding): `.claude/skills/crossword-content/examples/kerala-history-0012.puzzle.json`.

#### Answer encoding

```
answerEnc = base64( utf8(answer) XOR utf8(puzzleId + ":" + wordId) )   // key repeated over the answer
```

Obfuscation only. The server re-checks with `crosswordSolutions`. Fixture: `VAIKOM`, `kerala-history-0012`, `2D` → `PSQ7KiMs`.

### 4. `crosswordSolutions/{puzzleId}` — Answer key (private)

`{ "answers": { "1A": "MUZIRIS", "2D": "VAIKOM" } }` — read only by `submitCrossword`.

### 5. `crosswordDaily/{YYYY-MM-DD}` — Today's pointer (IST date)

`puzzleId`, `categoryId`, `title`, `difficulty`, `wordCount`, `xpReward`, `estimatedMinutes`.

### 6. `users/{uid}/crosswordProgress/{puzzleId}` — Player state

| Field | Type | Notes |
| --- | --- | --- |
| `status` | string | `in_progress` · `completed` |
| `letters` | string | Same length as `layout`; `.` = empty |
| `elapsedSec` | number | Only goes up |
| `hintsUsed` | map | `{ "letter": 1, "word": 0, "clue": 2 }` — only goes up |
| `checksUsed` | number | Only goes up |
| `startedAt`, `updatedAt` | timestamp | |
| `result` | map | Server: `{ score, correctWords, totalWords, xpEarned, timeSec, wrongWordIds[], revealedWordIds[] }` — `wrongWordIds` includes revealed words |
| `completedAt` | timestamp | Server |

### 7. `users/{uid}/revisionItems/{questionId}` — "My mistakes"

Server upserts on every wrong or revealed word. Fields: `answer`, `answerDisplay`, `clue`, `fact`, `subject`, `source` (`{ "game": "crossword", "puzzleId": "…" }`), `wrongCount`, `lastWrongAt`, `mastered` (player may toggle only this), `nextReviewAt` (reserved), `updatedAt`.

### 8. `leaderboards/{boardId}/entries/{uid}` — Weekly ranks

`boardId = {game}-{isoWeek}` → `crossword-2026-W43`. Parent doc: `top50` array + `updatedAt` (refreshed every 15 min). Entry: `displayName`, `photoUrl`, `points`, `puzzlesSolved`, `updatedAt`.

### 9. `contentReports/{reportId}` — "Report a wrong answer"

`uid`, `puzzleId`, `wordId`, `questionId`, `reason` (`wrong_answer` · `typo` · `other`), `message` (≤ 500), `status` (`open` · `fixed` · `rejected`), `createdAt`. Set by `adminResolveReport`: `resolvedBy`, `resolvedAt`, `resolutionNote`.

### `users/{uid}` — Player root (DEC-006)

Already reserved in `FirebaseCollections.users` on psc-dev. `submitCrossword` creates the doc (with only server fields) if the player has none yet, so the app's profile write (CW-055) must handle an existing doc: `update` the profile fields instead of `create`.

| Field | Written by | Notes |
| --- | --- | --- |
| `displayName` | App (CW-055) | Google name, or "Guest 1234" |
| `photoUrl` | App | nullable |
| `isAnonymous` | App | |
| `createdAt` | App, on create only | server timestamp |
| `lastSeenAt` | App | server timestamp |
| `xp` | **Server** | Total across games. Level computed in the app from Remote Config `xp_level_formula` |
| `crossword` | **Server** | `{ played, solved, currentStreak, longestStreak, lastSolvedDate, bestTimeSec }` |
| `rateLimit` | **Server** | `{ submitWindowStart, submitCount }` for `submitCrossword` |
| `blockedAt` | **Server / admin** | Set to block a player |

---

## Flows

### Admin: fact → live puzzle

1. **Add facts** → `adminSaveQuestion` (`status: draft`). A subject with no category creates that category, hidden (CW-064).
2. **Verify** → `adminVerifyQuestion` (`verified`, `verifiedBy`). Only verified facts go into puzzles.
3. **Build** → `adminSaveCrosswordPuzzle` validates the grid, saves the puzzle (`draft`) and `crosswordSolutions` in one batch.
4. **Review** → `adminSetPuzzleStatus`: `in_review` → `scheduled` (+ `publishAt`), or publish now.
5. **Go live** → `crosswordDailyRollover` at 00:05 IST publishes due puzzles; `adminScheduleDaily` sets `crosswordDaily/{date}`.
6. **Fix / retire** → edit (audited) or `archived`.

```mermaid
stateDiagram-v2
  [*] --> draft
  draft --> in_review
  in_review --> draft
  in_review --> scheduled
  scheduled --> published
  in_review --> published
  scheduled --> scheduled: change publishAt
  published --> archived
```

### Player: open and play

1. **Home** reads, in parallel: `crosswordDaily/{today IST}`, categories with `isActive == true` (sorted by `order` in the app — no composite index), own `users/{uid}`, a `count()` of own `revisionItems` with `mastered == false`, own progress for **today's puzzle only**, and per category a `count()` of own `crosswordProgress` with `status == completed` and the doc id between `{categoryId}-0000` and `{categoryId}-9999` (equality + `__name__` range: served by the single-field index). The whole progress collection is **never** read. Results are kept for the session (`CrosswordProgressRepository`): saves update the cache at once, a first submit bumps the category count, so returning from a puzzle costs no reads. *CW-057's summary doc would replace the per-category counts.*
2. **Category list**: published puzzles in the category, `number` desc, 20 per page (`startAfter(number)`); marks for the page's puzzles with one `in` query on the doc id (≤ 20 ids, ≤ 30 allowed), cached.
3. **Puzzle**: puzzle doc + own progress doc (from the cache when known). Revealed squares/words are kept on the device (SharedPreferences, key `crossword.reveals.{puzzleId}`) because the rules don't allow them on the progress doc; they're cleared after submit. Opening a completed puzzle calls `submitCrossword` again, which returns the stored result (no writes).
4. **Play**: Check / Reveal / Show clue are offline; progress saved on pause, leave, or every `crossword_autosave_seconds` (30) while changed — never per key, and never a new doc for a puzzle that was only looked at; reveals are limited per puzzle (DEC-008).
5. **Revise**: own `revisionItems`, `mastered == false`, `lastWrongAt` desc then doc id desc, 20 per page with `startAfter([lastWrongAt, questionId])` — one submit stamps all its mistakes with the same `lastWrongAt`, so the id breaks ties (the `mastered, lastWrongAt desc` index already orders by `__name__` desc). "Mark as learned" updates `mastered` + `updatedAt`, and Home re-counts.
6. **Ranks**: `leaderboards/crossword-{IST ISO week}` (`top50`) + own `entries/{uid}` + `count()` of entries with more points (rank = count + 1).
7. **Profile doc** (CW-055): after sign-in and on each app start, `users/{uid}` gets `displayName` (Google name or "Guest 1234", ≤ 40), `photoUrl`, `isAnonymous`, `lastSeenAt` (+ `createdAt` on create) — in a transaction: `update` when the doc exists (e.g. made by `submitCrossword`), `set` with `createdAt` otherwise, so a doc created in between retries as an update. Not awaited by sign-in.

### Player: finish

1. App calls `submitCrossword({ puzzleId, letters, elapsedSec, hintsUsed, revealedWordIds })`.
2. Function reads `crosswordSolutions` + progress (time and hints never lower than saved progress); scores each word; a revealed word counts as wrong. `score` = % of words correct; XP = round(`xpReward` × correct ÷ total) − 5 per revealed letter − 15 per revealed word (min 0; penalties from Remote Config `crossword_hint_penalties`). Rules in DEC-011.
3. One batch: progress `result` + `completed`; `users/{uid}.xp` + `crossword` stats; `leaderboards/crossword-{week}/entries/{uid}`; `revisionItems` for wrong/revealed words.
4. Returns the result — the Results screen needs no extra reads.
5. Calling again returns the stored result (idempotent).

---

## Security rules

`firestore.rules` is exactly the block below (CW-010); keep the two in sync. Allow/deny tests for every collection are in `firestore-tests/` (`npm test`, Firestore emulator). Cloud Functions use the Admin SDK and bypass rules.

| Collection | App can read | App can write |
| --- | --- | --- |
| `games` (daily word game) | Signed-in | Create (unchanged for now) |
| `users/{uid}` | Own | Profile fields only |
| `crosswordCategories` | Active only | No |
| `crosswordPuzzles` | Published only | No |
| `crosswordDaily` | Signed-in | No |
| `pscQuestions`, `crosswordSolutions`, `adminAuditLog` | No | No |
| `users/{uid}/crosswordProgress` | Own | Create/update while `in_progress`; values only go up |
| `users/{uid}/revisionItems` | Own | Only `mastered` |
| `leaderboards` | Signed-in | No |
| `contentReports` | No | Create only |

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ---------- Helpers ----------
    function isAuthenticated() {
      return request.auth != null;
    }
    function isOwner(uid) {
      return isAuthenticated() && request.auth.uid == uid;
    }
    function isNotBlocked(uid) {
      return !exists(/databases/$(database)/documents/users/$(uid))
        || get(/databases/$(database)/documents/users/$(uid)).data.get('blockedAt', null) == null;
    }
    function isDateId(id) {
      return id.matches('^\\d{4}-\\d{2}-\\d{2}$');
    }
    function isNonNegativeInt(n) {
      return n is int && n >= 0;
    }
    function isHintCount(h) {
      return h is map
        && h.keys().hasAll(['letter', 'word', 'clue'])
        && h.keys().hasOnly(['letter', 'word', 'clue'])
        && isNonNegativeInt(h.letter)
        && isNonNegativeInt(h.word)
        && isNonNegativeInt(h.clue);
    }
    function isCrosswordProgress(d) {
      return d.status == 'in_progress'
        && d.letters is string && d.letters.size() <= 400
        && isNonNegativeInt(d.elapsedSec)
        && isNonNegativeInt(d.checksUsed)
        && isHintCount(d.hintsUsed)
        && d.updatedAt == request.time;
    }
    function isProfile(d) {
      return d.displayName is string && d.displayName.size() <= 40
        && (!('photoUrl' in d) || d.photoUrl == null || d.photoUrl is string)
        && d.isAnonymous is bool
        && d.lastSeenAt == request.time;
    }

    // ---------- Daily word game (existing; tighten when it moves server-side) ----------
    match /games/{gameId} {
      allow read, create: if isAuthenticated();
    }

    // ---------- Player root ----------
    match /users/{uid} {
      allow read: if isOwner(uid);

      allow create: if isOwner(uid)
        && request.resource.data.keys().hasOnly(['displayName', 'photoUrl', 'isAnonymous',
             'createdAt', 'lastSeenAt'])
        && isProfile(request.resource.data)
        && request.resource.data.createdAt == request.time;

      allow update: if isOwner(uid) && isNotBlocked(uid)
        && request.resource.data.diff(resource.data).affectedKeys()
             .hasOnly(['displayName', 'photoUrl', 'isAnonymous', 'lastSeenAt'])
        && isProfile(request.resource.data);

      allow delete: if false;

      match /crosswordProgress/{puzzleId} {
        allow read: if isOwner(uid);

        allow create: if isOwner(uid) && isNotBlocked(uid)
          && request.resource.data.keys().hasOnly(['status', 'letters', 'elapsedSec',
               'hintsUsed', 'checksUsed', 'startedAt', 'updatedAt'])
          && isCrosswordProgress(request.resource.data)
          && request.resource.data.startedAt == request.time
          && get(/databases/$(database)/documents/crosswordPuzzles/$(puzzleId)).data.status == 'published';

        // Only while in progress; time, hints and checks can only go up.
        allow update: if isOwner(uid) && isNotBlocked(uid)
          && resource.data.status == 'in_progress'
          && request.resource.data.diff(resource.data).affectedKeys()
               .hasOnly(['letters', 'elapsedSec', 'hintsUsed', 'checksUsed', 'updatedAt'])
          && isCrosswordProgress(request.resource.data)
          && request.resource.data.letters.size() == resource.data.letters.size()
          && request.resource.data.elapsedSec >= resource.data.elapsedSec
          && request.resource.data.checksUsed >= resource.data.checksUsed
          && request.resource.data.hintsUsed.letter >= resource.data.hintsUsed.letter
          && request.resource.data.hintsUsed.word >= resource.data.hintsUsed.word
          && request.resource.data.hintsUsed.clue >= resource.data.hintsUsed.clue;

        allow delete: if false;
      }

      match /revisionItems/{questionId} {
        allow read: if isOwner(uid);
        allow update: if isOwner(uid) && isNotBlocked(uid)
          && request.resource.data.diff(resource.data).affectedKeys()
               .hasOnly(['mastered', 'updatedAt'])
          && request.resource.data.mastered is bool
          && request.resource.data.updatedAt == request.time;
        allow create, delete: if false;
      }
    }

    // ---------- PSC Crossword content (written only by Cloud Functions) ----------
    match /crosswordCategories/{categoryId} {
      allow read: if isAuthenticated() && resource.data.isActive == true;
      allow write: if false;
    }
    match /crosswordPuzzles/{puzzleId} {
      allow read: if isAuthenticated() && resource.data.status == 'published';
      allow write: if false;
    }
    match /crosswordDaily/{dateId} {
      allow read: if isAuthenticated() && isDateId(dateId);
      allow write: if false;
    }

    // ---------- Weekly leaderboards (server-written) ----------
    match /leaderboards/{boardId} {
      allow read: if isAuthenticated();
      allow write: if false;
      match /entries/{userId} {
        allow read: if isAuthenticated();
        allow write: if false;
      }
    }

    // ---------- Player reports: create only ----------
    match /contentReports/{reportId} {
      allow create: if isAuthenticated() && isNotBlocked(request.auth.uid)
        && request.resource.data.keys().hasOnly(['uid', 'puzzleId', 'wordId',
             'questionId', 'reason', 'message', 'status', 'createdAt'])
        && request.resource.data.uid == request.auth.uid
        && request.resource.data.reason in ['wrong_answer', 'typo', 'other']
        && request.resource.data.message is string
        && request.resource.data.message.size() <= 500
        && request.resource.data.status == 'open'
        && request.resource.data.createdAt == request.time;
      allow read, update, delete: if false;
    }

    // ---------- Everything else (pscQuestions, crosswordSolutions, adminAuditLog, …) ----------
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

> Rules are not filters: queries must include `where('isActive', isEqualTo: true)` (categories) and `where('status', isEqualTo: 'published')` (puzzles).

---

## Indexes

Merge into `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "crosswordPuzzles",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "categoryId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "number", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "crosswordPuzzles",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "categoryId", "order": "ASCENDING" },
        { "fieldPath": "number", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "revisionItems",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "mastered", "order": "ASCENDING" },
        { "fieldPath": "lastWrongAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "pscQuestions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "subject", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "updatedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "pscQuestions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "subject", "order": "ASCENDING" },
        { "fieldPath": "updatedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "pscQuestions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "updatedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "contentReports",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ],
  "fieldOverrides": [
    { "collectionGroup": "crosswordPuzzles", "fieldPath": "words", "indexes": [] },
    { "collectionGroup": "crosswordProgress", "fieldPath": "letters", "indexes": [] }
  ]
}
```

`contentReports` (status + newest first) is for `adminListReports`. `pscQuestions` (subject and/or status + recently updated first) and `crosswordPuzzles` (category, any status, newest number first) are for the admin read callables. Leaderboard `orderBy('points', 'desc')`, rank `where('points', '>', mine).count()` and the rollover's `where('status', '==', 'scheduled')` use automatic single-field indexes. `firestore.indexes.json` is exactly this block.

---

## Cloud Functions

In `functions/crossword/` (Python codebase created in CW-007, DEC-010), region `asia-south1`. Deployed names below are what the apps call. Admin callables: `assert_admin` → validate → `db().batch()` → `write_audit_log`. No `databaseId` parameter (DEC-002).

| Function | Type | Caller | Does |
| --- | --- | --- | --- |
| `adminSaveCategory` | Callable | Admin | Create/edit category |
| `adminSaveQuestion` | Callable | Admin | Create/edit fact; answer A–Z; edit of verified → draft. Same transaction: if `crosswordCategories/{subject, _ → -}` is missing, creates it (CW-064) with the `adminSaveCategory` fields — `name.en` Title Case of the subject, `name.ml` `""`, icon `folder`, color `#538D4E`, order 1000, **`isActive: false`**, counters 0 — and audits `crossword.autoCreateCategory` (`payload {subject, questionId}`). An existing category is never touched. Returns `{id, created, status, createdCategoryId}` (`null` unless created) |
| `adminVerifyQuestion` | Callable | Admin | `draft → verified` |
| `adminSaveCrosswordPuzzle` | Callable | Admin | Validate grid; save puzzle + solution in one batch; encode answers |
| `adminSetPuzzleStatus` | Callable | Admin | Status state machine; category count |
| `adminScheduleDaily` | Callable | Admin | Set daily puzzle for a date |
| `adminListReports` / `adminResolveReport` | Callable | Admin | Review player reports |
| `adminListCategories` | Callable | Admin | All categories, active or not, by `order` |
| `adminListQuestions` | Callable | Admin | Page questions (20), filter by `subject` / `status`, recently updated first |
| `adminListPuzzles` | Callable | Admin | Page a category's puzzles in any status (no grid), newest number first |
| `adminGetPuzzle` | Callable | Admin | One puzzle + plain answers from `crosswordSolutions`, for editing |
| `adminGetQuestion` | Callable | Admin | One question by id (reports page, CW-035) |
| `submitCrossword` | Callable | Player | Score; one batch: result, XP, stats, leaderboard, revision |
| `crosswordDailyRollover` | Scheduled 00:05 IST | System | Publish due puzzles; log an error if today or tomorrow has no daily doc |
| `refreshLeaderboardTop` | Scheduled 15 min | System | Copy top 50 into parent doc (first run of a week finishes last week's board) |

Admin reads go through callables, not rules: no client token can read `pscQuestions` or `crosswordSolutions`, admin or not (CW-025).

`submitCrossword` takes hint penalties from the **client** Remote Config template's `crossword_hint_penalties` default value (cached 5 min per instance; last good value or 5/15 if the fetch fails), so one console change applies to the app and the server (CW-026). Conditional values are ignored.

`submitCrossword` also rejects impossible results (`elapsedSec < wordCount × 2`) and allows 30 calls/hour/player (`users/{uid}.rateLimit`).

---

## Cost

**$0 up to ~2,000 daily players; ≈ $3/month at 10,000; ≈ $20/month at 50,000** — assuming one puzzle per player per day.

Per player per day ≈ **20 reads** (Home 3, list ≤ 10, puzzle 2, results/ranks 3, revision 2) and **9 writes** (4 progress saves + submit batch of 5). Leaderboard refresh adds 4,800 reads/day total.

App (M3) per session start: Home ≈ 4 reads + 1 per progress doc (one-time, cached) + 1 aggregation; puzzle 2; ranks 3 (board, own entry, count); profile write 1 read + 1 write. A heavy player with 100 played puzzles pays ~100 extra reads per session start until CW-057 replaces the progress scan with a server-kept summary.

| Daily players | Reads / day | Writes / day | Firestore / month |
| --- | --- | --- | --- |
| 1,000 | 25,000 | 9,000 | $0 |
| 2,000 | 45,000 | 18,000 | $0 |
| 10,000 | 205,000 | 90,000 | ≈ $3.30 |
| 50,000 | 1,005,000 | 450,000 | ≈ $20 |

Firestore Standard: free 50,000 reads, 20,000 writes, 1 GiB per day on the `(default)` database; then $0.03 / 100k reads and $0.09 / 100k writes ([pricing](https://cloud.google.com/firestore/pricing), checked 2026-10-22). Each project's `(default)` database gets its own free quota. Functions stay inside 2M free invocations/month even at 50,000 players, but **need the Blaze plan** (CW-008).

**Keep it low:** no list listeners · offline cache on · paginate at 20 · read `top50` not entries · batch progress saves · App Check on Firestore + Functions · budget alerts at $10 and $25.

---

## Later phases

| Shared piece | Phase 1 | Later |
| --- | --- | --- |
| `pscQuestions` | Crossword words | Clue Wordle, Map Challenge facts (`geo` fields), quizzes |
| `users/{uid}.xp` | Crossword XP | One XP/level across games |
| `revisionItems` | Crossword mistakes | Every game (`source.game`) |
| `leaderboards/{game}-{week}` | `crossword-…` | `map-…`, overall `xp-…` |
| `contentReports` | Crossword | Any game (`game` field) |
| Admin callable + audit pattern | Crossword | Every content type |

**Kerala Map Challenge:** `mapChallenges/{challengeId}` (routes, landmarks, district sets as coordinates), `users/{uid}/mapProgress/{challengeId}`, `submitMapChallenge` (server-side route accuracy). Map shapes ship as app assets, not Firestore docs.
