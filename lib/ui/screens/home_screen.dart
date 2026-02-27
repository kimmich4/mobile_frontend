import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_view_model.dart';
import '../../viewmodels/main_view_model.dart';
import '../components/animate_in.dart';
import '../widgets/profile_avatar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                AnimateIn(child: _buildTopSection(context, viewModel)),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      AnimateIn(
                        delay: const Duration(milliseconds: 200),
                        child: _buildDietPlanSection(context, viewModel),
                      ),
                      const SizedBox(height: 16),
                      AnimateIn(
                        delay: const Duration(milliseconds: 300),
                        child: _buildWorkoutSection(context, viewModel),
                      ),
                      const SizedBox(height: 16),
                      AnimateIn(
                        delay: const Duration(milliseconds: 400),
                        child: _buildProgressSummarySection(context, viewModel),
                      ),
                      const SizedBox(height: 16),
                      AnimateIn(
                        delay: const Duration(milliseconds: 500),
                        child: _buildAiAssistantSection(context),
                      ),
                      const SizedBox(height: 16),
                      AnimateIn(
                        delay: const Duration(milliseconds: 600),
                        child: _buildDailyTipSection(viewModel),
                      ),
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

  Widget _buildTopSection(BuildContext context, HomeViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF003135), Color(0xFF024950)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          InkWell(
            onTap: () => MainViewModel.switchTabStatic(3),
            child: Row(children: [
              Hero(
                tag: 'profile_pic',
                child: ProfileAvatar(
                  profilePicturePath: viewModel.profilePicturePath,
                  profileInitial: viewModel.profileInitial,
                  size: 48,
                ),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(viewModel.getGreeting(), style: const TextStyle(color: Color(0xFFAFDDE5), fontSize: 14)),
                Text(viewModel.fullName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
            ]),
          ),
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No new notifications")))),
        ]),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(
            child: _buildStatCard(
              title: 'Meals',
              value: viewModel.mealsDoneDisplay,
              subtitle: 'completed',
              isDone: viewModel.allMealsDone,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Workouts',
              value: '${viewModel.workoutsCompleted}/${viewModel.workoutsGoal}',
              subtitle: 'today',
              isDone: viewModel.allWorkoutsDone,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard(title: 'Streak', value: '${viewModel.currentStreak}', subtitle: 'days')),
        ]),
      ]),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    bool isDone = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDone
            ? Colors.green.withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: isDone ? Border.all(color: Colors.green.withOpacity(0.5)) : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
              color: isDone ? Colors.white : const Color(0xFFAFDDE5),
              fontSize: 12,
            )),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        Text(subtitle,
            style: TextStyle(
              color: isDone ? Colors.white.withOpacity(0.8) : const Color(0xFF0FA4AF),
              fontSize: 10,
            )),
      ]),
    );
  }

  Widget _buildDietPlanSection(BuildContext context, HomeViewModel viewModel) {
    return _buildDashboardCard(
      context,
      onTap: () => MainViewModel.switchTabStatic(2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              _buildGradientIconBox(colors: [const Color(0xFF0FA4AF), const Color(0xFF024950)], icon: Icons.restaurant_menu),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Today's Diet Plan", style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${viewModel.mealsRemaining} meals remaining', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
              ]),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                viewModel.mealsDoneDisplay,
                style: TextStyle(
                  color: viewModel.allMealsDone
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'meals done',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ]),
          ]),
          const SizedBox(height: 16),
          _buildProgressBar(viewModel.dietProgress),
        ]),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 8, clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0x7FAFDDE5), borderRadius: BorderRadius.circular(4)),
      child: FractionallySizedBox(
        widthFactor: progress, alignment: Alignment.centerLeft,
        child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0FA4AF), Color(0xFF964734)]))),
      ),
    );
  }

  Widget _buildWorkoutSection(BuildContext context, HomeViewModel viewModel) {
    return Column(
      children: [
        _buildWorkoutCard(
          context,
          title: viewModel.homeWorkoutTitle,
          description: viewModel.homeWorkoutDescription,
          isDone: viewModel.isHomeWorkoutDone,
          icon: Icons.home,
          colors: [const Color(0xFF964734), const Color(0xFF024950)],
          onTap: () {
            // Force select Home tab (0) and then navigate
            // Assuming we might need a way to set the tab in WorkoutViewModel
            MainViewModel.switchTabStatic(1);
          },
        ),
        const SizedBox(height: 16),
        _buildWorkoutCard(
          context,
          title: viewModel.gymWorkoutTitle,
          description: viewModel.gymWorkoutDescription,
          isDone: viewModel.isGymWorkoutDone,
          icon: Icons.fitness_center,
          colors: [const Color(0xFF0FA4AF), const Color(0xFF024950)],
          onTap: () {
            // Force select Gym tab (1) and then navigate
            MainViewModel.switchTabStatic(1);
          },
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(
    BuildContext context, {
    required String title,
    required String description,
    required bool isDone,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return _buildDashboardCard(
      context,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildGradientIconBox(colors: colors, icon: icon),
                  const SizedBox(width: 12),
                  Expanded(
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
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          description,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDone
                    ? Colors.green.withOpacity(0.2)
                    : const Color(0x330FA4AF),
                borderRadius: BorderRadius.circular(20),
                border: isDone ? Border.all(color: Colors.green.withOpacity(0.5)) : null,
              ),
              child: Text(
                isDone ? 'Completed' : 'Start',
                style: TextStyle(
                  color: isDone ? Colors.green : const Color(0xFF0FA4AF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummarySection(BuildContext context, HomeViewModel viewModel) {
    return GestureDetector(
      onTap: () => MainViewModel.switchTabStatic(4),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF024950), Color(0xFF003135)]), borderRadius: BorderRadius.circular(24)),
        child: Column(children: [
          Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.bar_chart, color: Colors.white)),
            const SizedBox(width: 12),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Progress Summary', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text("This week's overview", style: TextStyle(color: Color(0xFFAFDDE5), fontSize: 14)),
            ]),
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildProgressInfo(viewModel.weightChange, 'Weight'),
            _buildProgressInfo(viewModel.dietPlanCompletion, 'Diet Plan'),
            _buildProgressInfo(viewModel.workoutCompletion, 'Workout'),
          ]),
        ]),
      ),
    );
  }

  Widget _buildAiAssistantSection(BuildContext context) {
    return _buildDashboardCard(
      context,
      onTap: () => MainViewModel.switchTabStatic(5),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          _buildGradientIconBox(colors: [const Color(0xFF0FA4AF), const Color(0xFF964734)], icon: Icons.smart_toy),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Assistant', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Ask me anything...', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
          ]),
          const Icon(Icons.chevron_right, color: Color(0xFF024950)),
        ]),
      ),
    );
  }

  Widget _buildDailyTipSection(HomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF964734), Color(0xCC964734)]), borderRadius: BorderRadius.circular(24)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('💡', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Daily Tip', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(viewModel.dailyTip, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
        ])),
      ]),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required Widget child, VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 10))]),
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: child),
    );
  }

  Widget _buildGradientIconBox({required List<Color> colors, required IconData icon}) {
    return Container(width: 48, height: 48, decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: Colors.white));
  }

  Widget _buildProgressInfo(String value, String label) {
    return Column(children: [
      Text(value, style: const TextStyle(color: Color(0xFF0FA4AF), fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Color(0xFFAFDDE5), fontSize: 12)),
    ]);
  }
}

