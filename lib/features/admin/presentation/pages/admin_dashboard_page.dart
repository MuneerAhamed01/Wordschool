import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wordshool/di_admin.dart';
import 'package:wordshool/features/admin/data/admin_api_service.dart';
import 'package:wordshool/features/admin/data/admin_environment_store.dart';
import 'package:wordshool/features/admin/domain/models/admin_metrics.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  AdminMetrics? _metrics;
  Ga4Metrics? _ga4;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = adminGetIt<AdminApiService>();
      final metrics = await api.getOperationalMetrics(days: 7);
      Ga4Metrics? ga4;
      try {
        ga4 = await api.getGa4Metrics(days: 7);
      } catch (_) {
        ga4 = const Ga4Metrics(configured: false, days: 7, message: 'GA4 unavailable');
      }
      if (!mounted) return;
      setState(() {
        _metrics = metrics;
        _ga4 = ga4;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    final metrics = _metrics!;
    final env = adminGetIt<AdminEnvironmentStore>().current;
    final health = metrics.contentHealth;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Operations (${env.label})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (!health.todayGameExists || !health.todayCaseExists)
            Card(
              color: Colors.red.shade900,
              child: ListTile(
                leading: const Icon(Icons.warning_amber),
                title: const Text('Content health alert'),
                subtitle: Text(
                  [
                    if (!health.todayGameExists)
                      'Missing daily puzzle for ${health.todayGameDateId}',
                    if (!health.todayCaseExists)
                      'Missing detective case for ${health.todayCaseDateId}',
                  ].join('\n'),
                ),
              ),
            ),
          if (health.missingPlannedCasesNext14Days.isNotEmpty)
            Card(
              color: Colors.amber.shade900,
              child: ListTile(
                leading: const Icon(Icons.event_busy),
                title: const Text('Missing planned cases'),
                subtitle: Text(
                  health.missingPlannedCasesNext14Days.join(', '),
                ),
              ),
            ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(label: 'Total users', value: '${metrics.totalUsers}'),
              _StatCard(label: 'Active (7d)', value: '${metrics.activeUsers}'),
              _StatCard(label: 'Blocked', value: '${metrics.blockedUsers}'),
              _StatCard(
                label: 'Games completed',
                value: '${metrics.totalCompletedGames}',
              ),
              _StatCard(
                label: 'Detective points',
                value: '${metrics.totalDetectivePoints}',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Daily active users (Firestore)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: _buildOpsChart(metrics.dailyActiveTrend),
          ),
          const SizedBox(height: 24),
          Text(
            'Engagement (GA4)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildGa4Section(context),
        ],
      ),
    );
  }

  Widget _buildGa4Section(BuildContext context) {
    final ga4 = _ga4;
    if (ga4 == null) return const SizedBox.shrink();

    if (!ga4.configured) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('GA4 not configured'),
              if (ga4.message != null) Text(ga4.message!),
              const SizedBox(height: 8),
              const Text(
                'Set GA4_PROPERTY_ID on Cloud Functions and enable the Analytics Data API.',
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ga4.consoleUrl != null)
          TextButton.icon(
            onPressed: () => launchUrl(Uri.parse(ga4.consoleUrl!)),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open GA4 Console'),
          ),
        SizedBox(
          height: 220,
          child: _buildGa4Chart(ga4.daily),
        ),
        const SizedBox(height: 12),
        Text('Top events', style: Theme.of(context).textTheme.titleMedium),
        ...ga4.topEvents.map(
          (e) => ListTile(
            dense: true,
            title: Text(e.eventName),
            trailing: Text('${e.count}'),
          ),
        ),
      ],
    );
  }

  Widget _buildOpsChart(List<DailyActivePoint> points) {
    if (points.isEmpty) {
      return const Center(child: Text('No data'));
    }
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                return Text(
                  points[i].dateId.substring(5),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < points.length; i++)
                FlSpot(i.toDouble(), points[i].activeUsers.toDouble()),
            ],
            isCurved: true,
            color: Colors.tealAccent,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildGa4Chart(List<Ga4DailyPoint> points) {
    if (points.isEmpty) {
      return const Center(child: Text('No GA4 data yet'));
    }
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                final date = points[i].date;
                return Text(
                  date.length >= 4 ? date.substring(date.length - 4) : date,
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: points[i].activeUsers.toDouble(),
                  color: Colors.lightBlueAccent,
                  width: 12,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
