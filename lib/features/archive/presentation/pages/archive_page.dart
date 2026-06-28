import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wordshool/config/themes/colors.dart';
import 'package:wordshool/core/utils/date_helper.dart';
import 'package:wordshool/features/archive/presentation/bloc/archive_bloc.dart';
import 'package:wordshool/features/archive/presentation/widgets/calendar_day_tile.dart';
import 'package:wordshool/features/game/presentation/pages/game_page.dart';
import 'package:wordshool/shared/domains/entities/user_game_state/user_game_data.dart';
import 'package:wordshool/shared/presentations/widgets/fade_slide_in.dart';
import 'package:wordshool/shared/presentations/widgets/game_scaffold.dart';
import 'package:wordshool/shared/presentations/widgets/glass_card.dart';

class ArchivePage extends StatelessWidget {
  static const String routeName = '/archive';

  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      safeAreaBottom: false,
      appBar: AppBar(title: const Text('Previous Games')),
      body: BlocBuilder<ArchiveBloc, ArchiveState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message) => Center(child: Text(message)),
            loaded: (year, month, history) => _buildCalendar(
              context,
              year: year,
              month: month,
              history: history,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context, {
    required int year,
    required int month,
    required Map<String, UserGameDataEntity> history,
  }) {
    final monthLabel = DateFormat.yMMMM().format(DateTime(year, month));
    final todayId = DateHelper.todayDateId();
    final firstWeekday = DateTime(year, month, 1).weekday;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final leading = firstWeekday % 7;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          FadeSlideIn(child: _monthHeader(context, monthLabel)),
          const SizedBox(height: 16),
          _weekdayRow(),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: leading + daysInMonth,
              itemBuilder: (context, index) {
                if (index < leading) return const SizedBox.shrink();
                final day = index - leading + 1;
                final dateId = DateHelper.toDateId(DateTime(year, month, day));
                return CalendarDayTile(
                  dayNumber: day,
                  status: _status(dateId, todayId, history[dateId]),
                  onTap: () => _openGame(context, dateId),
                );
              },
            ),
          ),
          FadeSlideIn(
            delay: const Duration(milliseconds: 100),
            child: _legend(),
          ),
        ],
      ),
    );
  }

  Widget _monthHeader(BuildContext context, String label) {
    final state = context.read<ArchiveBloc>().state;
    final canNext = state.maybeWhen(
      loaded: (y, m, _) {
        final now = DateTime.now();
        return y < now.year || (y == now.year && m < now.month);
      },
      orElse: () => false,
    );

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () =>
                context.read<ArchiveBloc>().add(const ArchiveEvent.previousMonth()),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: canNext
                ? () => context
                    .read<ArchiveBloc>()
                    .add(const ArchiveEvent.nextMonth())
                : null,
          ),
        ],
      ),
    );
  }

  Widget _weekdayRow() {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      children: labels
          .map(
            (l) => Expanded(
              child: Center(
                child: Text(
                  l,
                  style: const TextStyle(
                    color: MyColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _legend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      children: const [
        _DotLegend(color: MyColors.tileCorrect, label: 'Won'),
        _DotLegend(color: MyColors.tilePresent, label: 'Lost'),
        _DotLegend(color: MyColors.accentGlow, label: 'Today'),
        _DotLegend(color: MyColors.gameBorder, label: 'Open'),
      ],
    );
  }

  CalendarDayStatus _status(
    String dateId,
    String todayId,
    UserGameDataEntity? data,
  ) {
    if (DateHelper.isFutureDateId(dateId)) return CalendarDayStatus.future;
    if (dateId == todayId) {
      if (data?.isCompleted == true) {
        return data!.isCorrect ? CalendarDayStatus.won : CalendarDayStatus.lost;
      }
      return CalendarDayStatus.today;
    }
    if (data?.isCompleted == true) {
      return data!.isCorrect ? CalendarDayStatus.won : CalendarDayStatus.lost;
    }
    return CalendarDayStatus.notPlayed;
  }

  void _openGame(BuildContext context, String dateId) {
    if (DateHelper.isFutureDateId(dateId)) return;
    final archive = dateId != DateHelper.todayDateId();
    context.push(
      '${GamePage.routeName}?date=$dateId&mode=${archive ? 'archive' : 'daily'}',
    );
  }
}

class _DotLegend extends StatelessWidget {
  const _DotLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
