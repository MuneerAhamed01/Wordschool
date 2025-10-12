import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wordshool/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wordshool/features/auth/utils/auth_type.dart';
import 'package:wordshool/features/game/presentation/pages/game_page.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/gradient_logo.dart';

class AuthPage extends StatelessWidget {
  static const String routeName = '/auth';
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
        listener: (ctx, state) {
          state.whenOrNull(
              authenticated: (_) => _onAuthenticate(ctx), error: (message) {});
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            const AnimatedGradientSquares(squareSize: 32),
            Text(
              'WordSchool',
              style: GoogleFonts.crimsonText(fontSize: 54, color: Colors.white),
            ),
            Text(
              'Start your day by brainstorming once :)',
              style: GoogleFonts.crimsonText(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 50),
            _buildAppButtonForGoogle(),
            const SizedBox(height: 24),
            _buildAppButtonForAnonymous(),
            const SizedBox(height: 32),
          ],
        ),
      )),
      bottomSheet: _buildTermsAndConditions(),
    );
  }

  Widget _buildAppButtonForGoogle() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isGoogleAuth =
            state.whenOrNull<AuthType?>(loading: (type) => type) ==
                AuthType.google;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 48,
            child: AppButton(
              onTap: () {
                context.read<AuthBloc>().add(AuthEvent.signInWithGoogle());
              },
              isLoading: state is AuthLoading && isGoogleAuth,
              isDisabled: state is AuthLoading,
              label: 'Continue with google',
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppButtonForAnonymous() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 48,
            child: AppButton(
              onTap: () {
                context.read<AuthBloc>().add(AuthEvent.signInAnonymously());
              },
              isLoading: state is AuthLoading &&
                  state.whenOrNull<AuthType?>(loading: (type) => type) ==
                      AuthType.anonymous,
              isDisabled: state is AuthLoading,
              label: 'Sign up anonymously',
              type: ButtonType.background,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTermsAndConditions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () {
              _launchUrl('https://sites.google.com/view/wordschool/home');
            },
            child: const Text(
              'By continue you are accepting our privacy policy. Click here to see privacy policy',
              style: TextStyle(
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 30)
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final myurl = Uri.parse(url);
    if (!await launchUrl(myurl)) {
      throw Exception('Could not launch $myurl');
    }
  }

  void _onAuthenticate(BuildContext context) {
    context.go(GamePage.routeName);
  }
}
