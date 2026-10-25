import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wordshool/core/remote_config/app_remote_config.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/entities/content_report.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/usecases/report_content.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/puzzle.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/result.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/word.dart';
import 'package:wordshool/features/crossword/puzzle/domain/usecases/load_puzzle.dart';
import 'package:wordshool/features/crossword/puzzle/domain/usecases/save_progress.dart';
import 'package:wordshool/features/crossword/puzzle/domain/usecases/submit_puzzle.dart';
import 'package:wordshool/features/crossword/puzzle/domain/usecases/utils/save_progress_param.dart';
import 'package:wordshool/features/crossword/puzzle/domain/usecases/utils/submit_puzzle_param.dart';
import 'package:wordshool/features/crossword/puzzle/domain/utils/grid.dart';

// ---------- Events ----------

sealed class PuzzleEvent {
  const PuzzleEvent();
}

final class PuzzleOpened extends PuzzleEvent {
  const PuzzleOpened(this.puzzleId);

  final String puzzleId;
}

final class PuzzleCellTapped extends PuzzleEvent {
  const PuzzleCellTapped(this.index);

  final int index;
}

final class PuzzleLetterTyped extends PuzzleEvent {
  const PuzzleLetterTyped(this.letter);

  final String letter;
}

final class PuzzleBackspacePressed extends PuzzleEvent {
  const PuzzleBackspacePressed();
}

final class PuzzleWordSelected extends PuzzleEvent {
  const PuzzleWordSelected(this.wordId);

  final String wordId;
}

final class PuzzleWordStepped extends PuzzleEvent {
  const PuzzleWordStepped({required this.forward});

  final bool forward;
}

final class PuzzleCheckPressed extends PuzzleEvent {
  const PuzzleCheckPressed();
}

/// Free "Show a clue" for the active word (counted once per word).
final class PuzzleClueShown extends PuzzleEvent {
  const PuzzleClueShown();
}

final class PuzzleRevealRequested extends PuzzleEvent {
  const PuzzleRevealRequested({required this.word});

  /// True = whole word, false = the cursor square.
  final bool word;
}

/// One second passed (from the bloc's ticker, or a test).
final class PuzzleTicked extends PuzzleEvent {
  const PuzzleTicked();
}

/// App went to the background (false) or came back (true).
final class PuzzleLifecycleChanged extends PuzzleEvent {
  const PuzzleLifecycleChanged({required this.active});

  final bool active;
}

/// The player is leaving the screen: save if anything changed.
final class PuzzleLeft extends PuzzleEvent {
  const PuzzleLeft();
}

final class PuzzleSubmitted extends PuzzleEvent {
  const PuzzleSubmitted();
}

final class PuzzleReported extends PuzzleEvent {
  const PuzzleReported({required this.reason, this.message = ''});

  final ReportReason reason;
  final String message;
}

// ---------- States ----------

sealed class PuzzleState extends Equatable {
  const PuzzleState();

  @override
  List<Object?> get props => [];
}

final class PuzzleLoading extends PuzzleState {
  const PuzzleLoading();
}

final class PuzzleLoadFailed extends PuzzleState {
  const PuzzleLoadFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// A one-off message for a snackbar; [id] makes repeats distinct.
class PuzzleNotice extends Equatable {
  const PuzzleNotice(this.id, this.message, {this.isError = false});

  final int id;
  final String message;
  final bool isError;

  @override
  List<Object?> get props => [id, message, isError];
}

final class PuzzleReady extends PuzzleState {
  const PuzzleReady({
    required this.puzzle,
    required this.grid,
    required this.revision,
    required this.elapsedSec,
    required this.hintsUsed,
    required this.checksUsed,
    required this.revealsLeft,
    required this.cluesShown,
    this.paused = false,
    this.lastCheck,
    this.submitting = false,
    this.notice,
    this.outcome,
  });

  final CrosswordPuzzleEntity puzzle;

  /// Mutable engine; [revision] tells states apart.
  final CrosswordGrid grid;
  final int revision;
  final int elapsedSec;
  final HintCount hintsUsed;
  final int checksUsed;
  final int revealsLeft;

  /// Words whose extra clue was opened this session.
  final Set<String> cluesShown;
  final bool paused;

  /// The last Check, until the next edit.
  final CheckSummary? lastCheck;
  final bool submitting;
  final PuzzleNotice? notice;

  /// Set once `submitCrossword` answered (the page then opens Results).
  final CrosswordSubmitOutcome? outcome;

