# M3 · Player app — plan and file map

> Branch `module/m3` (one commit per task at push time). Cards: `TASKS.md` → "M3 · Player app".
> Screens: `design/screens/psc-crossword.md`. Data: `docs/firebase/FIREBASE_DESIGN.md`. QA: `docs/qa/M3-manual-test.md`.
> **Read this file instead of scanning `lib/features/crossword/`.** It says where everything is and which
> existing piece to copy for a change.

## Build order (as done)

| Step | Tasks | What |
| --- | --- | --- |
| 1. Reusable first | CW-040, CW-043 | Entities, pure utils (grid engine, XP level, puzzle ids, IST week), colour tokens, shared widgets, `guardData`, `json_read`, `scripts/check.sh` |
| 2. Data | CW-041, CW-042, CW-055 | Models + fixtures, data sources, repository, use cases, DI; profile doc on sign-in |
| 3. Screens | CW-044 – CW-052 | Home, category list, puzzle, autosave, hints, results, revise, ranks, report |
| 4. Wiring | CW-054 | Routes, tab pages, tests at 360 px, docs |

CW-053 (analytics) is **blocked — not planned**: no analytics package or calls.

## Where things are — `lib/features/crossword/`

One folder per module; each has `data/ domain/ presentation/` and a `di.dart` (`initCrossword<Module>`),
wired by `crossword/di.dart`. Modules never import each other (CLAUDE.md "Code structure rules",
`scripts/check_structure.py`); they share `crossword/shared/` and navigate with `AppRoutes`.

| Module | What's in it | Notes |
| --- | --- | --- |
| `shared/` | Entities `category`, `puzzle` (+ `CrosswordDifficulty`), `word` (+ `CrosswordDirection`), `progress` (+ `HintCount`, status), `result` (+ `CrosswordSubmitOutcome`), `result_args` (`ResultArgs`, `ResultMistake`), `change` (`CrosswordChange`); models for those; `ProgressDataSource` → `CrosswordProgressRepository` (session cache: one doc, a page of ids via `in`, per-category `count()`, optimistic save, `markCompleted`); `CrosswordChangesRepository` + `WatchCrosswordChangesUseCase`; `puzzle_ids`; widgets `TagChip`, `MistakeCard`, `AnswerTiles`; `format.dart` | Used by 2+ modules only |
| `home/` | `HomeDataSource` (daily, categories, profile, mistakes `count()`), `HomeRepository` (+ marks via the shared cache), use cases `load_home`, `load_home_progress`, `count_revision_items`; `CrosswordHomeBloc`; `HomePage` (Play tab); widgets `home_top_bar`, `home_title`, `daily_puzzle_card`, `category_grid`, `category_tile`, `mistakes_tile`, `home_tile`, `streak_chip`, `language_toggle`, `daily_word_card` | Submit → silent reload; `revisionChanged` → re-count only |
| `category/` | `CategoryDataSource` (category, published puzzles 20/page), `CategoryRepository` (+ marks, completed count), use cases `load_category`, `load_category_puzzles`, `load_puzzle_marks`, `count_completed`; `CategoryPuzzlesBloc`; `CategoryPuzzlesPage`; widgets `category_header`, `puzzle_list`, `puzzle_row` | Load-more builds on the latest state |
| `puzzle/` | `PuzzleDataSource` (puzzle doc, `submitCrossword`), `RevealsDataSource` (SharedPreferences), `PuzzleRepository`; use cases `load_puzzle`, `save_progress`, `submit_puzzle`; utils `grid.dart` (engine), `answer_encoding.dart`, `result_args_of.dart`; `PuzzleBloc` (timer, save queue, submit); `PuzzlePage`; widgets `board`, `keyboard`, `clue_bar`, `clue_chips`, `header_chips`, `puzzle_header`, `fill_status`, `finish_dialog`, `back_row` | Sub-modules `hints/` (sheet) and `report/` (data source → repository → `ReportContentUseCase`, sheet) |
| `result/` | `xp_level.dart`; `ResultPage`; widgets `result_hero`, `result_stats`, `stat_tile`, `level_card` | Reads `ResultArgs` (route `extra`) — no reads |
| `revise/` | `ReviseDataSource` (paged with `(lastWrongAt, id)` cursor, set mastered), `ReviseRepository` (fires `revisionChanged`), use cases; `ReviseBloc`; `RevisePage` (Revise tab); `revision_card` | Reloads on `puzzleSubmitted` only |
| `leaderboard/` | `LeaderboardDataSource` (board + own entry + rank `count()`), repository, use case, `board_id.dart`; `LeaderboardBloc`; `LeaderboardPage` (Ranks tab); widgets `leaderboard_row`, `my_rank_bar` | Reloads on `puzzleSubmitted` |

