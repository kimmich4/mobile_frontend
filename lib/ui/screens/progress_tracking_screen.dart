import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/progress_tracking_view_model.dart';
import '../../viewmodels/main_view_model.dart';

class ProgressTrackingScreen extends StatelessWidget {
  const ProgressTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressTrackingViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, viewModel),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildStatsGrid(context, viewModel),
                      const SizedBox(height: 24),
                      _buildWeightProgressSection(context, viewModel),
                      const SizedBox(height: 16),
                      _buildCaloriesOverviewSection(context, viewModel),
                      const SizedBox(height: 16),
                      _buildConsistencySection(context, viewModel),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ProgressTrackingViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF003135), Color(0xFF024950)],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    MainViewModel.switchTabStatic(0);
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              const Text(
                'Progress Tracking',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildToggleItem(viewModel, 'Week', 0),
                _buildToggleItem(viewModel, 'Month', 1),
                _buildToggleItem(viewModel, 'Year', 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(ProgressTrackingViewModel viewModel, String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => viewModel.setSelectedPeriod(index),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: viewModel.selectedPeriod == index ? const Color(0xFF0FA4AF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: viewModel.selectedPeriod == index ? Colors.white : const Color(0xFFAFDDE5),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, ProgressTrackingViewModel viewModel) {
    final stats = viewModel.stats;
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildStatCard(
                context,
                'Weight Lost',
                '${stats.weightLostKg} kg',
                stats.weightLostPeriod,
                Icons.trending_down,
                const [Color(0xFF0FA4AF), Color(0xFF024950)],
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                context,
                'Avg Calories',
                '${stats.avgCaloriesBurned}',
                stats.caloriesPeriod,
                Icons.local_fire_department_outlined,
                null,
                isWhite: true,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _buildStatCard(
                context,
                'To Goal',
                '${stats.toGoalKg} kg',
                stats.toGoalTime,
                Icons.flag_outlined,
                [const Color(0xFF964734), const Color(0xFF964734).withOpacity(0.8)],
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                context,
                'Workouts',
                '${stats.workoutsCompleted}/${stats.workoutsGoal}',
                'completed',
                Icons.fitness_center,
                null,
                isWhite: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String subtitle, IconData icon, List<Color>? gradient, {bool isWhite = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isWhite ? Theme.of(context).colorScheme.surface : null,
        gradient: gradient != null ? LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.8,
            child: Icon(icon, color: isWhite ? Theme.of(context).colorScheme.onSurface : Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: isWhite ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6) : Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isWhite ? Theme.of(context).colorScheme.onSurface : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: isWhite ? Theme.of(context).colorScheme.primary : Colors.white.withOpacity(0.75),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightProgressSection(BuildContext context, ProgressTrackingViewModel viewModel) {
    return _buildChartContainer(
      context,
      title: 'Weight Progress',
      subtitle: '-1.3 kg this week',
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < viewModel.weightData.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _buildAxisLabel(context, viewModel.weightData[value.toInt()].day),
                      );
                    }
                    return const SizedBox();
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: viewModel.weightData.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value.weight);
                }).toList(),
                isCurved: true,
                color: const Color(0xFF0FA4AF),
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0FA4AF).withOpacity(0.3),
                      const Color(0xFF0FA4AF).withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => const Color(0xFF024950),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y} kg',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesOverviewSection(BuildContext context, ProgressTrackingViewModel viewModel) {
    return _buildChartContainer(
      context,
      title: 'Calories Overview',
      child: Column(
        children: [
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 3000,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF024950),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String category = rodIndex == 0 ? 'Burned' : 'Consumed';
                      return BarTooltipItem(
                        '$category\n',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: '${rod.toY.toInt()} cal',
                            style: const TextStyle(color: Color(0xFFAFDDE5), fontWeight: FontWeight.w500, fontSize: 12),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < viewModel.caloriesData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: _buildAxisLabel(context, viewModel.caloriesData[value.toInt()].day),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: viewModel.caloriesData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.burned.toDouble(),
                        color: const Color(0xFF964734),
                        width: 10,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: entry.value.consumed.toDouble(),
                        color: const Color(0xFF0FA4AF),
                        width: 10,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(context, 'Burned', const Color(0xFF964734)),
              const SizedBox(width: 24),
              _buildLegendItem(context, 'Consumed', const Color(0xFF0FA4AF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencySection(BuildContext context, ProgressTrackingViewModel viewModel) {
    return _buildChartContainer(
      context,
      title: 'Workout Consistency',
      subtitle: '80% completion rate',
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: viewModel.consistencyData.days.map((d) => 
              _buildConsistencyDay(context, d.dayName, d.isCompleted)
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(BuildContext context, {required String title, String? subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.trending_down, color: Color(0xFF0FA4AF), size: 16),
                const SizedBox(width: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF0FA4AF),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildAxisLabel(BuildContext context, String text) => Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 10));

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildConsistencyDay(BuildContext context, String day, bool completed) {
    return Column(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: completed ? const Color(0xFF0FA4AF) : const Color(0x190FA4AF),
            gradient: completed ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0FA4AF), Color(0xFF024950)]) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            completed ? '✓' : '—',
            style: TextStyle(color: completed ? Colors.white : const Color(0x66024950), fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
        ),
      ],
    );
  }
}

