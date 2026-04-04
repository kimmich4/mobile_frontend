import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/progress_tracking_view_model.dart';
import '../../viewmodels/main_view_model.dart';
import '../../data/models/progress_model.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize progress data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressTrackingViewModel>().init();
    });
  }

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
                      _buildLogWeightCard(context, viewModel),
                      const SizedBox(height: 16),
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
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0FA4AF)));
    }
    
    final stats = viewModel.stats;
    if (stats == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(Icons.analytics_outlined, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text(
              'No progress data yet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete workouts and meals to see your stats',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
    
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildStatCard(
                context,
                stats.weightLostPeriod.contains('gained') ? 'Weight Gained' : 'Weight Lost',
                '${stats.weightLostKg} kg',
                stats.weightLostPeriod,
                stats.weightLostPeriod.contains('gained') ? Icons.trending_up : Icons.trending_down,
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
                stats.toGoalLabel,
                '${stats.toGoalKg} kg',
                stats.toGoalTime,
                Icons.flag_outlined,
                const [Color(0xFF964734), Color(0xFF964734)],
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
    // Determine subtitle icon direction
    final isGained = viewModel.weightProgressSubtitle.contains('+') ||
        viewModel.weightProgressSubtitle.contains('gained');
    final subtitleIcon = isGained ? Icons.trending_up : Icons.trending_down;

    return _buildChartContainer(
      context,
      title: 'Weight Progress',
      subtitle: viewModel.weightProgressSubtitle,
      subtitleIcon: subtitleIcon,
      child: viewModel.weightData.isEmpty
          ? _buildEmptyChartState(
              context,
              'No weight logs yet',
              'Tap "Log Today\'s Weight" above to start tracking')
          : SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _getWeightInterval(viewModel),
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value != value.toInt()) return const SizedBox();
                              final int x = value.toInt();
                              String label = '';
                              if (viewModel.selectedPeriod == 0) {
                                // Week
                                const wLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                if (x >= 0 && x < 7) label = wLabels[x];
                              } else if (viewModel.selectedPeriod == 1) {
                                // Month
                                if (x >= 1 && x <= 31) label = x.toString();
                                // Only show every 5th day label, plus 1st, to avoid overlap
                                if (x != 1 && x % 5 != 0) label = '';
                              } else {
                                // Year
                                const yLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                if (x >= 1 && x <= 12) label = yLabels[x - 1];
                                // Only show every 2nd or 3rd month if overlap occurs, but 12 fits usually.
                              }
                              
                              if (label.isEmpty) return const SizedBox();
                              
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles:
                            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles:
                            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: viewModel.selectedPeriod == 0 ? 0 : 1,
                      maxX: viewModel.selectedPeriod == 0 ? 6 : (viewModel.selectedPeriod == 1 ? 31 : 12),
                      minY: _getWeightMinY(viewModel),
                      maxY: _getWeightMaxY(viewModel),
                      lineBarsData: [
                        LineChartBarData(
                          spots: viewModel.weightData.map((d) {
                            return FlSpot(d.x, d.weight);
                          }).toList(),
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: const Color(0xFF0FA4AF),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: const Color(0xFF0FA4AF),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
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
                        enabled: viewModel.weightData.length > 1,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => const Color(0xFF024950),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              // Find the data point that matches this exact X coordinate
                              final point = viewModel.weightData.firstWhere(
                                (d) => d.x == spot.x,
                                orElse: () => WeightDataPoint(day: '', weight: 0.0, x: 0.0),
                              );
                              
                              return LineTooltipItem(
                                '${point.day}\n${spot.y.toStringAsFixed(1)} kg',
                                const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
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
    // Compute dynamic maxY from actual data
    double maxY = 500;
    for (final point in viewModel.caloriesData) {
      if (point.burned > maxY) maxY = point.burned.toDouble();
      if (point.consumed > maxY) maxY = point.consumed.toDouble();
    }
    maxY = (maxY * 1.2).ceilToDouble();
    maxY = ((maxY / 500).ceil() * 500).toDouble();
    if (maxY < 500) maxY = 500;

    final periodLabel = viewModel.currentPeriod.displayName;
    final emptySubtitle = viewModel.selectedPeriod == 0
        ? 'Complete meals and workouts this week'
        : viewModel.selectedPeriod == 1
            ? 'Meals and workouts this month will appear here'
            : 'Year-to-date meals and workouts will appear here';

    return _buildChartContainer(
      context,
      title: 'Calories — $periodLabel',
      child:
          viewModel.caloriesData.isEmpty ||
                  viewModel.caloriesData.every((d) => d.burned == 0 && d.consumed == 0)
              ? _buildEmptyChartState(context, 'No calorie data yet', emptySubtitle)
              : Column(
                  children: [
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxY,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => const Color(0xFF024950),
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final String category =
                                    rodIndex == 0 ? 'Burned' : 'Consumed';
                                return BarTooltipItem(
                                  '$category\n',
                                  const TextStyle(
                                      color: Colors.white, fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(
                                      text: '${rod.toY.toInt()} cal',
                                      style: const TextStyle(
                                          color: Color(0xFFAFDDE5),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12),
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
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < viewModel.caloriesData.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: _buildAxisLabel(context,
                                          viewModel.caloriesData[value.toInt()].day),
                                    );
                                  }
                                  return const SizedBox();
                                },
                                reservedSize: 30,
                              ),
                            ),
                            leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                          barGroups:
                              viewModel.caloriesData.asMap().entries.map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.burned.toDouble(),
                                  color: const Color(0xFF964734),
                                  width: 10,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4)),
                                ),
                                BarChartRodData(
                                  toY: entry.value.consumed.toDouble(),
                                  color: const Color(0xFF0FA4AF),
                                  width: 10,
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4)),
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
      subtitle: viewModel.consistencySubtitle,
      child: Column(
        children: [
          const SizedBox(height: 20),
          viewModel.consistencyData.days.isEmpty
              ? _buildEmptyChartState(context, 'No workout data', 'Complete a workout to see your streak')
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: viewModel.consistencyData.days.map((d) => 
                    _buildConsistencyDay(context, d.dayName, d.isCompleted)
                  ).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyChartState(BuildContext context, String title, String subtitle) {
    return Container(
      height: 150,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined, size: 36, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer(BuildContext context,
      {required String title,
      String? subtitle,
      IconData subtitleIcon = Icons.trending_down,
      required Widget child}) {
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
          if (subtitle != null && subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(subtitleIcon, color: const Color(0xFF0FA4AF), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF0FA4AF),
                      fontSize: 14,
                    ),
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

  // --- Chart helpers ---

  double _getWeightMinY(ProgressTrackingViewModel viewModel) {
    if (viewModel.weightData.isEmpty) return 0;
    final minW = viewModel.weightData.map((d) => d.weight).reduce((a, b) => a < b ? a : b);
    return (minW - 3).floorToDouble().clamp(0, double.infinity);
  }

  double _getWeightMaxY(ProgressTrackingViewModel viewModel) {
    if (viewModel.weightData.isEmpty) return 100;
    final maxW = viewModel.weightData.map((d) => d.weight).reduce((a, b) => a > b ? a : b);
    return (maxW + 3).ceilToDouble();
  }

  double _getWeightInterval(ProgressTrackingViewModel viewModel) {
    final range = _getWeightMaxY(viewModel) - _getWeightMinY(viewModel);
    if (range <= 6) return 1;
    if (range <= 15) return 2;
    return 5;
  }

  // --- Log Weight Card ---

  Widget _buildLogWeightCard(BuildContext context, ProgressTrackingViewModel viewModel) {
    final signupW = viewModel.signupWeight;
    final trackedW = viewModel.latestTrackedWeight;

    double? diffKg;
    if (signupW != null && trackedW != null) {
      diffKg = trackedW - signupW;
    }

    final bool hasTracked = trackedW != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003135), Color(0xFF024950)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0FA4AF).withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF0FA4AF).withOpacity(0.20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.monitor_weight_outlined, color: Color(0xFF0FA4AF), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Track Your Weight',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Weight comparison row
          Row(
            children: [
              // Starting weight tile
              Expanded(
                child: _buildWeightTile(
                  context,
                  label: 'Starting Weight',
                  value: signupW != null ? '${signupW.toStringAsFixed(1)} kg' : '—',
                  icon: Icons.flag_outlined,
                  iconColor: const Color(0xFFAFDDE5),
                ),
              ),
              // Arrow / diff indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Icon(
                      diffKg == null
                          ? Icons.compare_arrows
                          : diffKg < 0
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                      color: diffKg == null
                          ? Colors.white38
                          : diffKg < 0
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFEF5350),
                      size: 22,
                    ),
                    if (diffKg != null) ...
                      [
                        const SizedBox(height: 2),
                        Text(
                          '${diffKg >= 0 ? '+' : ''}${diffKg.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: diffKg < 0 ? const Color(0xFF4CAF50) : const Color(0xFFEF5350),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                  ],
                ),
              ),
              // Current tracked weight tile
              Expanded(
                child: _buildWeightTile(
                  context,
                  label: 'Current Weight',
                  value: hasTracked ? '${trackedW.toStringAsFixed(1)} kg' : 'Not logged',
                  icon: Icons.track_changes,
                  iconColor: hasTracked ? const Color(0xFF0FA4AF) : Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Log button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: viewModel.isSavingWeight
                  ? null
                  : () => _showLogWeightDialog(context, viewModel),
              icon: viewModel.isSavingWeight
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add_circle_outline, size: 18),
              label: Text(viewModel.isSavingWeight ? 'Saving…' : 'Log Today\'s Weight'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0FA4AF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogWeightDialog(BuildContext context, ProgressTrackingViewModel viewModel) {
    final TextEditingController weightController = TextEditingController();
    // Pre-fill with last tracked or signup weight
    final prefill = viewModel.latestTrackedWeight ?? viewModel.signupWeight;
    if (prefill != null) {
      weightController.text = prefill.toStringAsFixed(1);
    }
    String? errorText;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF024950),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.monitor_weight_outlined, color: Color(0xFF0FA4AF), size: 22),
                SizedBox(width: 10),
                Text(
                  'Log Today\'s Weight',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your current weight in kilograms.',
                  style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  showCursor: true,
                  cursorColor: const Color(0xFF0FA4AF),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '70.0',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    suffixText: 'kg',
                    suffixStyle: const TextStyle(color: Color(0xFF0FA4AF), fontWeight: FontWeight.bold),
                    errorText: errorText,
                    errorStyle: const TextStyle(color: Color(0xFFEF5350)),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0FA4AF), width: 2),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF0FA4AF), width: 2),
                    ),
                    errorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEF5350), width: 2),
                    ),
                    focusedErrorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEF5350), width: 2),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.55))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0FA4AF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final raw = weightController.text.trim();
                  final parsed = double.tryParse(raw);
                  if (parsed == null || parsed <= 0 || parsed > 500) {
                    setDialogState(() => errorText = 'Enter a valid weight (e.g. 70.5)');
                    return;
                  }
                  Navigator.of(dialogContext).pop();
                  viewModel.logNewWeight(parsed);
                },
                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
}