Shared, reusable outside crossword: `lib/shared/presentations/widgets/{app_progress_bar,state_message,skeleton_box,app_sheet,category_visuals}.dart`, `lib/shared/domains/entities/paged.dart`, `lib/core/resorces/data_guard.dart`, `lib/core/utils/{json_read,ist_date}.dart`, `lib/core/firebase/dt_converter.dart` (`tryParse`), `lib/core/routes/app_routes.dart`.

## Behaviour worth knowing before changing it

- **Autosave** (`PuzzleBloc._save` → `_drainSaves`): only when changed, at most once per `crossword_autosave_seconds` (driven by the 1 s tick), on pause, and in `saveNow()`. Saves run one at a time; one asked for while another is writing runs right after it with the newer letters. A puzzle that was only looked at never gets a doc. `saveCount` and the `CROSSWORD_AUTOSAVE` log are for checking this.
- **Offline**: progress, revise "learned" and report writes wait at most `serverAckWait` (5 s, `awaitServerAck` in `core/firebase/server_ack.dart`) for the server; Firestore keeps the write and sends it later. Back doesn't wait for the save at all (the bloc finishes it after the route closes; the cache already shows the mark).
- **Revealed squares** live in SharedPreferences (`crossword.reveals.{puzzleId}`) because the rules don't allow them on the progress doc; they're sent as `revealedWordIds` on submit and cleared after.
- **Completed puzzle opened again**: the bloc calls `submitCrossword`, which is idempotent and returns the stored result, so Results can be shown without a new read path (no `puzzleSubmitted` signal).
- **Refresh without listeners**: `CrosswordChangesRepository` — a first submit sends `puzzleSubmitted` (Home, Revise, Ranks reload); "Mark as learned" sends `revisionChanged` (Home re-counts). Returning from a puzzle, Home and the category list re-read marks from the session cache (no reads).
- **Play tab is `/home`** (DEC-007). The daily word game is a card at the bottom of Crossword Home.

## Tests — `test/features/crossword/` (mirrors the modules)

| File | Covers |
| --- | --- |
| `crossword_fixtures.dart` + `test/fixtures/crossword/*.json`, `fixtures_entities.dart` | Real-shaped docs; `examplePuzzle()`, `exampleLetters`, `exampleCategory`, `revisionItem()` |
| `crossword_fakes.dart` | `FakeCrosswordRepository` (implements every module repository + changes), `FakeConfig`, `FakeUseCases` (real use cases + `puzzleBloc()`), `registerCrosswordFakes(getIt, repo)`, `dataError()`, `settle()` |
| `shared/data/{models,repositories}/` | Model parsing; progress cache (chunks, count bump, optimistic save) |
| `{home,category,puzzle,revise}/data/repositories/` | Degrade, paging, reveals round-trip, signals |
| `*/presentation/bloc/` | Every bloc incl. save queue, refresh races, typed changes |
| `puzzle/domain/utils/grid_test.dart` | Engine |
| `puzzle/presentation/widgets/puzzle_widgets_test.dart` | Active-word highlight, keyboard, chips, hints sheet |
| `screens_test.dart` | Every screen at 360 × 740 via a test `GoRouter` |

Widget tests: don't `await bloc.close()` at the end of a `testWidgets` (it never completes in the fake-async zone).

## Manual steps (user)

See `docs/qa/M3-manual-test.md` → "Before testing — manual configuration".
