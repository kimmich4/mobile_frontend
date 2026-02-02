import 'package:flutter/material.dart';
import 'video_screen.dart';
import 'main_screen.dart';
import 'animate_in.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  int _selectedTab = 0; // 0: Home, 1: Gym
  final Set<int> _completedExercises = {};

  void _onTabChanged(int index) {
    if (_selectedTab != index) {
      setState(() {
        _selectedTab = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        key: ValueKey(_selectedTab),
        child: Column(
          children: [
            AnimateIn(child: _buildHeader(context)),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  AnimateIn(delay: const Duration(milliseconds: 200), child: _buildSummaryCard()),
                  const SizedBox(height: 24),
                  _selectedTab == 0 ? _buildHomeWorkoutList() : _buildGymWorkoutList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
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
        gradient: LinearGradient(colors: [Color(0xFF003135), Color(0xFF024950)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => MainScreen.switchTab(0)),
              const Text('Workout Plan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.more_horiz, color: Colors.white), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Expanded(child: _buildToggleButton('Home Workout', 0)),
                const SizedBox(width: 8),
                Expanded(child: _buildToggleButton('Gym Workout', 1)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCalendarStrip(),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => _onTabChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0FA4AF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFFAFDDE5))),
      ),
    );
  }

  Widget _buildCalendarStrip() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map((day) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildCalendarCard(day, day == 'Mon' || day == 'Tue'),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarCard(String day, bool isCompleted) {
    return Container(
      width: 85, height: 68,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFF0FA4AF) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day, style: TextStyle(color: isCompleted ? Colors.white : const Color(0xFFAFDDE5), fontSize: 12)),
          const Spacer(),
          if (isCompleted) const Icon(Icons.check, color: Colors.white, size: 14),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upper Body Strength', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(Icons.timer_outlined, '45 min'),
              _buildInfoItem(Icons.local_fire_department_outlined, '380 cal'),
              _buildInfoItem(Icons.fitness_center_outlined, '6 x'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(children: [Icon(icon, size: 18, color: const Color(0xFF024950)), const SizedBox(width: 4), Text(label)]);
  }

  Widget _buildHomeWorkoutList() {
    return Column(children: [
      AnimateIn(delay: const Duration(milliseconds: 300), child: _buildExerciseCard(id: 1, name: 'Push-ups', difficulty: 'Medium', equipment: 'Bodyweight', sets: '3', reps: '15', cal: '60')),
      const SizedBox(height: 16),
      AnimateIn(delay: const Duration(milliseconds: 400), child: _buildExerciseCard(id: 2, name: 'Plank', difficulty: 'Easy', equipment: 'None', sets: '3', reps: '60s', cal: '40')),
    ]);
  }

  Widget _buildGymWorkoutList() {
    return Column(children: [
      AnimateIn(delay: const Duration(milliseconds: 300), child: _buildExerciseCard(id: 101, name: 'Bench Press', difficulty: 'Hard', equipment: 'Barbell', sets: '4', reps: '8', cal: '120')),
      const SizedBox(height: 16),
      AnimateIn(delay: const Duration(milliseconds: 400), child: _buildExerciseCard(id: 102, name: 'Deadlift', difficulty: 'Hard', equipment: 'Barbell', sets: '3', reps: '5', cal: '150')),
    ]);
  }

  Widget _buildExerciseCard({required int id, required String name, required String difficulty, required String equipment, required String sets, required String reps, required String cal}) {
    bool isDone = _completedExercises.contains(id);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFE0F2F1).withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 1.0) : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(children: [
            Container(width: 40, height: 40, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF024950)), alignment: Alignment.center, child: Text(id.toString().substring(id > 100 ? 2 : 0), style: const TextStyle(color: Colors.white))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(difficulty)])),
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Sets: $sets'), Text('Reps: $reps'), Text('$cal cal'),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VideoScreen())), child: const Text('Tutorial'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: isDone ? Colors.green : const Color(0xFF964734), foregroundColor: Colors.white),
              onPressed: () => setState(() => isDone ? _completedExercises.remove(id) : _completedExercises.add(id)),
              child: Text(isDone ? 'Done' : 'Complete'),
            )),
          ]),
        ],
      ),
    );
  }
}