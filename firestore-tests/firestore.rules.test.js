// Firestore security rules tests (CW-010).
// Run from this folder: `npm test` (starts the Firestore emulator, runs Jest, stops it).
const fs = require('node:fs');
const path = require('node:path');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const {
  doc,
  getDoc,
  getDocs,
  collection,
  query,
  where,
  setDoc,
  updateDoc,
  deleteDoc,
  addDoc,
  serverTimestamp,
} = require('firebase/firestore');

const PROJECT_ID = 'demo-kerala-pcs';

let testEnv;

/** Firestore client signed in as `uid` (or unauthenticated when `uid` is null). */
function db(uid) {
  return uid ? testEnv.authenticatedContext(uid).firestore() : testEnv.unauthenticatedContext().firestore();
}

/** Writes seed data with rules disabled. */
async function seed(docs) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const fs = ctx.firestore();
    for (const [docPath, data] of Object.entries(docs)) {
      await setDoc(doc(fs, docPath), data);
    }
  });
}

function profile(overrides = {}) {
  return {
    displayName: 'Alice',
    photoUrl: null,
    isAnonymous: false,
    createdAt: serverTimestamp(),
    lastSeenAt: serverTimestamp(),
    ...overrides,
  };
}

function progress(overrides = {}) {
  return {
    status: 'in_progress',
    letters: '....',
    elapsedSec: 10,
    hintsUsed: { letter: 1, word: 0, clue: 1 },
    checksUsed: 1,
    startedAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    ...overrides,
  };
}

function report(overrides = {}) {
  return {
    uid: 'alice',
    puzzleId: 'published-1',
    wordId: '2D',
    questionId: 'kerala-history-0012',
    reason: 'wrong_answer',
    message: 'Answer should be VAIKOM',
    status: 'open',
    createdAt: serverTimestamp(),
    ...overrides,
  };
}

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules: fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8') },
  });
});

afterAll(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await seed({
    'crosswordPuzzles/published-1': { status: 'published', title: { en: 'Kerala history' } },
    'crosswordPuzzles/draft-1': { status: 'draft', title: { en: 'Draft' } },
    'crosswordCategories/kerala-history': { isActive: true },
    'crosswordCategories/hidden': { isActive: false },
    'crosswordSolutions/published-1': { answers: { '2D': 'VAIKOM' } },
    'pscQuestions/kerala-history-0012': { answer: 'VAIKOM', status: 'verified' },
    'crosswordDaily/2026-10-23': { puzzleId: 'published-1' },
    'adminAuditLog/log-1': { action: 'save' },
    'leaderboards/crossword-2026-W43': { top50: [] },
    'leaderboards/crossword-2026-W43/entries/alice': { points: 10 },
    'games/2026-10-23': { word: 'APPLE' },
  });
});

describe('games (daily word game, unchanged)', () => {
  test('signed-in player can read and create', async () => {
    await assertSucceeds(getDoc(doc(db('alice'), 'games/2026-10-23')));
    await assertSucceeds(addDoc(collection(db('alice'), 'games'), { word: 'MANGO' }));
  });

  test('signed-out user cannot read; nobody can update or delete', async () => {
    await assertFails(getDoc(doc(db(null), 'games/2026-10-23')));
    await assertFails(updateDoc(doc(db('alice'), 'games/2026-10-23'), { word: 'X' }));
    await assertFails(deleteDoc(doc(db('alice'), 'games/2026-10-23')));
  });
});

