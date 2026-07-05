import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wordshool/features/auth/utils/auth_type.dart';
import 'package:wordshool/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/fade_slide_in.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';
import 'package:wordshool/shared/presentations/widgets/snackbar.dart';

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
            error: (message) {
              if (message == 'Google sign-in was cancelled' ||
                  message == 'Apple sign-in was cancelled') {
                return;
              }
              CustomSnackBar.show(
                ctx,
                message: message,
                type: SnackBarType.error,
              );
            },
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: FadeSlideIn(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLogoMark(),
                          const SizedBox(height: 28),
                          Text(
                            'WordSchool',
                            style: Theme.of(context).textTheme.displayLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Guess the word. Build your streak.',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'One puzzle, every day.',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: MyColors.textMuted,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildActions(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoMark() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MyColors.gameSurface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MyColors.gameBorder.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final letters = ['W', 'O', 'R', 'D', 'S'];
            return Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 6),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: index == 2
                      ? MyColors.tileCorrect
                      : MyColors.tileAbsent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: MyColors.tileFilled),
                ),
                alignment: Alignment.center,
                child: Text(
                  letters[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    height: 1,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (Platform.isIOS) ...[
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: _buildAppleButton(),
            ),
            const SizedBox(height: 12),
          ],
          FadeSlideIn(
            delay: const Duration(milliseconds: 120),
            child: _buildGoogleButton(),
          ),
          const SizedBox(height: 12),
          FadeSlideIn(
            delay: const Duration(milliseconds: 180),
            child: _buildGuestButton(),
          ),
          const SizedBox(height: 20),
          FadeSlideIn(
            delay: const Duration(milliseconds: 240),
            child: _buildTermsLink(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppleButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isApple =
            state.whenOrNull<AuthType?>(loading: (t) => t) == AuthType.apple;
        return AppButton(
          label: 'Continue with Apple',
          leading: SvgPicture.asset(
            'assets/svgs/apple_logo.svg',
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          variant: ButtonVariant.apple,
          isLoading: state is AuthLoading && isApple,
          isDisabled: state is AuthLoading,
          onTap: () =>
              context.read<AuthBloc>().add(const AuthEvent.signInWithApple()),
        );
      },
    );
  }

  Widget _buildGoogleButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isGoogle = state.whenOrNull<AuthType?>(loading: (t) => t) ==
            AuthType.google;
        return AppButton(
          label: 'Continue with Google',
          leading: SvgPicture.asset(
            'assets/svgs/google_logo.svg',
            width: 20,
            height: 20,
          ),
          variant: ButtonVariant.google,
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
              decorationColor: MyColors.textMuted.withValues(alpha: 0.6),
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
