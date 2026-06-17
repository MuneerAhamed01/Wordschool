import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wordshool/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wordshool/features/auth/utils/auth_type.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/fade_slide_in.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';
import 'package:wordshool/shared/presentations/widgets/glass_card.dart';

class AuthPage extends StatelessWidget {
  static const String routeName = '/auth';
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, state) {
          state.whenOrNull(
            authenticated: (_) => ctx.go(DashboardPage.routeName),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              FadeSlideIn(
                child: Column(
                  children: [
                    _buildLogoMark(),
                    const SizedBox(height: 24),
                    Text(
                      'WordSchool',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Guess the word. Build your streak.\nOne puzzle, every day.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              FadeSlideIn(
                delay: const Duration(milliseconds: 120),
                child: _buildGoogleButton(),
              ),
              const SizedBox(height: 12),
              FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: _buildGuestButton(),
              ),
              const SizedBox(height: 24),
              FadeSlideIn(
                delay: const Duration(milliseconds: 240),
                child: _buildTermsLink(context),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoMark() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: index == 2
                  ? const Color(0xFF538D4E)
                  : const Color(0xFF3A3A3C),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF565658)),
            ),
            child: Center(
              child: Text(
                ['W', 'O', 'R', 'D', 'S'][index],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isGoogle = state.whenOrNull<AuthType?>(loading: (t) => t) ==
            AuthType.google;
        return AppButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata_rounded,
          variant: ButtonVariant.primary,
          isLoading: state is AuthLoading && isGoogle,
          isDisabled: state is AuthLoading,
          onTap: () =>
              context.read<AuthBloc>().add(AuthEvent.signInWithGoogle()),
        );
      },
    );
  }

  Widget _buildGuestButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isGuest = state.whenOrNull<AuthType?>(loading: (t) => t) ==
            AuthType.anonymous;
        return AppButton(
          label: 'Continue as Guest',
          variant: ButtonVariant.ghost,
          isLoading: state is AuthLoading && isGuest,
          isDisabled: state is AuthLoading,
          onTap: () =>
              context.read<AuthBloc>().add(AuthEvent.signInAnonymously()),
        );
      },
    );
  }

  Widget _buildTermsLink(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchUrl('https://sites.google.com/view/wordschool/home'),
      child: Text(
        'By continuing, you agree to our Privacy Policy',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              decoration: TextDecoration.underline,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
