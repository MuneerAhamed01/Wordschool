## WordSchool

WordSchool is a Wordle-style word game built with Flutter. It includes anonymous and Google auth, a clean feature-first architecture, state management with BLoC/Cubit, DI via GetIt, routing with GoRouter, and theming. The game validates words against an embedded dictionary and evaluates guesses with Wordle logic (green/orange/none).

### Tech Stack
- **Flutter**: UI framework
- **flutter_bloc**: BLoC/Cubit state management
- **go_router**: Routing
- **get_it**: Dependency injection/service locator
- **shared_preferences**: Local session persistence
- **firebase_core, firebase_auth, google_sign_in**: Auth
- **flip_card**: Tile animation helper
- **flutter_dotenv**: Environment variables (optional)

## Project Structure
```
lib/
  config/
    themes/               # App theme definitions (colors, fonts)
  core/
    constants/            # Global constants/strings
    enums/                # App-wide enums (e.g., WordTileType)
    errors/               # Error models
    resorces/             # DataState, UseCase base, request helpers
    routes/               # GoRouter setup and providers
    utils/                # Utilities (valid words loader)
  di.dart                 # GetIt dependency registration
  features/
    auth/                 # Clean layers: data/domain/presentation
      data/
        data_source/      # Firebase + GoogleSignIn
        repositories/
      domain/
        repositories/
        usecases/
      presentation/
        bloc/             # AuthBloc
        pages/
    game/
      presentation/
        bloc/             # WordCubit
        pages/            # GamePage + helper mixin
        utils/            # Letter, Word, constants
        widgets/          # Keyboard UI
  shared/                 # Cross-feature modules
    data/                 # SessionHandler and impl
    domains/              # Entities, repository contracts, usecases
    presentations/        # Shared widgets (tiles, buttons, snackbar)
  main.dart               # App entry and MaterialApp
  firebase_options.dart   # FlutterFire (generated)
```

## Architecture Overview

### Feature-first with Clean Architecture flavors
- **auth** uses a layered approach:
  - data: platform services (FirebaseAuth, GoogleSignIn) + repo impl
  - domain: repository contracts and use cases
  - presentation: BLoC + UI page
- **game** currently houses presentation-only (Wordle logic lives in Cubit and UI utils). Domain/data can be added later if the game state grows.
- **shared** contains cross-cutting concepts (session) built with the same clean-style separation.

### Dependency Injection
- `get_it` is initialized in `di.dart` and run from `main.dart` before `runApp`.
- Registers `SharedPreferences`, `SessionHandler`, `SessionRepository`, auth data sources/repos/use cases, and `ValidWords` loader.

### Routing
- `GoRouter` builds per-route providers lazily:
  - `AuthPage` gets an `AuthBloc` with injected use cases
  - `GamePage` gets a `WordCubit` with injected `ValidWords`
- Initial route is chosen based on `SessionHandler.currentUser`.

### State Management
- **AuthBloc**: handles anonymous and Google sign-in, then persists user via `SessionHandler` through `SessionRepository`.
- **WordCubit**: holds the grid of guessed words (`List<Word>`). Each `Word` contains a `List<Letter>` with a `WordTileType` representing evaluation.

## Key Modules and Flows

### App Bootstrap
1. `main.dart` initializes Flutter bindings, Firebase, dotenv, and DI via `initializeDependency()`.
2. Reads current session; chooses initial route (`/game` or `/auth`).
3. `appRouter` provides feature-level BLoCs/Cubits per route.

### Session and Auth Flow
- `SessionHandler` wraps `SharedPreferences` to persist a simplified `WordSchoolUserModel`.
- `AuthBloc` invokes use cases:
  - Anonymous sign-in
  - Sign in with Google
  - Save user session (`SaveUserSessionUseCase` -> `SessionRepository` -> `SessionHandler`)
- On success, `AuthBloc` emits `authenticated` and navigation proceeds to the game route.

### Game Representation
- `Word`: a row in the grid; tracks `letters` and `isCompleted`.
- `Letter`: stores the character and an optional `WordTileType`.
- `WordTileType`: `{ green, none, orange, error }` (UI maps colors: green, gray, orange, red). In current gameplay, non-present letters are styled as `none` (gray).

### UI Composition
- `GamePage` builds a 5x5 grid for 5 guesses of 5 letters, plus a `CustomKeyboard`.
- `listenToWord` and `GamePageHelper` handle feedback like shaking invalid rows.
- `WordTile` renders a single cell with gradient/color based on `WordTileType`.

