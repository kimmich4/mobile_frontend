import 'package:flutter/material.dart';
import 'video_screen.dart';
import 'main_screen.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  int _selectedTab = 0; // 0: Home, 1: Gym
  final Set<int> _completedExercises = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFDDE5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildContent(context),
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
                  ),
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
                  color: Colors.white.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
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
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Calendar Strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCalendarCard('Monday', true),
                const SizedBox(width: 8),
                _buildCalendarCard('Tuesday', true),
                const SizedBox(width: 8),
                _buildCalendarCard('Wednesday', false),
                const SizedBox(width: 8),
                _buildCalendarCard('Thursday', false),
                const SizedBox(width: 8),
                _buildCalendarCard('Friday', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(String day, bool isCompleted) {
    return Container(
      width: 85,
      height: 68,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFF0FA4AF) : Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: TextStyle(
              color: isCompleted ? Colors.white : const Color(0xFFAFDDE5),
              fontSize: 14,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          if (isCompleted)
            const Text(
              '✓',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Arial',
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: _selectedTab == 0 ? _buildHomeWorkoutContent(context) : _buildGymWorkoutContent(context),
    );
  }

  Widget _buildHomeWorkoutContent(BuildContext context) {
    return Column(
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 24),
        _buildExerciseList(context),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSummaryCard() {
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upper Body Strength',
            style: TextStyle(
              color: Color(0xFF003135),
              fontSize: 16,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(Icons.timer_outlined, '45 min'),
              _buildInfoItem(Icons.local_fire_department_outlined, '~380 cal'),
              _buildInfoItem(Icons.fitness_center_outlined, '6 exercises'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF024950)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF024950),
            fontSize: 14,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseList(BuildContext context) {
    return Column(
      children: [
        _buildExerciseCard(
          id: 1,
          context: context,
          name: 'Push-ups',
          difficulty: 'Medium',
          equipment: 'Bodyweight',
          sets: '3',
          reps: '12-15',
          cal: '60',
        ),
        const SizedBox(height: 24),
        _buildExerciseCard(
          id: 2,
          context: context,
          name: 'Dumbbell Rows',
          difficulty: 'Medium',
          equipment: 'Dumbbells',
          sets: '3',
          reps: '10-12',
          cal: '80',
        ),
        const SizedBox(height: 24),
        _buildExerciseCard(
          id: 3,
          context: context,
          name: 'Shoulder Press',
          difficulty: 'Medium',
          equipment: 'Dumbbells',
          sets: '3',
          reps: '10-12',
          cal: '75',
        ),
      ],
    );
  }

  Widget _buildExerciseCard({
    required int id,
    required BuildContext context,
    required String name,
    required String difficulty,
    required String equipment,
    required String sets,
    required String reps,
    required String cal,
  }) {
    bool isDone = _completedExercises.contains(id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 10),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.50, 0.00),
                    end: Alignment(0.50, 1.00),
                    colors: [Color(0xFF964734), Color(0xFF024950)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  id.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Arial'),
                ),
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
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildBadge(difficulty, const Color(0x19964734), const Color(0xFF964734)),
                        const SizedBox(width: 8),
                        _buildBadge(equipment, const Color(0x4CAFDDE5), const Color(0xFF024950)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildExerciseStat('Sets', sets, const Color(0x190FA4AF)),
              _buildExerciseStat('Reps', reps, const Color(0x19964734)),
              _buildExerciseStat('Cal', cal, const Color(0x190FA4AF)),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            label: 'Watch Tutorial',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VideoScreen())),
            gradient: const [Color(0xFF024950), Color(0xFF0FA4AF)],
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            label: isDone ? 'Completed ✓' : 'Mark as Done',
            onTap: () => setState(() {
              if (isDone) {
                _completedExercises.remove(id);
              } else {
                _completedExercises.add(id);
              }
            }),
            color: isDone ? const Color(0xFF0FA4AF).withOpacity(0.1) : const Color(0xFF964734).withOpacity(0.1),
            textColor: isDone ? const Color(0xFF0FA4AF) : const Color(0xFF964734),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(26843500),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 12, fontFamily: 'Arial'),
      ),
    );
  }

  Widget _buildExerciseStat(String label, String value, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(color: Color(0xFF024950), fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Color(0x99024950), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildGymWorkoutContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGymSummaryRow(),
        const SizedBox(height: 24),
        _buildGymProgressBar(),
        const SizedBox(height: 24),
        _buildGymExerciseList(context),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildGymSummaryRow() {
    return Row(
      children: [
        Expanded(child: _buildGymInfoCard('Duration', '80 min', Icons.timer_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _buildGymInfoCard('Calories', '770 kcal', Icons.local_fire_department_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _buildGymInfoCard('Progress', '0/8', Icons.analytics_outlined)),
      ],
    );
  }

  Widget _buildGymInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF024950),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFFAFDDE5)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Color(0xFFAFDDE5), fontSize: 12, fontFamily: 'Arial'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Arial', fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildGymProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Workout Progress',
              style: TextStyle(color: Color(0xFF024950), fontSize: 14, fontFamily: 'Arial'),
            ),
            Text(
              '0%',
              style: TextStyle(color: Color(0xFF024950), fontSize: 14, fontFamily: 'Arial'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF024950).withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: 0.1, // Placeholder for 0%
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0FA4AF), Color(0xFF964734)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGymExerciseList(BuildContext context) {
    return Column(
      children: [
        _buildGymExerciseCard(
          id: 1,
          context: context,
          name: 'Barbell Bench Press',
          equipment: 'Barbell + Bench',
          difficulty: 'Hard',
          sets: '4 × 8-10',
          time: '12 min',
          cal: '120 cal',
          difficultyColor: const Color(0xFFE7000A),
          difficultyBg: const Color(0xFFFFE2E2),
        ),
        const SizedBox(height: 16),
        _buildGymExerciseCard(
          id: 2,
          context: context,
          name: 'Lat Pulldown',
          equipment: 'Cable Machine',
          difficulty: 'Medium',
          sets: '3 × 10-12',
          time: '10 min',
          cal: '90 cal',
          difficultyColor: const Color(0xFFD08700),
          difficultyBg: const Color(0xFFFEF9C2),
        ),
        const SizedBox(height: 16),
        _buildGymExerciseCard(
          id: 3,
          context: context,
          name: 'Leg Press',
          equipment: 'Leg Press Machine',
          difficulty: 'Hard',
          sets: '4 × 12-15',
          time: '12 min',
          cal: '140 cal',
          difficultyColor: const Color(0xFFE7000A),
          difficultyBg: const Color(0xFFFFE2E2),
        ),
      ],
    );
  }

  Widget _buildGymExerciseCard({
    required int id,
    required BuildContext context,
    required String name,
    required String equipment,
    required String difficulty,
    required String sets,
    required String time,
    required String cal,
    required Color difficultyColor,
    required Color difficultyBg,
  }) {
    bool isDone = _completedExercises.contains(id + 100); // Unique offset for gym

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFAFDDE5), width: 1.6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() {
              if (isDone) {
                _completedExercises.remove(id + 100);
              } else {
                _completedExercises.add(id + 100);
              }
            }),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFAFDDE5), width: 1.6),
                color: isDone ? const Color(0xFF0FA4AF) : Colors.transparent,
              ),
              child: isDone ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Color(0xFF003135),
                              fontSize: 16,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            equipment,
                            style: const TextStyle(
                              color: Color(0x99024950),
                              fontSize: 14,
                              fontFamily: 'Arial',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: difficultyBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        difficulty,
                        style: TextStyle(color: difficultyColor, fontSize: 12, fontFamily: 'Arial'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildGymStatItem(Icons.repeat, sets),
                    const SizedBox(width: 16),
                    _buildGymStatItem(Icons.access_time, time),
                    const SizedBox(width: 16),
                    _buildGymStatItem(Icons.local_fire_department, cal, textColor: const Color(0xFF964734)),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VideoScreen())),
                  child: const Row(
                    children: [
                      Icon(Icons.play_circle_outline, size: 16, color: Color(0xFF0FA4AF)),
                      SizedBox(width: 8),
                      Text(
                        'Watch Tutorial',
                        style: TextStyle(color: Color(0xFF0FA4AF), fontSize: 14, fontFamily: 'Arial'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGymStatItem(IconData icon, String value, {Color? textColor}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF024950).withOpacity(0.6)),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: textColor ?? const Color(0xFF024950),
            fontSize: 14,
            fontFamily: 'Arial',
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    List<Color>? gradient,
    Color? color,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: gradient != null ? LinearGradient(colors: gradient) : null,
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 16,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}