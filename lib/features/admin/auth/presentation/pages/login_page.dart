import 'package:flutter/material.dart';
import 'package:wordshool/core/routes/admin_routes.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/resorces/data_state.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/shared/data/data_source/auth_service.dart';
import 'package:wordshool/features/admin/shared/domain/utils/sign_in_errors.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _sendingReset = false;
  bool _showPassword = false;
  String? _error;
  String? _notice;

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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_loading || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
      _notice = null;
    });
    final result = await _auth.signInWithEmail(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    // On success the router redirects to Home by itself.
    setState(() {
      _loading = false;
      if (result is DataError) _error = result.error?.message;
    });
  }

  Future<void> _resetPassword() async {
    final problem = emailProblem(_email.text);
    if (problem != null) {
      setState(() {
        _error = '$problem above, then tap "Forgot password?" again.';
        _notice = null;
      });
      return;
    }
    setState(() {
      _sendingReset = true;
      _error = null;
      _notice = null;
    });
    final result = await _auth.sendPasswordReset(_email.text);
    if (!mounted) return;
    setState(() {
      _sendingReset = false;
      if (result is DataError) {
        _error = result.error?.message;
      } else {
        _notice = 'If ${_email.text.trim()} has an account, a reset link is '
            'on its way. Check your inbox.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  child: _buildContent(Theme.of(context).textTheme),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TextTheme textTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Logo(),
        const SizedBox(height: 20),
        Text(
          'Kerala PSC Admin',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Add questions, build crosswords and choose the puzzle of the day.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: MyColors.textSecondary),
        ),
        const SizedBox(height: 28),
        _buildForm(),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _loading || _sendingReset ? null : _resetPassword,
            child: Text(_sendingReset ? 'Sending…' : 'Forgot password?'),
          ),
        ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Sign in',
          isLoading: _loading,
          onTap: _signIn,
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          _buildMessage(
            textTheme,
            text: _error!,
            icon: Icons.lock_outline,
            background: MyColors.errorBg,
            foreground: MyColors.errorText,
          ),
        ],
        if (_notice != null) ...[
          const SizedBox(height: 16),
          _buildMessage(
            textTheme,
            text: _notice!,
            icon: Icons.mark_email_read_outlined,
            background: MyColors.successBg,
            foreground: MyColors.successText,
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'Only accounts with admin access can sign in.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: MyColors.navInactive),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          children: [
            TextFormField(
              controller: _email,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: emailProblem,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: !_showPassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: _showPassword ? 'Hide password' : 'Show password',
                  icon: Icon(_showPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
              validator: passwordProblem,
              onFieldSubmitted: (_) => _signIn(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(
    TextTheme textTheme, {
    required String text,
    required IconData icon,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(color: foreground),
            ),
          ),
        ],
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
