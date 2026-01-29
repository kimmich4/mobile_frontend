import 'package:flutter/material.dart';
import 'main_screen.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

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
              child: _buildDailySummaryCard(),
            ),
            _buildMealsList(),
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
                'Diet Plan',
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
                child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Calendar Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayItem('Mon', false),
              _buildDayItem('Tue', true),
              _buildDayItem('Wed', false),
              _buildDayItem('Thu', false),
              _buildDayItem('Fri', false),
              _buildDayItem('Sat', false),
              _buildDayItem('Sun', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(String day, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0FA4AF) : Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        day,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFFAFDDE5),
          fontSize: 14,
          fontFamily: 'Arial',
        ),
      ),
    );
  }

  Widget _buildDailySummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Summary',
                style: TextStyle(
                  color: Color(0xFF003135),
                  fontSize: 16,
                  fontFamily: 'Arial',
                ),
              ),
              const Text(
                '1710 cal',
                style: TextStyle(
                  color: Color(0xFF0FA4AF),
                  fontSize: 16,
                   fontFamily: 'Arial',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroItem('Protein', '111g', const Color(0xFF0FA4AF)),
              _buildMacroItem('Carbs', '180g', const Color(0xFF964734)),
               _buildMacroItem('Fats', '58g', const Color(0xFF0FA4AF)), // Using repeat color for simplicity or check design
               // Actually third one was Gradient: 0FA4AF -> 964734 in design code 
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withOpacity(0.7)], // Simple gradient simulation
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Arial',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
             color: Color(0xFF024950),
             fontSize: 14,
             fontFamily: 'Arial',
          ),
        ),
      ],
    );
  }

  Widget _buildMealsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMealSection('Breakfast', '420 cal', [
            _buildMealItem('Oatmeal with Berries', '350 cal'),
            _buildMealItem('Coffee with Milk', '70 cal'),
          ]),
          const SizedBox(height: 24),
           _buildMealSection('Lunch', '650 cal', [
            _buildMealItem('Grilled Chicken Salad', '450 cal'),
            _buildMealItem('Apple', '80 cal'),
             _buildMealItem('Yogurt', '120 cal'),
          ]),
          const SizedBox(height: 24),
          _buildMealSection('Snacks', '200 cal', [
             _buildMealItem('Almonds', '150 cal'),
             _buildMealItem('Dark Chocolate', '50 cal'),
          ]),
          const SizedBox(height: 24),
           _buildMealSection('Dinner', '440 cal', [
            _buildMealItem('Salmon with Asparagus', '440 cal'),
          ]),
        ],
      ),
    );
  }

  Widget _buildMealSection(String title, String calories, List<Widget> items) {
    return Column(
      children: [
        Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text(
               title,
               style: const TextStyle(
                 color: Color(0xFF024950),
                 fontSize: 18,
                 fontWeight: FontWeight.bold,
                 fontFamily: 'Arial',
               ),
             ),
             Text(
               calories,
               style: const TextStyle(
                 color: Color(0xFF0FA4AF),
                 fontSize: 14,
                 fontFamily: 'Arial',
               ),
             ),
           ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMealItem(String name, String cal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF964734),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: const TextStyle(
                   color: Color(0xFF003135),
                   fontSize: 14,
                   fontFamily: 'Arial',
                ),
              ),
            ],
          ),
          Text(
            cal,
            style: const TextStyle(
              color: Color(0x99024950),
              fontSize: 12,
              fontFamily: 'Arial',
            ),
          ),
        ],
      ),
    );
  }
}