import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wordshool/core/routes/admin_routes.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/shared/data/data_source/auth_service.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/fade_slide_in.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  static const routeName = AdminRoutes.login;

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _auth = adminGetIt<AdminAuthService>();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // A non-admin session restored from a previous visit.
    if (_auth.status == AdminAuthStatus.notAdmin) {
      final email = _auth.currentUser?.email ?? 'This account';
      _error = '$email is not an admin. Ask the project owner to give this '
          'account admin access, or sign in with another account.';
      _auth.signOut();
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _auth.signInWithGoogle();
    if (!mounted) return;
    // On success the router redirects to Home by itself.
    setState(() {
      _loading = false;
      if (result is DataError) _error = result.error?.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FadeSlideIn(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Logo(),
                      const SizedBox(height: 20),
                      Text(
                        'Kerala PSC Admin',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add questions, build crosswords and choose the '
                        'puzzle of the day.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium
                            ?.copyWith(color: MyColors.textSecondary),
                      ),
                      const SizedBox(height: 28),
                      AppButton(
                        label: 'Sign in with Google',
                        leading: SvgPicture.asset(
                          'assets/svgs/google_logo.svg',
                          width: 20,
                          height: 20,
                        ),
                        variant: ButtonVariant.google,
                        isLoading: _loading,
                        onTap: _signIn,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: MyColors.errorBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lock_outline,
                                  color: MyColors.errorText, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: textTheme.bodyMedium
                                      ?.copyWith(color: MyColors.errorText),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        'Only accounts with admin access can sign in.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall
                            ?.copyWith(color: MyColors.navInactive),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    const letters = ['P', 'S', 'C'];
    const colors = [
      MyColors.tileCorrect,
      MyColors.tilePresent,
      MyColors.tileCorrect
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < letters.length; i++)
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors[i],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              letters[i],
              style: const TextStyle(
                color: MyColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}
