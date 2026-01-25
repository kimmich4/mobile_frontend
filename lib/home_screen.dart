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
            _buildDietPlanSection(),
             // Add more sections here as found in original code if any
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
          // User Header
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
                  color: Colors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                     // Navigate to notifications or show dialog
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No new notifications")));
                  },
                  child: const Text(
                    '🔔',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats Row
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
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {},
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFAFDDE5),
              fontSize: 14,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Arial',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF0FA4AF),
              fontSize: 12,
              fontFamily: 'Arial',
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDietPlanSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
             BoxShadow(
              color: Color(0x19000000),
              blurRadius: 6,
              offset: Offset(0, 4),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 15,
              offset: Offset(0, 10),
              spreadRadius: -3,
            )
          ],
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
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                           colors: [Color(0xFF0FA4AF), Color(0xFF024950)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      // Placeholder for icon
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Today's Diet Plan",
                          style: TextStyle(
                            color: Color(0xFF003135),
                            fontSize: 16,
                            fontFamily: 'Arial',
                          ),
                        ),
                        Text(
                          '4 meals remaining',
                          style: TextStyle(
                            color: Color(0x99024950),
                            fontSize: 14,
                            fontFamily: 'Arial',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      '1,847',
                      style: TextStyle(
                        color: Color(0xFF0FA4AF),
                        fontSize: 16,
                        fontFamily: 'Arial',
                      ),
                    ),
                    Text(
                      'cal consumed',
                      style: TextStyle(
                        color: Color(0x99024950),
                        fontSize: 12,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.7, // Example value
                backgroundColor: const Color(0x7FAFDDE5),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0FA4AF)), 
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
            // Footer info or button if any
          ],
        ),
      ),
    );
  }
}