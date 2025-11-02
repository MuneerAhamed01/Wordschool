import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/enums/word_tile_type.dart';
import 'package:wordshool/features/winning/presentation/widgets/animated_checkmark.dart';
import 'package:wordshool/shared/presentations/widgets/app_button.dart';
import 'package:wordshool/shared/presentations/widgets/wordle_tile/tile.dart';

class WinningPage extends StatelessWidget {
  static const String routeName = '/winning';
  const WinningPage({
    super.key,
    required this.word,
    this.isLost = false,
  });

  final String word;

  final bool isLost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                if (isLost)
                  const Text(
                    '🥺',
                    style: TextStyle(fontSize: 60),
                  )
                else
                  const AnimatedCheckmarkAvatar(
                    backgroundColor: MyColors.green2,
                  ),
                const SizedBox(height: 60),
                if (isLost) ...[
                  Text(
                    "Come back tomorrow we will add more words for you",
                    style: GoogleFonts.crimsonText(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Correct word is:",
                    style: GoogleFonts.crimsonText(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 12),

                GridView.builder(
                  itemCount: 5,
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    // childAspectRatio: 1.2,
                    // mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  shrinkWrap: true,
                  itemBuilder: (_, index) => WordTile(
                    value:
                        word.split('').elementAtOrNull(index)?.toUpperCase() ??
                            '',
                    tileType: WordTileType.green,
                    shakeCallBack: (value) {},
                  ),
                ),
                const SizedBox(height: 30),
                if (!isLost) ...[
                  Text(
                    "Congrats you have found your\nToday's word",
                    style: GoogleFonts.crimsonText(
                      fontSize: 28,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Come back tomorrow we will add more words for you",
                    style: GoogleFonts.crimsonText(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 48,
                    child: AppButton(
                      onTap: () {
                        // Get.toNamed(StreakScreen.routeName);
                      },
                      label: 'Continue to the steaks',
                      type: ButtonType.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16),
                //   child: SizedBox(
                //     height: 48,
                //     child: AppButton(
                //       onTap: () {
                //         SnackBarService.showSnackBar('message');
                //       },
                //       label: 'Play next game by watching an ad for 15 sec',
                //       type: ButtonType.background,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