  CrosswordWordEntity? get activeWord {
    final id = grid.activeWord?.id;
    if (id == null) return null;
    for (final w in puzzle.words) {
      if (w.id == id) return w;
    }
    return null;
  }

  PuzzleReady copyWith({
    int? elapsedSec,
    HintCount? hintsUsed,
    int? checksUsed,
    int? revealsLeft,
    Set<String>? cluesShown,
    bool? paused,
    CheckSummary? lastCheck,
    bool clearCheck = false,
    bool? submitting,
    PuzzleNotice? notice,
    CrosswordSubmitOutcome? outcome,
  }) {
    return PuzzleReady(
      puzzle: puzzle,
      grid: grid,
      revision: grid.revision,
      elapsedSec: elapsedSec ?? this.elapsedSec,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      checksUsed: checksUsed ?? this.checksUsed,
      revealsLeft: revealsLeft ?? this.revealsLeft,
      cluesShown: cluesShown ?? this.cluesShown,
      paused: paused ?? this.paused,
      lastCheck: clearCheck ? null : (lastCheck ?? this.lastCheck),
      submitting: submitting ?? this.submitting,
      notice: notice ?? this.notice,
      outcome: outcome ?? this.outcome,
    );
  }

  @override
  List<Object?> get props => [
        puzzle.id,
        revision,
        elapsedSec,
        hintsUsed,
        checksUsed,
        revealsLeft,
        cluesShown,
        paused,
        lastCheck?.correct,
        lastCheck?.wrong,
        submitting,
        notice,
        outcome,
      ];
}

// ---------- Bloc ----------

/// The puzzle screen (CW-046 … CW-049, CW-052): grid engine, timer, check,
/// hints, autosave (pause / leave / every `crossword_autosave_seconds` while
/// changed — never per key) and submit.
class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  PuzzleBloc({
    required LoadPuzzleUseCase loadPuzzle,
    required SaveCrosswordProgressUseCase saveProgress,
    required SubmitCrosswordUseCase submit,
    required ReportContentUseCase report,
    required AppRemoteConfig config,
    this.startTicker = true,
  })  : _loadPuzzle = loadPuzzle,
        _saveProgress = saveProgress,
        _submit = submit,
        _report = report,
        _config = config,
        super(const PuzzleLoading()) {
    on<PuzzleOpened>(_onOpened);
    on<PuzzleCellTapped>(
        (e, emit) => _edit(emit, (g) => g.tap(e.index), changes: false));
    on<PuzzleLetterTyped>((e, emit) => _edit(emit, (g) => g.type(e.letter)));
    on<PuzzleBackspacePressed>((e, emit) => _edit(emit, (g) => g.backspace()));
    on<PuzzleWordSelected>((e, emit) =>
        _edit(emit, (g) => g.selectWord(e.wordId), changes: false));
    on<PuzzleWordStepped>((e, emit) => _edit(
        emit, (g) => e.forward ? g.nextWord() : g.previousWord(),
        changes: false));
    on<PuzzleCheckPressed>(_onCheck);
    on<PuzzleClueShown>(_onClueShown);
    on<PuzzleRevealRequested>(_onReveal);
    on<PuzzleTicked>(_onTick);
    on<PuzzleLifecycleChanged>(_onLifecycle);
    on<PuzzleLeft>((e, emit) => _save(force: true));
    on<PuzzleSubmitted>(_onSubmit);
    on<PuzzleReported>(_onReport);
  }

  final LoadPuzzleUseCase _loadPuzzle;
  final SaveCrosswordProgressUseCase _saveProgress;
  final SubmitCrosswordUseCase _submit;
  final ReportContentUseCase _report;
  final AppRemoteConfig _config;

  /// Off in tests, which send [PuzzleTicked] themselves.
  final bool startTicker;

  StreamSubscription<void>? _ticker;
  bool _hasProgressDoc = false;
  bool _completed = false;

  /// Letters/hints/checks changed since the last save.
  bool _dirty = false;
  int _lastSavedElapsed = 0;
  int _noticeId = 0;

  /// The running save queue; saves asked for meanwhile run after it.
  Future<void>? _saving;
  bool _saveRequested = false;
  bool _forceRequested = false;

  /// Number of progress writes (CW-047 check: ≤ 1 per autosave interval).
  int saveCount = 0;

  PuzzleReady? get _ready => state is PuzzleReady ? state as PuzzleReady : null;

