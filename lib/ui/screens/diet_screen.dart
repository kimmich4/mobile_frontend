import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/diet_view_model.dart';
import '../../viewmodels/main_view_model.dart';


class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  Future<void> _selectDate(BuildContext context, DietViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF024950)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      viewModel.setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DietViewModel>(
      builder: (context, viewModel, child) {
        final currentData = viewModel.currentDietData;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: viewModel.isLoading 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF024950)))
            : (viewModel.currentDietPlan == null)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No diet plan found for this date.', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => viewModel.generateDietPlan(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF024950),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Generate AI Diet Plan'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    // Key helps with rebuilding if date changes significantly, though Consumer handles data updates.
                    key: ValueKey(viewModel.selectedDayIndex),
                    child: Column(children: [
                      _buildHeader(context, viewModel),
                      Transform.translate(offset: const Offset(0, -40), child: _buildDailySummaryCard(context, currentData)),
                      _buildMealsList(currentData),
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
          IconButton(icon: const Icon(Icons.calendar_today, color: Colors.white), onPressed: () => _selectDate(context, viewModel)),
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

  Widget _buildDailySummaryCard(BuildContext context, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Daily Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('${data['calories']} cal', style: const TextStyle(color: Color(0xFF0FA4AF), fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 24),
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

  Widget _buildMealsList(Map<String, dynamic> data) {
    List<dynamic> meals = data['meals'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(children: List.generate(meals.length, (i) => 
        Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildMealSection(meals[i]['title'], meals[i]['cal'], (meals[i]['items'] as List).map((it) => _buildMealItem(it['name'], it['cal'])).toList()))
      )),
    );
  }

  Widget _buildMealSection(String title, String cal, List<Widget> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF024950))),
        Text(cal, style: const TextStyle(color: Color(0xFF0FA4AF))),
      ]),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(16)), child: Column(children: items)),
    ]);
  }

  Widget _buildMealItem(String name, String cal) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(children: [const Icon(Icons.circle, size: 8, color: Color(0xFF964734)), const SizedBox(width: 8), Text(name)]),
      Text(cal, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]));
  }
}

