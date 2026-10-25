import 'package:flutter/material.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/progress.dart';
import 'package:wordshool/features/crossword/shared/domain/entities/word.dart';
import 'package:wordshool/shared/presentations/widgets/app_sheet.dart';

enum HintChoice { letter, word }

/// Phase 1 hints (DEC-008): "Show a clue" is free and opens in place;
/// reveals cost 1 (letter) or 3 (word) of the per-puzzle budget. Pops with
/// the [HintChoice] picked, or null.
class HintsSheet extends StatefulWidget {
  const HintsSheet({
    super.key,
    required this.word,
    required this.revealsLeft,
    required this.letterPenalty,
    required this.wordPenalty,
    required this.clueShown,
    required this.onShowClue,
    this.canRevealLetter = true,
    this.canRevealWord = true,
  });

  final CrosswordWordEntity word;
  final int revealsLeft;

  /// XP taken per revealed letter / word (Remote Config).
  final int letterPenalty;
  final int wordPenalty;

  /// The extra clue was already opened for this word (no new count).
  final bool clueShown;
  final VoidCallback onShowClue;

  /// False when the selected square / word is already revealed.
  final bool canRevealLetter;
  final bool canRevealWord;

  @override
  State<HintsSheet> createState() => _HintsSheetState();
}

class _HintsSheetState extends State<HintsSheet> {
  late bool _clueOpen = widget.clueShown;

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final extra = word.extraClue.en.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSheetHeader(
          overline: word.label,
          title: 'Need a hint?',
          subtitle: word.clue.en,
        ),
        const SizedBox(height: 12),
        _Balance(revealsLeft: widget.revealsLeft),
        const SizedBox(height: 12),
        _HintOption(
          key: const ValueKey('hint-clue'),
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Show a clue',
          subtitle: extra.isEmpty ? 'No extra clue for this word' : 'Free',
          cost: 'Free',
          enabled: extra.isNotEmpty,
          free: true,
          onTap: () {
            if (!_clueOpen) widget.onShowClue();
            setState(() => _clueOpen = true);
          },
          expanded: _clueOpen && extra.isNotEmpty
              ? Container(
                  key: const ValueKey('hint-clue-text'),
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MyColors.clueBarBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: MyColors.clueBarBorder),
                  ),
                  child: Text(
                    '“$extra”',
                    style: const TextStyle(color: MyColors.white, height: 1.35),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 8),
        _buildOption(
          key: 'hint-letter',
          icon: Icons.text_fields_rounded,
          title: 'Reveal a letter',
          subtitle: 'Fills the selected square · −${widget.letterPenalty} XP',
          cost: HintCount.revealLetterCost,
          allowed: widget.canRevealLetter,
          choice: HintChoice.letter,
        ),
        const SizedBox(height: 8),
        _buildOption(
          key: 'hint-word',
          icon: Icons.spellcheck_rounded,
          title: 'Reveal the word',
          subtitle: 'Fills all ${word.length} letters of ${word.number} '
              '${word.direction.label} · −${widget.wordPenalty} XP',
          cost: HintCount.revealWordCost,
          allowed: widget.canRevealWord,
          choice: HintChoice.word,
        ),
        const SizedBox(height: 14),
        const Text(
          'Revealed words go to My mistakes so you can revise them later.',
          style: TextStyle(color: MyColors.navInactive, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildOption({
    required String key,
    required IconData icon,
    required String title,
    required String subtitle,
    required int cost,
    required bool allowed,
    required HintChoice choice,
  }) {
    final affordable = widget.revealsLeft >= cost;
    return _HintOption(
      key: ValueKey(key),
      icon: icon,
      title: title,
      subtitle: allowed ? subtitle : 'Already revealed',
      cost: affordable
          ? '$cost ${cost == 1 ? 'reveal' : 'reveals'}'
          : 'Not enough reveals',
      enabled: allowed && affordable,
      onTap: () => Navigator.of(context).pop(choice),
    );
  }
}

class _Balance extends StatelessWidget {
  const _Balance({required this.revealsLeft});

  final int revealsLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: MyColors.gameSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded,
              color: MyColors.hint, size: 18),
          const SizedBox(width: 8),
          Text(
            '$revealsLeft ${revealsLeft == 1 ? 'reveal' : 'reveals'} left in this puzzle',
            style: const TextStyle(
                color: MyColors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _HintOption extends StatelessWidget {
  const _HintOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cost,
    required this.enabled,
    required this.onTap,
    this.free = false,
    this.expanded,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String cost;
  final bool enabled;
  final bool free;
  final VoidCallback onTap;
  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: MyColors.gameSurface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: MyColors.gameSurfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: MyColors.hint, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  color: MyColors.white,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style: const TextStyle(
                                  color: MyColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: free ? MyColors.successBg : MyColors.warnBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cost,
                        style: TextStyle(
                          color:
                              free ? MyColors.successText : MyColors.warnText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (expanded != null) expanded!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