describe('users/{uid}', () => {
  test('owner can create a profile and update profile fields', async () => {
    const alice = db('alice');
    await assertSucceeds(setDoc(doc(alice, 'users/alice'), profile()));
    await assertSucceeds(
      updateDoc(doc(alice, 'users/alice'), { displayName: 'Alice K', lastSeenAt: serverTimestamp() }),
    );
    await assertSucceeds(getDoc(doc(alice, 'users/alice')));
  });

  test('player cannot set own xp (on create or update)', async () => {
    const alice = db('alice');
    await assertFails(setDoc(doc(alice, 'users/alice'), profile({ xp: 9999 })));
    await assertSucceeds(setDoc(doc(alice, 'users/alice'), profile()));
    await assertFails(updateDoc(doc(alice, 'users/alice'), { xp: 9999, lastSeenAt: serverTimestamp() }));
  });

  test('player cannot write server-only fields', async () => {
    await seed({ 'users/alice': { displayName: 'Alice', isAnonymous: false, xp: 10 } });
    const ref = doc(db('alice'), 'users/alice');
    for (const field of ['crossword', 'rateLimit', 'blockedAt']) {
      await assertFails(updateDoc(ref, { [field]: {}, lastSeenAt: serverTimestamp() }));
    }
  });

  test('player cannot read or write another player, nor delete self', async () => {
    await seed({ 'users/bob': { displayName: 'Bob', isAnonymous: false } });
    await assertFails(getDoc(doc(db('alice'), 'users/bob')));
    await assertFails(setDoc(doc(db('alice'), 'users/bob'), profile()));
    await assertFails(deleteDoc(doc(db('bob'), 'users/bob')));
  });

  test('client timestamps must be server time', async () => {
    await assertFails(setDoc(doc(db('alice'), 'users/alice'), profile({ lastSeenAt: new Date(0) })));
  });

  test('blocked player cannot update profile', async () => {
    await seed({ 'users/alice': { displayName: 'Alice', isAnonymous: false, blockedAt: new Date() } });
    await assertFails(
      updateDoc(doc(db('alice'), 'users/alice'), { displayName: 'A', lastSeenAt: serverTimestamp() }),
    );
  });
});

describe('content collections', () => {
  test('player can read published puzzles, active categories and daily pointers', async () => {
    const alice = db('alice');
    await assertSucceeds(getDoc(doc(alice, 'crosswordPuzzles/published-1')));
    await assertSucceeds(getDoc(doc(alice, 'crosswordCategories/kerala-history')));
    await assertSucceeds(getDoc(doc(alice, 'crosswordDaily/2026-10-23')));
    await assertSucceeds(
      getDocs(query(collection(alice, 'crosswordPuzzles'), where('status', '==', 'published'))),
    );
  });

  test('player cannot read a draft puzzle, inactive category, or unfiltered list', async () => {
    const alice = db('alice');
    await assertFails(getDoc(doc(alice, 'crosswordPuzzles/draft-1')));
    await assertFails(getDoc(doc(alice, 'crosswordCategories/hidden')));
    await assertFails(getDocs(collection(alice, 'crosswordPuzzles')));
    await assertFails(getDoc(doc(db(null), 'crosswordPuzzles/published-1')));
  });

  test('player cannot read private collections', async () => {
    const alice = db('alice');
    await assertFails(getDoc(doc(alice, 'crosswordSolutions/published-1')));
    await assertFails(getDoc(doc(alice, 'pscQuestions/kerala-history-0012')));
    await assertFails(getDoc(doc(alice, 'adminAuditLog/log-1')));
  });

  test('player cannot write content', async () => {
    const alice = db('alice');
    await assertFails(setDoc(doc(alice, 'crosswordPuzzles/new'), { status: 'published' }));
    await assertFails(updateDoc(doc(alice, 'crosswordPuzzles/published-1'), { status: 'archived' }));
    await assertFails(setDoc(doc(alice, 'crosswordCategories/new'), { isActive: true }));
    await assertFails(setDoc(doc(alice, 'crosswordDaily/2026-10-24'), { puzzleId: 'x' }));
    await assertFails(setDoc(doc(alice, 'crosswordSolutions/x'), { answers: {} }));
    await assertFails(setDoc(doc(alice, 'pscQuestions/x'), { answer: 'X' }));
  });
});

