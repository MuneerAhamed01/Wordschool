/// Lets routes outside the dashboard tab (game, winning) request a refresh
/// when the user returns home.
class DashboardRefreshController {
  void Function()? _onRefresh;

  void bind(void Function() onRefresh) {
    _onRefresh = onRefresh;
  }

  void unbind() {
    _onRefresh = null;
  }

  void requestRefresh() {
    _onRefresh?.call();
  }
}
