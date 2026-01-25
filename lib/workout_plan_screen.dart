import 'package:flutter/material.dart';
import 'video_screen.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  int _selectedTab = 0; // 0: Home, 1: Gym

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFDDE5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Transform.translate(
              offset: const Offset(0, -40),
              child: _buildCalendarStrip(),
            ),
            _buildWorkoutList(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 64),
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
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              const Text(
                'Workout Plan',
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
                child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? const Color(0xFF0FA4AF) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Home Workout',
                        style: TextStyle(
                          color: _selectedTab == 0 ? Colors.white : const Color(0xFFAFDDE5),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? const Color(0xFF0FA4AF) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Gym Workout',
                        style: TextStyle(
                          color: _selectedTab == 1 ? Colors.white : const Color(0xFFAFDDE5),
                           fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildCalendarCard('Monday', true),
          const SizedBox(width: 12),
          _buildCalendarCard('Tuesday', true),
          const SizedBox(width: 12),
          _buildCalendarCard('Wednesday', false),
           const SizedBox(width: 12),
          _buildCalendarCard('Thursday', false),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(String day, bool isCompleted) {
    return Container(
      width: 80,
      height: 70,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFF0FA4AF) : Colors.white.withValues(alpha: 0.8), // Adjusted for contrast
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: TextStyle(
              color: isCompleted ? Colors.white : const Color(0xFF003135),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          if (isCompleted)
            const Text(
              '✓',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkoutList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildWorkoutCard(),
          const SizedBox(height: 24),
          _buildExercisesList(context),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 25,
            offset: Offset(0, 20),
            spreadRadius: -5,
          )
        ],
      ),
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upper Body Strength',
            style: TextStyle(
              color: Color(0xFF003135),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoBadge(Icons.timer_outlined, '45 min'),
              const SizedBox(width: 16),
              _buildInfoBadge(Icons.local_fire_department_outlined, '~380 cal'),
              const SizedBox(width: 16),
              _buildInfoBadge(Icons.fitness_center_outlined, '6 exercises'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label) {
    return Row(
      children: [
         Icon(icon, size: 18, color: const Color(0xFF0FA4AF)),
         const SizedBox(width: 6),
         Text(
           label,
           style: const TextStyle(
             color: Color(0xFF024950),
             fontSize: 14,
           ),
         ),
      ],
    );
  }

  Widget _buildExercisesList(BuildContext context) {
    // Determine content based on tab
    if (_selectedTab == 0) {
      // Home Workout
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
         child: Column(
           children: [
             _buildExerciseItem(context, 'Push-ups', '3 sets x 12 reps', 'Medium'),
             const Divider(),
             _buildExerciseItem(context, 'Squats', '3 sets x 15 reps', 'Easy'),
             const Divider(),
             _buildExerciseItem(context, 'Plank', '3 sets x 45 sec', 'Hard'),
           ],
         ),
      );
    } else {
      // Gym Workout Content (Placeholder for now as handled by logic)
       return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
         child: const Center(child: Text("Gym Exercises List")),
      );
    }
  }

  Widget _buildExerciseItem(BuildContext context, String name, String reps, String difficulty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VideoScreen()),
          );
        },
        child: Row(
          children: [
            Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0x190FA4AF),
              borderRadius: BorderRadius.circular(12),
            ),
            // load icon/image
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF003135),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  reps,
                  style: const TextStyle(
                    color: Color(0x99024950),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: difficulty == 'Hard' ? const Color(0x19964734) : const Color(0x190FA4AF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              difficulty,
              style: TextStyle(
                color: difficulty == 'Hard' ? const Color(0xFF964734) : const Color(0xFF0FA4AF),
                fontSize: 12,
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}