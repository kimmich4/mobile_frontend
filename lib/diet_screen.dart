import 'package:flutter/material.dart';
import 'main_screen.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  late int _selectedDayIndex;
  late DateTime _selectedDate;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedDayIndex = _selectedDate.weekday - 1;
  }

  void _onDaySelected(int index) {
    setState(() {
      _selectedDayIndex = index;
      int difference = index - (_selectedDate.weekday - 1);
      _selectedDate = _selectedDate.add(Duration(days: difference));
    });
  }

  String _getFormattedDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    String day = date.day.toString();
    String suffix = 'th';
    if (day.endsWith('1') && day != '11') suffix = 'st';
    else if (day.endsWith('2') && day != '12') suffix = 'nd';
    else if (day.endsWith('3') && day != '13') suffix = 'rd';
    return "${dayNames[date.weekday - 1]}, ${months[date.month - 1]} $day$suffix";
  }

  final Map<int, Map<String, dynamic>> _dietData = {
    0: { 'calories': '1,650', 'protein': '105g', 'carbs': '170g', 'fats': '55g', 'meals': [{'title': 'Breakfast', 'cal': '400 cal', 'items': [{'name': 'Eggs & Toast', 'cal': '350 cal'}, {'name': 'Orange Juice', 'cal': '50 cal'}]}, {'title': 'Lunch', 'cal': '600 cal', 'items': [{'name': 'Turkey Sandwich', 'cal': '450 cal'}, {'name': 'Side Salad', 'cal': '150 cal'}]}, {'title': 'Dinner', 'cal': '650 cal', 'items': [{'name': 'Steak & Veggies', 'cal': '650 cal'}]}]},
    1: { 'calories': '1,710', 'protein': '111g', 'carbs': '180g', 'fats': '58g', 'meals': [{'title': 'Breakfast', 'cal': '420 cal', 'items': [{'name': 'Oatmeal with Berries', 'cal': '350 cal'}, {'name': 'Coffee with Milk', 'cal': '70 cal'}]}, {'title': 'Lunch', 'cal': '650 cal', 'items': [{'name': 'Grilled Chicken Salad', 'cal': '450 cal'}, {'name': 'Apple', 'cal': '80 cal'}, {'name': 'Yogurt', 'cal': '120 cal'}]}, {'title': 'Snacks', 'cal': '200 cal', 'items': [{'name': 'Almonds', 'cal': '150 cal'}, {'name': 'Dark Chocolate', 'cal': '50 cal'}]}, {'title': 'Dinner', 'cal': '440 cal', 'items': [{'name': 'Salmon with Asparagus', 'cal': '440 cal'}]}]},
    2: { 'calories': '1,800', 'protein': '120g', 'carbs': '190g', 'fats': '60g', 'meals': [{'title': 'Breakfast', 'cal': '450 cal', 'items': [{'name': 'Greek Yogurt Bowl', 'cal': '400 cal'}, {'name': 'Honey', 'cal': '50 cal'}]}, {'title': 'Lunch', 'cal': '700 cal', 'items': [{'name': 'Beef Stir Fry', 'cal': '600 cal'}, {'name': 'Brown Rice', 'cal': '100 cal'}]}, {'title': 'Dinner', 'cal': '650 cal', 'items': [{'name': 'Pasta with Shrimp', 'cal': '650 cal'}]}]},
  };

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF024950))), child: child!),
    );
    if (picked != null) setState(() { _selectedDate = picked; _selectedDayIndex = picked.weekday - 1; });
  }

  @override
  Widget build(BuildContext context) {
    final currentData = _dietData[_selectedDayIndex] ?? _dietData[0]!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        key: ValueKey(_selectedDayIndex),
        child: Column(children: [
          _buildHeader(context),
          Transform.translate(offset: const Offset(0, -40), child: _buildDailySummaryCard(currentData)),
          _buildMealsList(currentData),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 64),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF003135), Color(0xFF024950)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => MainScreen.switchTab(0)),
          Column(children: [
            const Text('Diet Plan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(_getFormattedDate(_selectedDate), style: const TextStyle(color: Color(0xFFAFDDE5), fontSize: 14)),
          ]),
          IconButton(icon: const Icon(Icons.calendar_today, color: Colors.white), onPressed: () => _selectDate(context)),
        ]),
        const SizedBox(height: 24),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: List.generate(7, (i) => _buildDayItem(_days[i], i)))),
      ]),
    );
  }

  Widget _buildDayItem(String day, int index) {
    bool isSelected = _selectedDayIndex == index;
    return GestureDetector(
      onTap: () => _onDaySelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF0FA4AF) : Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(day, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFFAFDDE5))),
      ),
    );
  }

  Widget _buildDailySummaryCard(Map<String, dynamic> data) {
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