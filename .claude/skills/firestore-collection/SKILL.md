---
name: firestore-collection
description: Add or change a Firestore collection in the Kerala PSC app end to end — design doc entry, collection constants (Dart + Python), security rules with emulator tests, indexes and field overrides, model, and cost check. Use whenever a task introduces a new collection, subcollection or field, or changes who can read/write data.
---

# Firestore collection — end to end

A collection is "done" only when all six places agree. Do them in this order.

## 1. Design first — `docs/firebase/FIREBASE_DESIGN.md`

Add the collection under "Collections in detail" with:

- path and ID format (readable slug where possible: `kerala-history-0012`, `2026-10-22`, `crossword-2026-W43`)
- who reads / who writes (app, admin function, player function, scheduled job)
- a field table: name · type · example/notes — plus the standard fields `schemaVersion`, `createdAt`, `updatedAt`, `createdBy`, `updatedBy` for content
- the screen(s) that read it and how many reads that costs

Ask: can the screen load in 1–3 reads? If not, add a summary/pointer doc (like `crosswordDaily` or `top50`) instead of a query.

## 2. Constants

- Dart: `lib/core/firebase/collections.dart` → `static const String myThings = 'myThings';`
- Python: `functions/crossword/collections.py` (or the feature's folder) → `MY_THINGS = "myThings"` (needs CW-007)

## 3. Security rules — `firestore.rules`

Pick the pattern:

| Who writes | Rule |
| --- | --- |
| Admin content | `allow read: if <public condition>; allow write: if false;` (functions use Admin SDK) |
| Private server data | `allow read, write: if false;` |
| Player-owned (`users/{uid}/...`) | `isOwner(uid) && isNotBlocked(uid)` + `keys().hasOnly([...])` on create + `diff(resource.data).affectedKeys().hasOnly([...])` on update + "only goes up" checks |
| Player create-only (reports) | validated `create`, `read, update, delete: if false` |

Rules:
- Put new top-level matches **above** the catch-all deny; player subcollections **inside** `match /users/{uid}`.
- Reuse the helpers at the top of `firestore.rules` (`isAuthenticated`, `isOwner`, `isNotBlocked`, `isDateId`, `isNonNegativeInt` — added in CW-010). Add new helpers there.
- Timestamps from the client must equal `request.time` (client sends `FieldValue.serverTimestamp()`).
- Rules are not filters: if read depends on a field (`status == 'published'`), the app's query must filter on it too.

Template for a player-owned subcollection:

```js
match /myThings/{thingId} {
  allow read: if isOwner(uid);
  allow create: if isOwner(uid) && isNotBlocked(uid)
    && request.resource.data.keys().hasOnly(['fieldA', 'count', 'updatedAt'])
    && request.resource.data.fieldA is string
    && isNonNegativeInt(request.resource.data.count)
    && request.resource.data.updatedAt == request.time;
  allow update: if isOwner(uid) && isNotBlocked(uid)
    && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['count', 'updatedAt'])
    && request.resource.data.count >= resource.data.count
    && request.resource.data.updatedAt == request.time;
  allow delete: if false;
}
```

## 4. Rules tests (harness chosen in CW-010)

Run against the Firestore emulator (`firebase emulators:exec --only firestore "<rules test command>"`; see CW-010 for the harness). For each collection prove **both** sides:

```ts
await assertSucceeds(getDoc(doc(alice, "crosswordPuzzles/published-1")));
await assertFails(getDoc(doc(alice, "crosswordPuzzles/draft-1")));
await assertFails(setDoc(doc(alice, "crosswordPuzzles/x"), {...}));
await assertFails(updateDoc(doc(alice, "users/alice/crosswordProgress/p1"), {elapsedSec: 1})); // went down
```

## 5. Indexes — `firestore.indexes.json`

- Composite index for every query with equality + order on different fields (`categoryId ==`, `status ==`, `orderBy number desc`).
- `fieldOverrides` with `"indexes": []` for big arrays/strings never queried (`words`, `letters`) — saves storage and write cost.
- Single-field `orderBy`/range queries need nothing.
- Deploy: `firebase deploy --only firestore:indexes` (project `kerala-pcs-dev`); wait for "Enabled".

## 6. Code

- Model + entity via the `flutter-feature` skill (field names from step 1).
- Functions types in `functions/<feature>/types.py` (`TypedDict`).

## Cost check (write it in the PR)

- Reads per screen open, writes per user action, and whether anything is a listener.
- Use the table in the design doc's "Cost estimate" to see if the free tier still holds at 2,000 daily players.

## Checklist

- [ ] Design doc updated (same PR)
- [ ] Dart + Python constants
- [ ] Rules + allow/deny tests passing
- [ ] Indexes / overrides added and deployed to dev
- [ ] Queries match rule conditions
- [ ] Reads per screen ≤ 3 (or justified)
