import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/workout_view_model.dart';
import '../../viewmodels/main_view_model.dart';
import '../../data/models/workout_model.dart';
import 'video_screen.dart';

class WorkoutPlanScreen extends StatelessWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF024950)))
            : (viewModel.currentPlan == null || viewModel.currentWorkoutExercises.isEmpty)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No workout plan found.', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => viewModel.generateWorkouts(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF024950),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Generate AI Workout Plan'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(context, viewModel),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              _buildSummaryCard(context, viewModel),
                              const SizedBox(height: 24),
                              _buildWorkoutList(context, viewModel),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, WorkoutViewModel viewModel) {
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
              IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => MainViewModel.switchTabStatic(0)),
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
                Expanded(child: _buildToggleButton(context, viewModel, 'Home Workout', 0)),
                const SizedBox(width: 8),
                Expanded(child: _buildToggleButton(context, viewModel, 'Gym Workout', 1)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCalendarStrip(viewModel),
        ],
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context, WorkoutViewModel viewModel, String label, int index) {
    bool isSelected = viewModel.selectedTab == index;
    return GestureDetector(
      onTap: () => viewModel.setSelectedTab(index),
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

  Widget _buildCalendarStrip(WorkoutViewModel viewModel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: viewModel.calendarDays.map((day) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildCalendarCard(day.dayName, day.isCompleted),
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

  Widget _buildSummaryCard(BuildContext context, WorkoutViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(viewModel.workoutTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(Icons.timer_outlined, '${viewModel.durationMinutes} min'),
              _buildInfoItem(Icons.local_fire_department_outlined, '${viewModel.totalCalories} cal'),
              _buildInfoItem(Icons.fitness_center_outlined, '${viewModel.exerciseCount} x'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(children: [Icon(icon, size: 18, color: const Color(0xFF024950)), const SizedBox(width: 4), Text(label)]);
  }

  Widget _buildWorkoutList(BuildContext context, WorkoutViewModel viewModel) {
    final exercises = viewModel.currentWorkoutExercises;
    return Column(
      children: exercises.map((exercise) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildExerciseCard(context, viewModel, exercise),
      )).toList(),
    );
  }

  Widget _buildExerciseCard(BuildContext context, WorkoutViewModel viewModel, Exercise exercise) {
    bool isDone = viewModel.isExerciseCompleted(exercise.id);
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
            Container(width: 40, height: 40, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF024950)), alignment: Alignment.center, child: Text(exercise.id.toString().substring(exercise.id > 100 ? 2 : 0), style: const TextStyle(color: Colors.white))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(exercise.difficulty)])),
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Sets: ${exercise.sets}'), Text('Reps: ${exercise.reps}'), Text('${exercise.calories} cal'),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VideoScreen())), child: const Text('Tutorial'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: isDone ? Colors.green : const Color(0xFF964734), foregroundColor: Colors.white),
              onPressed: () => viewModel.toggleExerciseCompletion(exercise.id),
              child: Text(isDone ? 'Done' : 'Complete'),
            )),
          ]),
        ],
      ),
    );
  }
}

