import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/crossword/puzzle/report/domain/entities/content_report.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/puzzle/presentation/bloc/puzzle_bloc.dart';

import '../../../crossword_fakes.dart';
import '../../../crossword_fixtures.dart';

void main() {
  late FakeCrosswordRepository repo;
  late PuzzleBloc bloc;

  PuzzleReady ready() => bloc.state as PuzzleReady;

  Future<void> open({FakeConfig? config}) async {
    bloc = FakeUseCases(repo).puzzleBloc(config: config);
    bloc.add(PuzzleOpened(repo.puzzle.id));
    await settle();
  }

  Future<void> send(PuzzleEvent event) async {
    bloc.add(event);
    await settle();
  }

  Future<void> tick(int seconds) async {
    for (var i = 0; i < seconds; i++) {
      await send(const PuzzleTicked());
    }
  }

  setUp(() {
    repo = FakeCrosswordRepository();
  });

  tearDown(() => bloc.close());

  test('opens a new puzzle', () async {
    await open();
    expect(ready().puzzle.id, 'kerala-history-0012');
    expect(ready().revealsLeft, 3);
    expect(ready().elapsedSec, 0);
    expect(ready().activeWord!.id, '1A');
  });

  test('a load error shows the message', () async {
    repo.failLoad = true;
    await open();
    expect(bloc.state, const PuzzleLoadFailed("This puzzle isn't available."));
  });

  test('resumes saved progress', () async {
    repo.progress = CrosswordProgressEntity(
      puzzleId: repo.puzzle.id,
      letters: exampleLetters['inProgress']!,
      elapsedSec: 95,
      hintsUsed: const HintCount(letter: 1, clue: 2),
      checksUsed: 1,
    );
    await open();
    expect(ready().elapsedSec, 95);
    expect(ready().revealsLeft, 2);
    expect(ready().grid.typedAnswer('1A'), 'MUZIRIS');
  });

  test('typing, backspace and word navigation change the grid', () async {
    await open();
    await send(const PuzzleLetterTyped('M'));
    await send(const PuzzleLetterTyped('U'));
    expect(ready().grid.typedAnswer('1A'), 'MU·····');
    await send(const PuzzleBackspacePressed());
    await send(const PuzzleBackspacePressed());
    expect(ready().grid.filledCount, 0);
    await send(const PuzzleWordSelected('2D'));
    expect(ready().activeWord!.id, '2D');
    await send(const PuzzleWordStepped(forward: true));
    expect(ready().activeWord!.id, '3D');
    await send(const PuzzleWordStepped(forward: false));
    expect(ready().activeWord!.id, '2D');
    await send(const PuzzleCellTapped(0));
    expect(ready().grid.cursor, 0);
  });

  test('check counts, reports wrong squares and clears on edit', () async {
    await open();
    await send(const PuzzleLetterTyped('M'));
    await send(const PuzzleLetterTyped('X'));
    await send(const PuzzleCheckPressed());
    expect(ready().checksUsed, 1);
    expect(ready().lastCheck!.wrong, 1);
    await send(const PuzzleLetterTyped('Z'));
    expect(ready().lastCheck, isNull);
  });

  group('hints', () {
    test('show a clue is free and counted once per word', () async {
      await open();
      await send(const PuzzleClueShown());
      await send(const PuzzleClueShown());
      expect(ready().hintsUsed.clue, 1);
      expect(ready().revealsLeft, 3);
      await send(const PuzzleWordSelected('2D'));
      await send(const PuzzleClueShown());
      expect(ready().hintsUsed.clue, 2);
    });

    test('reveal letter costs 1, reveal word costs 3', () async {
      await open();
      await send(const PuzzleRevealRequested(word: false));
      expect(ready().hintsUsed.letter, 1);
      expect(ready().revealsLeft, 2);
      expect(ready().grid.letterAt(0), 'M');

      // Word needs 3; only 2 left.
      await send(const PuzzleRevealRequested(word: true));
      expect(ready().hintsUsed.word, 0);
      expect(ready().notice!.message, 'Not enough reveals left.');
    });

    test('reveal word fills the word and is sent on submit', () async {
      await open();
      await send(const PuzzleWordSelected('3D'));
      await send(const PuzzleRevealRequested(word: true));
      expect(ready().revealsLeft, 0);
      expect(ready().grid.typedAnswer('3D'), 'GAMA');
      await send(const PuzzleSubmitted());
      expect(repo.submits.single.revealed, ['3D']);
      expect(repo.submits.single.progress.hintsUsed, const HintCount(word: 1));
    });

    test('a reveal on an already revealed square costs nothing', () async {
      await open();
      await send(const PuzzleRevealRequested(word: false));
      await send(const PuzzleRevealRequested(word: false));
      expect(ready().hintsUsed.letter, 1);
    });
  });

  group('autosave (CW-047)', () {
    test('typing for 65 s writes at most once per 30 s', () async {
      await open();
      for (var s = 0; s < 65; s++) {
        await send(PuzzleLetterTyped(s.isEven ? 'M' : 'X'));
        await send(const PuzzleTicked());
      }
      expect(ready().elapsedSec, 65);
      expect(repo.saves, hasLength(2)); // at 30 s and 60 s
      expect(repo.saves.first.create, isTrue);
      expect(repo.saves.last.create, isFalse);
      expect(bloc.saveCount, 2);
    });

    test('no writes while nothing changes', () async {
      await open();
      await tick(90);
      expect(repo.saves, isEmpty);
    });

    test('pause saves and stops the clock; resume restarts it', () async {
      await open();
      await send(const PuzzleLetterTyped('M'));
      await tick(3);
      await send(const PuzzleLifecycleChanged(active: false));
      expect(repo.saves, hasLength(1));
      expect(repo.saves.single.progress.elapsedSec, 3);
      expect(ready().paused, isTrue);
      await tick(5);
      expect(ready().elapsedSec, 3);
      await send(const PuzzleLifecycleChanged(active: true));
      await tick(2);
      expect(ready().elapsedSec, 5);
    });

    test('leaving after only looking creates no progress doc', () async {
      await open();
      await tick(10);
      await bloc.saveNow();
      expect(repo.saves, isEmpty);
    });

    test('leaving saves time spent on an existing doc', () async {
      repo.progress = CrosswordProgressEntity(
          puzzleId: repo.puzzle.id, letters: exampleLetters['inProgress']!);
      await open();
      await tick(4);
      await bloc.saveNow();
      expect(repo.saves.single.create, isFalse);
      expect(repo.saves.single.progress.elapsedSec, 4);
    });

    test('a failed save is retried on the next chance', () async {
      await open();
      repo.failSave = true;
      await send(const PuzzleLetterTyped('M'));
      await bloc.saveNow();
      expect(repo.saves, isEmpty);
      repo.failSave = false;
      await bloc.saveNow();
      expect(repo.saves, hasLength(1));
    });

    test('leaving while an autosave is writing saves the newer letters',
        () async {
      await open();
      await send(const PuzzleLetterTyped('M'));
      repo.saveGate = Completer<void>();
      final autosave = bloc.saveNow();
      await send(const PuzzleLetterTyped('U'));
      final leave = bloc.saveNow();
      repo.saveGate!.complete();
      await Future.wait([autosave, leave]);
      expect(repo.saves, hasLength(2));
      expect(repo.saves.first.create, isTrue);
      expect(repo.saves.last.create, isFalse);
      expect(repo.saves.last.progress.letters, startsWith('MU'));
    });
  });

  group('submit', () {
    test('sends letters, time and hints; emits the outcome once', () async {
      await open();
      await send(const PuzzleLetterTyped('M'));
      await tick(7);
      await send(const PuzzleSubmitted());
      await send(const PuzzleSubmitted());
      expect(repo.submits, hasLength(1));
      final sent = repo.submits.single.progress;
      expect(sent.elapsedSec, 7);
      expect(sent.letters, startsWith('M......#'));
      expect(ready().outcome, repo.outcome);
      // Finished: the clock and edits stop.
      await tick(3);
      await send(const PuzzleLetterTyped('Q'));
      expect(ready().elapsedSec, 7);
      expect(ready().grid.letterAt(1), '');
    });

    test('edits, checks and reveals wait while the submit is sending',
        () async {
      await open();
      await send(const PuzzleLetterTyped('M'));
      repo.submitGate = Completer<void>();
      await send(const PuzzleSubmitted());
      expect(ready().submitting, isTrue);
      final letters = ready().grid.lettersString;
      await send(const PuzzleLetterTyped('U'));
      await send(const PuzzleBackspacePressed());
      await send(const PuzzleCheckPressed());
      await send(const PuzzleRevealRequested(word: true));
      await send(const PuzzleClueShown());
      expect(ready().grid.lettersString, letters);
      expect(ready().checksUsed, 0);
      expect(ready().hintsUsed, HintCount.zero);
      repo.submitGate!.complete();
      await settle();
      expect(ready().outcome, repo.outcome);
    });

    test('an error shows the server message and allows a retry', () async {
      await open();
      repo.failSubmit = true;
      await send(const PuzzleSubmitted());
      expect(ready().submitting, isFalse);
      expect(ready().notice!.isError, isTrue);
      expect(ready().notice!.message, contains('Too many tries'));
      repo.failSubmit = false;
      await send(const PuzzleSubmitted());
      expect(ready().outcome, isNotNull);
    });

    test('opening a completed puzzle fetches the stored result', () async {
      repo.progress = CrosswordProgressEntity(
        puzzleId: repo.puzzle.id,
        status: CrosswordProgressStatus.completed,
        letters: exampleLetters['completedWithTypo']!,
      );
      await open();
      await settle();
      expect(repo.submits, hasLength(1));
      expect(ready().outcome, isNotNull);
    });
  });

  test('report sends the active word', () async {
    await open();
    await send(const PuzzleWordSelected('2D'));
    await send(
        const PuzzleReported(reason: ReportReason.typo, message: 'Vaikkom?'));
    final report = repo.reports.single;
    expect(report.wordId, '2D');
    expect(report.questionId, 'q-vaikom');
    expect(report.reason, ReportReason.typo);
    expect(ready().notice!.message, contains('2 Down'));
  });
}