  /// The puzzle while the player may change it: not finished and not being
  /// submitted (the server gets the letters and hints as they were).
  PuzzleReady? get _editable {
    final ready = _ready;
    return ready == null || _completed || ready.submitting ? null : ready;
  }

  Future<void> _onOpened(PuzzleOpened event, Emitter<PuzzleState> emit) async {
    emit(const PuzzleLoading());
    final result = await _loadPuzzle(param: event.puzzleId);
    if (result is DataError || result.data == null) {
      emit(PuzzleLoadFailed(
          result.error?.message ?? "Couldn't open the puzzle."));
      return;
    }
    final session = result.data!;
    final progress = session.progress;
    _hasProgressDoc = progress != null;
    _completed = progress?.isCompleted ?? false;
    _lastSavedElapsed = progress?.elapsedSec ?? 0;
    final grid = CrosswordGrid.fromPuzzle(
      session.puzzle,
      letters: progress?.letters,
      revealedCells: session.revealedCells,
      revealedWordIds: session.revealedWordIds,
    );
    final hints = progress?.hintsUsed ?? HintCount.zero;
    emit(PuzzleReady(
      puzzle: session.puzzle,
      grid: grid,
      revision: grid.revision,
      elapsedSec: progress?.elapsedSec ?? 0,
      hintsUsed: hints,
      checksUsed: progress?.checksUsed ?? 0,
      revealsLeft: _revealsLeft(hints),
      cluesShown: const {},
    ));
    if (_completed) {
      // Already submitted: submitCrossword is idempotent and returns the
      // stored result with the player's totals for the Results screen.
      add(const PuzzleSubmitted());
      return;
    }
    if (startTicker) {
      _ticker = Stream<void>.periodic(const Duration(seconds: 1))
          .listen((_) => add(const PuzzleTicked()));
    }
  }

  int _revealsLeft(HintCount hints) =>
      (_config.crosswordRevealsPerPuzzle - hints.revealsSpent)
          .clamp(0, 1 << 30);

  void _edit(
    Emitter<PuzzleState> emit,
    void Function(CrosswordGrid grid) change, {
    bool changes = true,
  }) {
    final ready = _editable;
    if (ready == null) return;
    final before = ready.grid.lettersString;
    change(ready.grid);
    final edited = changes && ready.grid.lettersString != before;
    if (edited) _dirty = true;
    emit(ready.copyWith(clearCheck: edited));
  }

  void _onCheck(PuzzleCheckPressed event, Emitter<PuzzleState> emit) {
    final ready = _editable;
    if (ready == null) return;
    final summary = ready.grid.check();
    _dirty = true;
    emit(ready.copyWith(checksUsed: ready.checksUsed + 1, lastCheck: summary));
  }

  void _onClueShown(PuzzleClueShown event, Emitter<PuzzleState> emit) {
    final ready = _editable;
    final wordId = ready?.grid.activeWord?.id;
    if (ready == null || wordId == null || ready.cluesShown.contains(wordId)) {
      return;
    }
    _dirty = true;
    emit(ready.copyWith(
      hintsUsed: ready.hintsUsed.copyWith(clue: ready.hintsUsed.clue + 1),
      cluesShown: {...ready.cluesShown, wordId},
    ));
  }

  void _onReveal(PuzzleRevealRequested event, Emitter<PuzzleState> emit) {
    final ready = _editable;
    if (ready == null) return;
    final cost =
        event.word ? HintCount.revealWordCost : HintCount.revealLetterCost;
    if (ready.revealsLeft < cost) {
      emit(ready.copyWith(notice: _notice('Not enough reveals left.')));
      return;
    }
    final done =
        event.word ? ready.grid.revealWord() : ready.grid.revealLetter();
    if (!done) return;
    _dirty = true;
    final hints = event.word
        ? ready.hintsUsed.copyWith(word: ready.hintsUsed.word + 1)
        : ready.hintsUsed.copyWith(letter: ready.hintsUsed.letter + 1);
    emit(ready.copyWith(
      hintsUsed: hints,
      revealsLeft: _revealsLeft(hints),
      clearCheck: true,
    ));
  }

  Future<void> _onTick(PuzzleTicked event, Emitter<PuzzleState> emit) async {
    final ready = _ready;
    if (ready == null || ready.paused || _completed || ready.submitting) {
      return;
    }
    emit(ready.copyWith(elapsedSec: ready.elapsedSec + 1));
    final interval = _config.crosswordAutosaveInterval.inSeconds;
    if (_dirty && ready.elapsedSec + 1 - _lastSavedElapsed >= interval) {
      await _save();
    }
  }