### Input Flow and Validation
1. Typing on the `CustomKeyboard` calls `WordCubit.addLetter` to append letters to the active row.
2. Backspace removes the last letter; if a row is empty, it gets removed.
3. Enter triggers `onSubmitWord`, which calls `WordCubit.submitWordIfValid`.
4. `ValidWords` validates the guessed word against `assets/words/words.txt`.
5. If invalid, the row tiles are shaken and a snackbar is shown.
6. If valid, `_checkAndUpdateTheWordStatus` evaluates each letter against the active target word.

### Word Evaluation (Wordle Logic)
- Two-pass evaluation to correctly handle duplicates:
  - First pass marks exact matches as `green` and reserves those target positions.
  - Second pass uses remaining target letter counts to mark `orange` for in-word, wrong-position letters; otherwise `none`.
- After evaluation, the active `Word` is marked `isCompleted` and the grid updates.

## Important References

Entry and DI
```1:27:lib/main.dart
import 'package:firebase_core/firebase_core.dart';
...
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load();
  await initializeDependency();
  runApp(const MainApp());
}
```

Routing and Providers
```9:35:lib/core/routes/app_router.dart
GoRouter appRouter(String initialRoute) {
  return GoRouter(
    initialLocation: initialRoute,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AuthPage.routeName,
        ...
      ),
      GoRoute(
        path: GamePage.routeName,
        builder: (context, state) => BlocProvider(
          create: (context) => WordCubit(validWords: getIt()),
          child: const GamePage(),
        ),
      ),
    ],
  );
}
```

Valid Words Loader
```3:16:lib/core/utils/valid_words.dart
class ValidWords {
  final List<String> _validWords = [];
  Future<void> loadWords() async {
    final data = await rootBundle.loadString('assets/words/words.txt');
    _validWords.addAll(data.split('\n').map((e) => e.trim().toLowerCase()));
  }
  bool checkIsValidWord(String word) => _validWords.contains(word.toLowerCase());
}
```

Word Evaluation (inside WordCubit)
```96:114:lib/features/game/presentation/bloc/word_cubit/word_cubit.dart
Future<void> _checkAndUpdateTheWordStatus(String word) async {
  final activeWordIndex = _findActiveWordIndex();
  if (activeWordIndex == -1) return;
  final activeWord = state[activeWordIndex];
  if (!_hasRequiredLetters(activeWord)) return;
  final targetChars = word.trim().toUpperCase().split('');
  final guessChars = activeWord.letters.map((l) => l.letter.toUpperCase()).toList();
  final types = _evaluateGuess(guessChars, targetChars);
  final updatedWord = _applyEvaluationToWord(activeWord, types);
  _emitUpdatedWordAt(activeWordIndex, updatedWord);
}
```

## Setup & Running

### Prerequisites
- Flutter SDK installed (`flutter doctor` clean)
- Firebase project set up; `firebase_options.dart` generated (already present)
- Platform config:
  - iOS: `ios/Runner/GoogleService-Info.plist` (present)
  - Android: `android/app/google-services.json` (present)

### Install dependencies
```bash
flutter pub get
```

### Run the app
```bash
flutter run -d ios        # or
flutter run -d android
```

### Build
```bash
flutter build ios         # creates an Xcode archive workspace
flutter build apk         # Android APK
```

## Configuration
- `.env` (optional): Loaded via `flutter_dotenv`. If you add env keys, ensure to include and read them explicitly.
- Assets: `assets/words/words.txt` must be listed in `pubspec.yaml` (already referenced).

## Extending the Game
- Replace the static daily word with an API:
  - Inject a `GameRepository` and `GetDailyWordUseCase` into `WordCubit` creation in the router.
  - Load the daily word before first submission and pass it to `submitWordIfValid`.
- Persist keyboard state (letters colored by highest achieved status per Wordle rules).
- Add animations (flip, reveal) to tiles on evaluation.
- Track stats and streaks in local storage or Firestore.

## Troubleshooting
- Asset not found: `flutter clean`, verify `pubspec.yaml` assets section, and run `flutter pub get`.
- Firebase initialization errors: confirm `firebase_options.dart` matches your Firebase project and platform configs are present.
- iOS pods issues: run `cd ios && pod repo update && pod install`, then `cd ..` and `flutter clean && flutter pub get`.

## License
This project is for educational/demo purposes. Add a LICENSE file if you intend to distribute.