describe('users/{uid}/crosswordProgress', () => {
  const path = 'users/alice/crosswordProgress/published-1';

  test('owner can start and save progress on a published puzzle', async () => {
    const ref = doc(db('alice'), path);
    await assertSucceeds(setDoc(ref, progress()));
    await assertSucceeds(
      updateDoc(ref, {
        letters: 'VA..',
        elapsedSec: 40,
        hintsUsed: { letter: 2, word: 0, clue: 1 },
        updatedAt: serverTimestamp(),
      }),
    );
    await assertSucceeds(getDoc(ref));
  });

  test('cannot start progress on a draft puzzle or for another player', async () => {
    await assertFails(setDoc(doc(db('alice'), 'users/alice/crosswordProgress/draft-1'), progress()));
    await assertFails(setDoc(doc(db('bob'), path), progress()));
  });

  test('cannot create as completed or with a result', async () => {
    const ref = doc(db('alice'), path);
    await assertFails(setDoc(ref, progress({ status: 'completed' })));
    await assertFails(setDoc(ref, progress({ result: { score: 100 } })));
  });

  test('cannot lower elapsedSec, hints or checks', async () => {
    await seed({ [path]: { ...progress(), startedAt: new Date(), updatedAt: new Date() } });
    const ref = doc(db('alice'), path);
    await assertFails(updateDoc(ref, { elapsedSec: 5, updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(ref, { checksUsed: 0, updatedAt: serverTimestamp() }));
    for (const kind of ['letter', 'clue']) {
      await assertFails(
        updateDoc(ref, {
          hintsUsed: { letter: 1, word: 0, clue: 1, [kind]: 0 },
          updatedAt: serverTimestamp(),
        }),
      );
    }
    // Control: a valid save on the same doc is allowed, so the denials above are for the field.
    await assertSucceeds(updateDoc(ref, { elapsedSec: 11, updatedAt: serverTimestamp() }));
  });

  test('cannot change status, result or letters length', async () => {
    await seed({ [path]: { ...progress(), startedAt: new Date(), updatedAt: new Date() } });
    const ref = doc(db('alice'), path);
    await assertFails(updateDoc(ref, { status: 'completed', updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(ref, { result: { score: 100 }, updatedAt: serverTimestamp() }));
    await assertFails(updateDoc(ref, { letters: '.....', updatedAt: serverTimestamp() }));
    // Control: a valid save on the same doc is allowed, so the denials above are for the field.
    await assertSucceeds(updateDoc(ref, { elapsedSec: 11, updatedAt: serverTimestamp() }));
  });

  test('cannot edit a completed progress doc', async () => {
    await seed({
      [path]: { ...progress(), status: 'completed', startedAt: new Date(), updatedAt: new Date() },
    });
    await assertFails(
      updateDoc(doc(db('alice'), path), { elapsedSec: 99, updatedAt: serverTimestamp() }),
    );
    await assertFails(deleteDoc(doc(db('alice'), path)));
  });
});

describe('users/{uid}/revisionItems', () => {
  const path = 'users/alice/revisionItems/kerala-history-0012';

  beforeEach(async () => {
    await seed({ [path]: { answer: 'VAIKOM', wrongCount: 1, mastered: false } });
  });

  test('owner can read and toggle mastered', async () => {
    const ref = doc(db('alice'), path);
    await assertSucceeds(getDoc(ref));
    await assertSucceeds(updateDoc(ref, { mastered: true, updatedAt: serverTimestamp() }));
  });

  test('owner cannot change other fields, create or delete', async () => {
    const alice = db('alice');
    await assertFails(updateDoc(doc(alice, path), { wrongCount: 0, updatedAt: serverTimestamp() }));
    await assertFails(setDoc(doc(alice, 'users/alice/revisionItems/new'), { mastered: false }));
    await assertFails(deleteDoc(doc(alice, path)));
    await assertFails(getDoc(doc(db('bob'), path)));
  });
});

describe('leaderboards', () => {
  test('signed-in player can read boards and entries but not write', async () => {
    const alice = db('alice');
    await assertSucceeds(getDoc(doc(alice, 'leaderboards/crossword-2026-W43')));
    await assertSucceeds(getDoc(doc(alice, 'leaderboards/crossword-2026-W43/entries/alice')));
    await assertFails(
      setDoc(doc(alice, 'leaderboards/crossword-2026-W43/entries/alice'), { points: 9999 }),
    );
    await assertFails(getDoc(doc(db(null), 'leaderboards/crossword-2026-W43')));
  });
});

describe('contentReports', () => {
  test('player can create a valid report but not read it', async () => {
    const alice = db('alice');
    await assertSucceeds(setDoc(doc(alice, 'contentReports/r1'), report()));
    await assertFails(getDoc(doc(alice, 'contentReports/r1')));
    await assertFails(updateDoc(doc(alice, 'contentReports/r1'), { status: 'fixed' }));
  });

  test('invalid reports are refused', async () => {
    const ref = doc(db('alice'), 'contentReports/r2');
    await assertFails(setDoc(ref, report({ uid: 'bob' })));
    await assertFails(setDoc(ref, report({ reason: 'spam' })));
    await assertFails(setDoc(ref, report({ status: 'fixed' })));
    await assertFails(setDoc(ref, report({ message: 'x'.repeat(501) })));
    await assertFails(setDoc(ref, report({ extra: true })));
    await assertFails(setDoc(doc(db(null), 'contentReports/r3'), report()));
  });

  test('blocked player cannot report', async () => {
    await seed({ 'users/alice': { displayName: 'Alice', isAnonymous: false, blockedAt: new Date() } });
    await assertFails(setDoc(doc(db('alice'), 'contentReports/r4'), report()));
  });
});
