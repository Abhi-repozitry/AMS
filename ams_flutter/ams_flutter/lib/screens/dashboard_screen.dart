// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/attendance_record.dart';
import '../utils/theme.dart';
import '../screens/mark_attendance_screen.dart';
import '../screens/students_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final stats = app.statsForDate(_today);
    final isDark = app.darkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Text(
              DateFormat('EEEE, d MMM yyyy').format(DateTime.now()),
              style: TextStyle(
                  fontSize: 12, color: colorScheme.onSurface.withOpacity(0.5)),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: kIndigo,
              radius: 16,
              child: Text('AMS',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Today's Overview ──
          _sectionLabel(context, "Today's Overview"),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: AttendanceStatus.values.map((status) {
              return _StatCard(
                status: status,
                count: stats[status] ?? 0,
                isDark: isDark,
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // ── 7-Day Trend ──
          _sectionLabel(context, '7-Day Attendance Trend'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
              child: _TrendChart(
                provider: app,
                isDark: isDark,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Status Breakdown ──
          _sectionLabel(context, "Status Breakdown"),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: AttendanceStatus.values.map((status) {
              final studs = app.studentsWithStatus(_today, status);
              return _BreakdownCard(
                  status: status, students: studs.map((s) => s.name).toList());
            }).toList(),
          ),

          const SizedBox(height: 20),

          // ── Quick Actions ──
          Card(
            color: kIndigo,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Actions',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _QuickAction(
                        icon: Icons.download_rounded,
                        label: 'Export CSV',
                        onTap: () {
                          final csv = app.exportCSV();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'CSV ready (${csv.split('\n').length - 1} records)'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                      _QuickAction(
                        icon: Icons.edit_note,
                        label: 'Mark Attendance',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MarkAttendanceScreen(),
                            ),
                          );
                        },
                      ),
                      _QuickAction(
                        icon: Icons.person_add,
                        label: 'Add Student',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const StudentsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final AttendanceStatus status;
  final int count;
  final bool isDark;

  const _StatCard(
      {required this.status, required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(statusIcon(status), color: color, size: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  status.label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final AppProvider provider;
  final bool isDark;

  const _TrendChart({required this.provider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return DateFormat('yyyy-MM-dd').format(d);
    });

    final chartData = days.map((date) {
      final stats = provider.statsForDate(date);
      return {
        'label': DateFormat('MM/dd').format(DateTime.parse(date)),
        'present': (stats[AttendanceStatus.present] ?? 0).toDouble(),
        'absent': (stats[AttendanceStatus.absent] ?? 0).toDouble(),
        'late': (stats[AttendanceStatus.late] ?? 0).toDouble(),
        'leave': (stats[AttendanceStatus.leave] ?? 0).toDouble(),
      };
    }).toList();

    final gridColor =
        isDark ? const Color(0xFF374151) : const Color(0xFFF0F0F0);
    final labelColor =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: provider.students.length.toDouble() + 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: gridColor, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) => Text(
                  v.toInt().toString(),
                  style: TextStyle(fontSize: 10, color: labelColor),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= chartData.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      chartData[idx]['label'] as String,
                      style: TextStyle(fontSize: 9, color: labelColor),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final dayChart = chartData[group.x];
                final String label = dayChart['label'] as String;
                final double value = rod.toY;
                String status;
                switch (rodIndex) {
                  case 0:
                    status = 'Present';
                    break;
                  case 1:
                    status = 'Absent';
                    break;
                  case 2:
                    status = 'Late';
                    break;
                  case 3:
                    status = 'Leave';
                    break;
                  default:
                    status = '';
                }
                return BarTooltipItem(
                  '$status: $value\n',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: label,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: List.generate(chartData.length, (i) {
            final d = chartData[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                    toY: d['present']! as double,
                    color: const Color(0xFF22C55E),
                    width: 6,
                    borderRadius: BorderRadius.circular(3)),
                BarChartRodData(
                    toY: d['absent']! as double,
                    color: const Color(0xFFF87171),
                    width: 6,
                    borderRadius: BorderRadius.circular(3)),
                BarChartRodData(
                    toY: d['late']! as double,
                    color: const Color(0xFFFB923C),
                    width: 6,
                    borderRadius: BorderRadius.circular(3)),
                BarChartRodData(
                    toY: d['leave']! as double,
                    color: const Color(0xFF60A5FA),
                    width: 6,
                    borderRadius: BorderRadius.circular(3)),
              ],
              barsSpace: 2,
            );
          }),
        ),
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final AttendanceStatus status;
  final List<String> students;

  const _BreakdownCard({required this.status, required this.students});

  @override
  Widget build(BuildContext context) {
    final bg = statusBgColor(status);
    final textColor = statusTextColor(status);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? const Color(0xFF374151)
                : statusColor(status).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            status.label.toUpperCase(),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: textColor),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: students.isEmpty
                ? Text(
                    'None',
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.4),
                        fontStyle: FontStyle.italic),
                  )
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (_, i) => Text(
                      students[i],
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF4338CA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
