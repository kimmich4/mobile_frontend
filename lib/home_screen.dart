import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFDDE5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopSection(context),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  _buildDietPlanSection(),
                  const SizedBox(height: 16),
                  _buildWorkoutSection(),
                  const SizedBox(height: 16),
                  _buildProgressSummarySection(),
                  const SizedBox(height: 16),
                  _buildAiAssistantSection(),
                  const SizedBox(height: 16),
                  _buildDailyTipSection(),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 24),
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
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF0FA4AF), Color(0xFF964734)],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'J',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Good Evening',
                        style: TextStyle(
                          color: Color(0xFFAFDDE5),
                          fontSize: 14,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'John Doe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No new notifications")));
                  },
                  child: const Text('🔔', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Calories',
                  value: '1,847',
                  subtitle: 'of 2,200',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Workouts',
                  value: '4/5',
                  subtitle: 'this week',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Streak',
                  value: '12',
                  subtitle: 'days',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Color(0xFFAFDDE5), fontSize: 14, fontFamily: 'Arial'),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Arial', fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF0FA4AF), fontSize: 12, fontFamily: 'Arial'),
          ),
        ],
      ),
    );
  }

  Widget _buildDietPlanSection() {
    return _buildDashboardCard(
      height: 108,
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildGradientIconBox(
                      colors: [const Color(0xFF0FA4AF), const Color(0xFF024950)],
                      icon: Icons.restaurant_menu,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Today's Diet Plan",
                          style: TextStyle(color: Color(0xFF003135), fontSize: 16, fontFamily: 'Arial', fontWeight: FontWeight.w400),
                        ),
                        Text(
                          '4 meals remaining',
                          style: TextStyle(color: Color(0x99024950), fontSize: 14, fontFamily: 'Arial', fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ],
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '1,847',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Color(0xFF0FA4AF), fontSize: 16, fontFamily: 'Arial', fontWeight: FontWeight.w400),
                    ),
                    Text(
                      'cal consumed',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Color(0x99024950), fontSize: 12, fontFamily: 'Arial', fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            top: 80,
            right: 20,
            child: Container(
              height: 8,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: const Color(0x7FAFDDE5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26843500)),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.8,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(0.50, 0.00),
                      end: Alignment(0.50, 1.00),
                      colors: [Color(0xFF0FA4AF), Color(0xFF964734)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSection() {
    return _buildDashboardCard(
      height: 116,
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildGradientIconBox(
                        colors: [const Color(0xFF964734), const Color(0xFF024950)],
                        icon: Icons.fitness_center,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Workout Plan',
                              style: TextStyle(color: Color(0xFF003135), fontSize: 16, fontFamily: 'Arial', fontWeight: FontWeight.w400),
                            ),
                            Text(
                              'Upper Body - 45 min',
                              style: TextStyle(color: Color(0x99024950), fontSize: 14, fontFamily: 'Arial', fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: ShapeDecoration(
                    color: const Color(0x330FA4AF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26843500)),
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(color: Color(0xFF0FA4AF), fontSize: 14, fontFamily: 'Arial', fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 20,
            top: 80,
            child: Row(
              children: [
                Icon(Icons.list_alt, size: 14, color: Color(0x99024950)),
                SizedBox(width: 4),
                Text(
                  '6 exercises',
                  style: TextStyle(color: Color(0x99024950), fontSize: 12, fontFamily: 'Arial', fontWeight: FontWeight.w400),
                ),
                SizedBox(width: 12),
                Icon(Icons.local_fire_department, size: 14, color: Color(0x99024950)),
                SizedBox(width: 4),
                Text(
                  '~380 cal',
                  style: TextStyle(color: Color(0x99024950), fontSize: 12, fontFamily: 'Arial', fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFF024950), Color(0xFF003135)],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadows: [_buildDefaultBoxShadow()],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.bar_chart, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress Summary',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Arial', fontWeight: FontWeight.w400),
                  ),
                  Text(
                    "This week's overview",
                    style: TextStyle(color: Color(0xFFAFDDE5), fontSize: 14, fontFamily: 'Arial', fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressInfo('-1.2kg', 'Weight'),
              _buildProgressInfo('92%', 'Diet Plan'),
              _buildProgressInfo('80%', 'Workout'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiAssistantSection() {
    return _buildDashboardCard(
      height: 104,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _buildGradientIconBox(
              colors: [const Color(0xFF0FA4AF), const Color(0xFF964734)],
              icon: Icons.smart_toy,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'AI Assistant',
                    style: TextStyle(color: Color(0xFF003135), fontSize: 16, fontFamily: 'Arial', fontWeight: FontWeight.w400),
                  ),
                  Text(
                    'Ask me anything about your fitness journey',
                    style: TextStyle(color: Color(0x99024950), fontSize: 14, fontFamily: 'Arial', fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Color(0xFF0FA4AF), shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTipSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF964734), Color(0xCC964734)],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadows: [_buildDefaultBoxShadow()],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💡', style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Tip',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Arial', fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 8),
                Text(
                  'Stay hydrated! Aim for at least 8 glasses of water today to support your metabolism and workout recovery.',
                  style: TextStyle(color: Color(0xE5FFFEFE), fontSize: 14, fontFamily: 'Arial', fontWeight: FontWeight.w400, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({required double height, required Widget child}) {
    return Container(
      height: height,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        shadows: [_buildDefaultBoxShadow()],
      ),
      child: child,
    );
  }

  BoxShadow _buildDefaultBoxShadow() {
    return const BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3);
  }

  Widget _buildGradientIconBox({required List<Color> colors, required IconData icon}) {
    return Container(
      width: 48,
      height: 48,
      decoration: ShapeDecoration(
        gradient: LinearGradient(begin: const Alignment(0.50, 0.00), end: const Alignment(0.50, 1.00), colors: colors),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  Widget _buildProgressInfo(String value, String label) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF0FA4AF), fontSize: 16, fontFamily: 'Arial', fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFAFDDE5), fontSize: 12, fontFamily: 'Arial', fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