  Future<void> _onLifecycle(
    PuzzleLifecycleChanged event,
    Emitter<PuzzleState> emit,
  ) async {
    final ready = _ready;
    if (ready == null) return;
    emit(ready.copyWith(paused: !event.active));
    if (!event.active) await _save(force: true);
  }

  /// Queues a save. A save asked for while one is writing runs right after
  /// it with the newer letters, so edits made meanwhile are never dropped.
  /// [force] (pause, leave) also saves time spent since the last write.
  Future<void> _save({bool force = false}) {
    _saveRequested = true;
    _forceRequested = _forceRequested || force;
    return _saving ??= _drainSaves();
  }

  Future<void> _drainSaves() async {
    try {
      while (_saveRequested) {
        final force = _forceRequested;
        _saveRequested = false;
        _forceRequested = false;
        await _writeProgress(force: force);
      }
    } finally {
      _saving = null;
    }
  }

  /// Writes the progress doc when something changed, but never creates a
  /// doc for a puzzle the player only looked at.
  Future<void> _writeProgress({required bool force}) async {
    final ready = _ready;
    if (ready == null || _completed || ready.submitting) return;
    final timeChanged = ready.elapsedSec != _lastSavedElapsed;
    if (!_dirty && !(force && timeChanged && _hasProgressDoc)) return;
    final wasDirty = _dirty;
    _dirty = false;
    final result = await _saveProgress(
      param: SaveCrosswordProgressParam(
        progress: _progressOf(ready),
        create: !_hasProgressDoc,
        revealedCells: ready.grid.revealedCells,
        revealedWordIds: ready.grid.revealedWordIds,
      ),
    );
    if (result is DataSuccess) {
      saveCount++;
      _hasProgressDoc = true;
      _lastSavedElapsed = ready.elapsedSec;
    } else {
      // Try again on the next interval / pause.
      _dirty = _dirty || wasDirty;
    }
  }

  CrosswordProgressEntity _progressOf(PuzzleReady ready) =>
      CrosswordProgressEntity(
        puzzleId: ready.puzzle.id,
        letters: ready.grid.lettersString,
        elapsedSec: ready.elapsedSec,
        hintsUsed: ready.hintsUsed,
        checksUsed: ready.checksUsed,
      );

  Future<void> _onSubmit(
      PuzzleSubmitted event, Emitter<PuzzleState> emit) async {
    final ready = _ready;
    if (ready == null || ready.submitting || ready.outcome != null) return;
    emit(ready.copyWith(submitting: true));
    final result = await _submit(
      param: SubmitCrosswordParam(
        progress: _progressOf(ready),
        revealedWordIds: ready.grid.revealedWordIds,
      ),
    );
    final latest = _ready ?? ready;
    if (result is DataError || result.data == null) {
      emit(latest.copyWith(
        submitting: false,
        notice: _notice(
          result.error?.message ?? "Couldn't submit. Try again.",
          isError: true,
        ),
      ));
      return;
    }
    final outcome = result.data!;
    _completed = true;
    _dirty = false;
    await _ticker?.cancel();
    emit(latest.copyWith(submitting: false, outcome: outcome));
  }

  Future<void> _onReport(
      PuzzleReported event, Emitter<PuzzleState> emit) async {
    final ready = _ready;
    final word = ready?.activeWord;
    if (ready == null || word == null) return;
    final result = await _report(
      param: ContentReportEntity(
        puzzleId: ready.puzzle.id,
        wordId: word.id,
        questionId: word.questionId,
        reason: event.reason,
        message: event.message,
      ),
    );
    final latest = _ready ?? ready;
    emit(latest.copyWith(
      notice: result is DataSuccess
          ? _notice(
              "Thanks — we'll check ${word.number} ${word.direction.label}.")
          : _notice(result.error?.message ?? "Couldn't send the report.",
              isError: true),
    ));
  }

  /// Saves now if anything changed. Safe to call as the route closes: the
  /// queue finishes on its own, and Firestore keeps the write offline.
  Future<void> saveNow() => _save(force: true);

  PuzzleNotice _notice(String message, {bool isError = false}) =>
      PuzzleNotice(++_noticeId, message, isError: isError);

  @override
  Future<void> close() async {
    await _ticker?.cancel();
    return super.close();
  }
}
