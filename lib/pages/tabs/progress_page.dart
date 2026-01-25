import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:trainexa/models/workout_session.dart';
import 'package:trainexa/services/storage_service.dart';
import 'package:trainexa/auth/supabase_auth_manager.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final storage = StorageService();
  List<WorkoutSession> sessions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final authManager = SupabaseAuthManager();
    final user = authManager.getCurrentUser();
    if (user == null) {
      setState(() => loading = false);
      return;
    }
    final s = await storage.loadSessions(user.uid);
    setState(() {
      sessions = s;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    final weekly = _groupVolumeByWeek(sessions);
    final spots = weekly.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Your Progress', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (v, meta) => Padding(padding: const EdgeInsets.only(top: 8), child: Text('W${v.toInt()}')))),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, m) => Text(v.toInt().toString()))),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: Theme.of(context).colorScheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  spots: [
                    for (var i = 0; i < spots.length; i++) FlSpot(i.toDouble() + 1, spots[i].value / 100),
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Uptrend is good. Keep consistency!'),
      ],
    );
  }

  Map<int, double> _groupVolumeByWeek(List<WorkoutSession> sessions) {
    final map = <int, double>{};
    for (final s in sessions) {
      final week = int.parse('${s.date.year}${_weekOfYear(s.date).toString().padLeft(2, '0')}');
      map[week] = (map[week] ?? 0) + s.totalVolumeLbs;
    }
    return map;
  }

  int _weekOfYear(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final diff = date.difference(firstDay).inDays + firstDay.weekday;
    return (diff / 7).floor() + 1;
  }
}
