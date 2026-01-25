import 'package:flutter/material.dart';
import 'main_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form controllers
  final TextEditingController _nameController = TextEditingController(text: 'John Doe');
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  String _selectedGender = 'Male';
  String _selectedGoal = 'Lose weight';
  String _selectedActivityLevel = 'Moderately active';
  List<String> _selectedAllergies = [];
  List<String> _selectedDietaryRestrictions = [];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSetup();
    }
  }

  void _completeSetup() {
    // Save profile data and navigate to home screen
    print('Profile setup completed');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
  }

  double get _progressPercentage {
    return (_currentPage + 1) / 4;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFDDE5),
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.50, 0.00),
                  end: Alignment(0.50, 1.00),
                  colors: [Color(0xFF003135), Color(0xFF024950)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  const Text(
                    'Profile Setup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                  Column(
                    spacing: 8,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Step ${_currentPage + 1} of 4',
                            style: const TextStyle(
                              color: Color(0xFFAFDDE5),
                              fontSize: 14,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                            ),
                          ),
                          Text(
                            '${(_progressPercentage * 100).toInt()}%',
                            style: const TextStyle(
                              color: Color(0xFFAFDDE5),
                              fontSize: 14,
                              fontFamily: 'Arial',
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                            ),
                          ),
                        ],
                      ),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(26843500),
                        child: LinearProgressIndicator(
                          value: _progressPercentage,
                          minHeight: 8,
                          backgroundColor: const Color(0xFF024950),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0FA4AF)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
            // Continue button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    width: 0.80,
                    color: Color(0xFFAFDDE5),
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: _nextPage,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment(0.50, 0.00),
                      end: Alignment(0.50, 1.00),
                      colors: [Color(0xFF024950), Color(0xFF0FA4AF)],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    shadows: const [
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
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        _currentPage == 3 ? 'Complete' : 'Continue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Basic Information
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(
              color: Color(0xFF003135),
              fontSize: 16,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
          _buildTextField(
            label: 'Full Name',
            controller: _nameController,
          ),
          _buildTextField(
            label: 'Age',
            controller: _ageController,
            hint: 'Enter your age',
            keyboardType: TextInputType.number,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              const Text(
                'Gender',
                style: TextStyle(
                  color: Color(0xFF024950),
                  fontSize: 16,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              Row(
                spacing: 12,
                children: [
                  _buildGenderButton('Male'),
                  _buildGenderButton('Female'),
                  _buildGenderButton('Other'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 2: Physical Metrics
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          const Text(
            'Physical Metrics',
            style: TextStyle(
              color: Color(0xFF003135),
              fontSize: 16,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
          _buildTextField(
            label: 'Height (cm)',
            controller: _heightController,
            hint: 'Enter your height',
            keyboardType: TextInputType.number,
          ),
          _buildTextField(
            label: 'Weight (kg)',
            controller: _weightController,
            hint: 'Enter your weight',
            keyboardType: TextInputType.number,
          ),
          _buildDropdownField(
            label: 'Fitness Goal',
            value: _selectedGoal,
            items: ['Lose weight', 'Maintain weight', 'Gain muscle', 'Improve fitness'],
            onChanged: (value) {
              setState(() {
                _selectedGoal = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  // Step 3: Activity & Lifestyle
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          const Text(
            'Activity & Lifestyle',
            style: TextStyle(
              color: Color(0xFF003135),
              fontSize: 16,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
          _buildDropdownField(
            label: 'Activity Level',
            value: _selectedActivityLevel,
            items: ['Sedentary', 'Lightly active', 'Moderately active', 'Very active', 'Extremely active'],
            onChanged: (value) {
              setState(() {
                _selectedActivityLevel = value!;
              });
            },
          ),
          _buildMultiSelectField(
            label: 'Dietary Restrictions',
            options: ['Vegetarian', 'Vegan', 'Keto', 'Paleo', 'Halal', 'Kosher'],
            selectedOptions: _selectedDietaryRestrictions,
            onChanged: (value) {
              setState(() {
                if (_selectedDietaryRestrictions.contains(value)) {
                  _selectedDietaryRestrictions.remove(value);
                } else {
                  _selectedDietaryRestrictions.add(value);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  // Step 4: Health Information
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          const Text(
            'Health Information',
            style: TextStyle(
              color: Color(0xFF003135),
              fontSize: 16,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),
          _buildMultiSelectField(
            label: 'Allergies',
            options: ['Dairy', 'Gluten', 'Nuts', 'Soy', 'Eggs', 'Shellfish'],
            selectedOptions: _selectedAllergies,
            onChanged: (value) {
              setState(() {
                if (_selectedAllergies.contains(value)) {
                  _selectedAllergies.remove(value);
                } else {
                  _selectedAllergies.add(value);
                }
              });
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: const Color(0xFFF0F9FA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFF024950),
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your health information helps us create personalized plans for you.',
                    style: TextStyle(
                      color: Color(0xFF024950),
                      fontSize: 14,
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
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

  // Helper widget: Text field
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF024950),
            fontSize: 16,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Color(0xFF0A0A0A),
            fontSize: 16,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0x7F0A0A0A),
              fontSize: 16,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                width: 1.60,
                color: Color(0xFFAFDDE5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                width: 1.60,
                color: Color(0xFFAFDDE5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                width: 1.60,
                color: Color(0xFF024950),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget: Gender button
  Widget _buildGenderButton(String gender) {
    final bool isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        child: Container(
          height: 51.20,
          decoration: ShapeDecoration(
            color: isSelected ? const Color(0xFF024950) : Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1.60,
                color: isSelected ? const Color(0xFF024950) : const Color(0xFFAFDDE5),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Center(
            child: Text(
              gender,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF024950),
                fontSize: 16,
                fontFamily: 'Arial',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget: Dropdown field
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF024950),
            fontSize: 16,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1.60,
                color: Color(0xFFAFDDE5),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(
                color: Color(0xFF0A0A0A),
                fontSize: 16,
                fontFamily: 'Arial',
                fontWeight: FontWeight.w400,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget: Multi-select field
  Widget _buildMultiSelectField({
    required String label,
    required List<String> options,
    required List<String> selectedOptions,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF024950),
            fontSize: 16,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final bool isSelected = selectedOptions.contains(option);
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: ShapeDecoration(
                  color: isSelected ? const Color(0xFF024950) : Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1.60,
                      color: isSelected ? const Color(0xFF024950) : const Color(0xFFAFDDE5),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF024950),
                    fontSize: 14,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}