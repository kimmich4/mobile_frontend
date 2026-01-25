import 'package:flutter/material.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  int _selectedPeriod = 1; // 0: Week, 1: Month, 2: Year

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFDDE5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            Transform.translate(
              offset: const Offset(0, -20),
              child: _buildProgressChartSection(),
            ),
             const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 32),
       decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFF003135), Color(0xFF024950)],
        ),
         borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
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
                  color: Colors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share, color: Colors.white, size: 20), // Share icon
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Period Toggle
           Container(
            padding: const EdgeInsets.all(4),
             decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
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
          height: 36,
          decoration: BoxDecoration(
            color: _selectedPeriod == index ? const Color(0xFF0FA4AF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: _selectedPeriod == index ? Colors.white : const Color(0xFFAFDDE5),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildStatCard('Weight Lost', '1.3 kg', 'This week', const LinearGradient(
                  colors: [Color(0xFF0FA4AF), Color(0xFF024950)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )),
                const SizedBox(height: 16),
                _buildStatCard('Avg Calories', '2,260', 'burned/day', const LinearGradient( // White card
                  colors: [Colors.white, Colors.white],
                ), textColor: const Color(0xFF003135), subtitleColor: const Color(0xFF0FA4AF)),
              ],
            ),
          ),
           const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                 _buildStatCard('To Goal', '8.7 kg', '~8 weeks', const LinearGradient(
                  colors: [Color(0xFF964734), Color(0xCC964734)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )),
                const SizedBox(height: 16),
                _buildStatCard('Workouts', '4/5', 'completed', const LinearGradient( // White card
                  colors: [Colors.white, Colors.white],
                ), textColor: const Color(0xFF003135), subtitleColor: const Color(0xFF0FA4AF)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Gradient gradient, {Color textColor = Colors.white, Color? subtitleColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
         boxShadow: [
          if (textColor != Colors.white)
            const BoxShadow(
               color: Color(0x19000000),
               blurRadius: 10,
               offset: Offset(0, 8),
               spreadRadius: -6,
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2), // Adjust for white card visibility?
              // If card is white, this bg needs to be different.
              // Let's make it dynamic or simple.
               shape: BoxShape.circle,
            ),
             child: Icon(Icons.show_chart, color: textColor, size: 16), // Placeholder icon
          ),
          const SizedBox(height: 16),
           Text(
            title,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: subtitleColor ?? textColor.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChartSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
       decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
         boxShadow: const [
          BoxShadow(
             color: Color(0x19000000),
             blurRadius: 10,
             offset: Offset(0, 8),
             spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Weight Progress',
                style: TextStyle(
                  color: Color(0xFF003135),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
               Text(
                '-1.2%',
                style: TextStyle(
                  color: Color(0xFF0FA4AF),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Simple Chart Placeholder
          Container(
            height: 150,
            width: double.infinity,
             decoration: BoxDecoration(
               color: const Color(0x190FA4AF),
               borderRadius: BorderRadius.circular(16),
             ),
             alignment: Alignment.center,
             child: const Text(
               'Chart Coming Soon',
               style: TextStyle(color: Color(0xFF0FA4AF)),
             ),
          ),
        ],
      ),
    );
  }
}