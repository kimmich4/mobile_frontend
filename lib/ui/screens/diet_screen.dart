import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/diet_view_model.dart';
import '../../viewmodels/main_view_model.dart';


class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DietViewModel>(
      builder: (context, viewModel, child) {
        final currentData = viewModel.currentDietData;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: viewModel.isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF024950)))
            : (viewModel.dietPlan == null)
                ? const Center(
                    child: Text('No diet plan found.', style: TextStyle(fontSize: 16)),
                  )
                : SingleChildScrollView(
                    key: ValueKey(viewModel.selectedDayIndex),
                    child: Column(children: [
                      _buildHeader(context, viewModel),
                      if (currentData.isNotEmpty)
                        Transform.translate(offset: const Offset(0, -40), child: _buildDailySummaryCard(context, currentData, viewModel)),
                      if (currentData.isNotEmpty)
                        _buildMealsList(context, currentData, viewModel)
                      else
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: Text('No data for this day.')),
                        ),
                      const SizedBox(height: 100),
                    ]),
                  ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DietViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 64),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF003135), Color(0xFF024950)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => MainViewModel.switchTabStatic(0)),
          Column(children: [
            const Text('Diet Plan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(viewModel.getFormattedDate(), style: const TextStyle(color: Color(0xFFAFDDE5), fontSize: 14)),
          ]),
          const SizedBox(width: 48),
        ]),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(7, (i) => _buildDayItem(viewModel, viewModel.days[i], i)),
          ),
        ),
      ]),
    );
  }

  Widget _buildDayItem(DietViewModel viewModel, String day, int index) {
    bool isSelected = viewModel.selectedDayIndex == index;
    return GestureDetector(
      onTap: () => viewModel.selectDay(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF0FA4AF) : Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(day, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFFAFDDE5))),
      ),
    );
  }

  Widget _buildDailySummaryCard(BuildContext context, Map<String, dynamic> data, DietViewModel viewModel) {
    final totalMeals = (data['meals'] as List?)?.length ?? 0;
    final completedCount = viewModel.completedMealsCount;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Daily Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('$completedCount/$totalMeals meals completed', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
          ]),
          Text('${data['calories']} cal', style: const TextStyle(color: Color(0xFF0FA4AF), fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 16),
        // Progress bar for meal completion
        Container(
          height: 8, clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: const Color(0x7FAFDDE5), borderRadius: BorderRadius.circular(4)),
          child: FractionallySizedBox(
            widthFactor: totalMeals > 0 ? (completedCount / totalMeals).clamp(0.0, 1.0) : 0.0,
            alignment: Alignment.centerLeft,
            child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0FA4AF), Color(0xFF964734)]))),
          ),
        ),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildMacroCircle('Protein', data['protein'], const Color(0xFF0FA4AF)),
          _buildMacroCircle('Carbs', data['carbs'], const Color(0xFF964734)),
          _buildMacroCircle('Fats', data['fats'], const Color(0xFF0FA4AF)),
        ]),
      ]),
    );
  }

  Widget _buildMacroCircle(String label, String value, Color color) {
    return Column(children: [
      Container(width: 64, height: 64, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [color.withOpacity(0.7), color])), alignment: Alignment.center, child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      const SizedBox(height: 8), Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]);
  }

  Widget _buildMealsList(BuildContext context, Map<String, dynamic> data, DietViewModel viewModel) {
    List<dynamic> meals = data['meals'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(children: List.generate(meals.length, (i) {
        final meal = meals[i];
        final mealIndex = meal['index'] as int;
        final isCompleted = viewModel.isMealCompleted(mealIndex);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16), 
          child: _buildMealSection(
            context,
            viewModel,
            meal['title'],
            meal['cal'],
            mealIndex,
            isCompleted,
            (meal['items'] as List).map((it) => _buildMealItem(it['name'], it['cal'])).toList(),
          ),
        );
      })),
    );
  }

  Widget _buildMealSection(BuildContext context, DietViewModel viewModel, String title, String cal, int mealIndex, bool isCompleted, List<Widget> items) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted 
          ? const Color(0xFFE0F2F1).withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 1.0) 
          : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: isCompleted ? [Colors.green, Colors.green.shade700] : [const Color(0xFF0FA4AF), const Color(0xFF024950)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(isCompleted ? Icons.check : Icons.restaurant, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF024950))),
          ]),
          Text(cal, style: const TextStyle(color: Color(0xFF0FA4AF), fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 12),
        ...items,
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted ? Colors.green : const Color(0xFF964734),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: Icon(isCompleted ? Icons.check_circle : Icons.check_circle_outline, size: 20),
            label: Text(isCompleted ? 'Completed' : 'Mark as Complete'),
            onPressed: () => viewModel.toggleMealCompletion(mealIndex),
          ),
        ),
      ]),
    );
  }

  Widget _buildMealItem(String name, String cal) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(child: Row(children: [const Icon(Icons.circle, size: 8, color: Color(0xFF964734)), const SizedBox(width: 8), Expanded(child: Text(name, overflow: TextOverflow.ellipsis))])),
      Text(cal, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]));
  }
}
