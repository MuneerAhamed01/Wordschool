import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/gradient_logo.dart';

class SlidingDialog extends StatelessWidget {
  final String title;
  final VoidCallback? onPressContinue;

  const SlidingDialog({super.key, required this.title, this.onPressContinue});

  // Example usage function
  static Future<void> show(
    BuildContext context, {
    required String title,
    VoidCallback? onPressContinue,
  }) {
    return Navigator.of(context).push<void>(
      SlidingDialogRoute(
        page: SlidingDialog(
          title: title,
          onPressContinue: onPressContinue,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        height: 300,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          border: Border.all(
            color: MyColors.gray5,
            width: 6,
          ),
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [MyColors.gray5, MyColors.gray6],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const AnimatedGradientSquares(
              squareSize: 24,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            if (onPressContinue != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 48,
                  child: AppButton(
                    onTap: onPressContinue,
                    label: 'Continue',
                    type: ButtonType.grey,
                  ),
                ),
              ),
            if (onPressContinue != null)
              const SizedBox(height: 12)
            else
              const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 48,
                child: AppButton(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  label: 'Back',
                  type: ButtonType.background,
                ),
              ),
            ),
            if (onPressContinue == null) const SizedBox(height: 24)
          ],
        ),
      ),
    );
  }
}

class SlidingDialogRoute<T> extends PageRouteBuilder<T> {
  SlidingDialogRoute({required Widget page})
      : super(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.black.withOpacity(0.5),
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved =
                CurvedAnimation(parent: animation, curve: Curves.easeOut);
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            );
          },
        );
}
