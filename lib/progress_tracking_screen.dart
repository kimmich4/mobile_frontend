import 'package:flutter/material.dart';
import 'main_screen.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFDDE5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildContent(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
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
                    MainScreen.switchTab(0);
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
          // Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildToggleItem('Week', 0),
                _buildToggleItem('Month', 1),
                _buildToggleItem('Year', 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: _selectedPeriod == index ? const Color(0xFF0FA4AF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: _selectedPeriod == index ? Colors.white : const Color(0xFFAFDDE5),
              fontSize: 16,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildStatsGrid(),
          const SizedBox(height: 24),
          _buildWeightProgressSection(),
          const SizedBox(height: 16),
          _buildCaloriesOverviewSection(),
          const SizedBox(height: 16),
          _buildConsistencySection(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildStatCard(
                'Weight Lost',
                '1.3 kg',
                'This week',
                Icons.trending_down,
                const [Color(0xFF0FA4AF), Color(0xFF024950)],
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Avg Calories',
                '2,260',
                'burned/day',
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
                'To Goal',
                '8.7 kg',
                '~8 weeks',
                Icons.flag_outlined,
                [const Color(0xFF964734), const Color(0xFF964734).withOpacity(0.8)],
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Workouts',
                '4/5',
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

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, List<Color>? gradient, {bool isWhite = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isWhite ? Colors.white : null,
        gradient: gradient != null ? LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.8,
            child: Icon(icon, color: isWhite ? const Color(0xFF024950) : Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: isWhite ? const Color(0x99024950) : Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isWhite ? const Color(0xFF003135) : Colors.white,
              fontSize: 18,
              fontFamily: 'Arial',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: isWhite ? const Color(0xFF0FA4AF) : Colors.white.withOpacity(0.75),
              fontSize: 12,
              fontFamily: 'Arial',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightProgressSection() {
    return _buildChartContainer(
      title: 'Weight Progress',
      subtitle: '-1.3 kg this week',
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildYAxisLabel('79'),
              _buildYAxisLabel('78.25'),
              _buildYAxisLabel('77.5'),
              _buildYAxisLabel('76.75'),
              _buildYAxisLabel('76'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildXAxisLabel('Mon'),
              _buildXAxisLabel('Tue'),
              _buildXAxisLabel('Wed'),
              _buildXAxisLabel('Thu'),
              _buildXAxisLabel('Fri'),
              _buildXAxisLabel('Sat'),
              _buildXAxisLabel('Sun'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesOverviewSection() {
    return _buildChartContainer(
      title: 'Calories Overview',
      child: Column(
        children: [
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildCalorieBar(0.6, 0.4),
                _buildCalorieBar(0.8, 0.5),
                _buildCalorieBar(0.5, 0.7),
                _buildCalorieBar(0.9, 0.4),
                _buildCalorieBar(0.7, 0.6),
                _buildCalorieBar(0.4, 0.8),
                _buildCalorieBar(0.6, 0.5),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Burned', const Color(0xFF964734)),
              const SizedBox(width: 24),
              _buildLegendItem('Consumed', const Color(0xFF0FA4AF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieBar(double burnedHeightFactor, double consumedHeightFactor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 8,
          height: 150 * burnedHeightFactor,
          decoration: BoxDecoration(
            color: const Color(0xFF964734),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 8,
          height: 150 * consumedHeightFactor,
          decoration: BoxDecoration(
            color: const Color(0xFF0FA4AF),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildConsistencySection() {
    return _buildChartContainer(
      title: 'Workout Consistency',
      subtitle: '80% completion rate',
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildConsistencyDay('Mon', true),
              _buildConsistencyDay('Tue', true),
              _buildConsistencyDay('Wed', true),
              _buildConsistencyDay('Thu', false),
              _buildConsistencyDay('Fri', true),
              _buildConsistencyDay('Sat', false),
              _buildConsistencyDay('Sun', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartContainer({required String title, String? subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF003135),
              fontSize: 16,
              fontFamily: 'Arial',
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
                    fontFamily: 'Arial',
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

  Widget _buildYAxisLabel(String text) => Text(text, style: const TextStyle(color: Color(0xFF024950), fontSize: 10, fontFamily: 'Inter'));
  Widget _buildXAxisLabel(String text) => Text(text, style: const TextStyle(color: Color(0xFF024950), fontSize: 10, fontFamily: 'Inter'));

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xB2024950), fontSize: 14, fontFamily: 'Arial'),
        ),
      ],
    );
  }

  Widget _buildConsistencyDay(String day, bool completed) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
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
          style: const TextStyle(color: Color(0x99024950), fontSize: 12, fontFamily: 'Arial'),
        ),
      ],
    );
  }
}