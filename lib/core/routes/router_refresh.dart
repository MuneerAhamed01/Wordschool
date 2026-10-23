import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifies [GoRouter] to re-run its redirect whenever [stream] emits,
/// e.g. on Firebase auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
