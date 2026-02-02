import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'main_screen.dart';
import 'animate_in.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = 'Male';
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _selectedActivityLevel = 'Sedentary';

  final List<String> _medicalConditionsOptions = ['Diabetes', 'Hypertension', 'Heart Disease', 'Asthma', 'None'];
  final List<String> _selectedMedicalConditions = [];
  final TextEditingController _otherMedicalConditionController = TextEditingController();
  bool _medicalConditionOtherSelected = false;

  final List<String> _fitnessGoalsOptions = ['Lose weight', 'Build muscle', 'Improve endurance', 'Flexibility'];
  final List<String> _selectedFitnessGoals = [];
  final TextEditingController _otherFitnessGoalController = TextEditingController();
  bool _fitnessGoalOtherSelected = false;

  final List<String> _experienceLevelOptions = ['Beginner', 'Intermediate', 'Advanced'];
  String? _selectedExperienceLevel;
  final TextEditingController _otherExperienceController = TextEditingController();
  bool _experienceOtherSelected = false;

  String? _medicalReportName;
  String? _inBodyReportName;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _otherMedicalConditionController.dispose();
    _otherFitnessGoalController.dispose();
    _otherExperienceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeSetup();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _completeSetup() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
  }

  double get _progressPercentage => (_currentPage + 1) / 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          AnimateIn(child: _buildHeader()),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
              ],
            ),
          ),
          AnimateIn(
            delay: const Duration(milliseconds: 400),
            slideOffset: 50,
            child: Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  if (_currentPage > 0) ...[
                    Expanded(child: _buildNavButton('Back', isPrimary: false, onTap: _previousPage)),
                    const SizedBox(width: 12),
                  ],
                  Expanded(child: _buildNavButton(_currentPage == 3 ? 'Finish' : 'Continue', isPrimary: true, onTap: _nextPage)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String label, {required bool isPrimary, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isPrimary ? null : Theme.of(context).colorScheme.surface,
          gradient: isPrimary ? const LinearGradient(colors: [Color(0xFF024950), Color(0xFF0FA4AF)]) : null,
          borderRadius: BorderRadius.circular(14),
          border: isPrimary ? null : Border.all(color: const Color(0xFF024950), width: 1.6),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: isPrimary ? Colors.white : const Color(0xFF024950), fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF003135), Color(0xFF024950)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Profile Setup', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Step ${_currentPage + 1} of 4', style: const TextStyle(color: Color(0xFFAFDDE5))),
          Text('${(_progressPercentage * 100).toInt()}%', style: const TextStyle(color: Color(0xFFAFDDE5))),
        ]),
        const SizedBox(height: 8),
        _buildProgressBar(),
      ]),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 8, clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0xFF024950), borderRadius: BorderRadius.circular(10)),
      child: FractionallySizedBox(
        widthFactor: _progressPercentage, alignment: Alignment.centerLeft,
        child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0FA4AF), Color(0xFF964734)]))),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AnimateIn(child: Text('Basic Information', style: TextStyle(color: Color(0xFF003135), fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 24),
        AnimateIn(delay: const Duration(milliseconds: 200), child: _buildTextField(label: 'Full Name', controller: _nameController, hint: 'e.g. John Doe')),
        const SizedBox(height: 16),
        AnimateIn(delay: const Duration(milliseconds: 300), child: _buildTextField(label: 'Age', controller: _ageController, hint: 'Enter your age', keyboardType: TextInputType.number)),
        const SizedBox(height: 16),
        const AnimateIn(delay: Duration(milliseconds: 400), child: Text('Gender', style: TextStyle(color: Color(0xFF024950), fontSize: 16))),
        const SizedBox(height: 8),
        AnimateIn(delay: const Duration(milliseconds: 500), child: Row(children: [
          _buildGenderOption('Male'), const SizedBox(width: 12),
          _buildGenderOption('Female'), const SizedBox(width: 12),
          _buildGenderOption('Other'),
        ])),
      ]),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AnimateIn(child: Text('Body Metrics', style: TextStyle(color: Color(0xFF003135), fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 24),
        AnimateIn(delay: const Duration(milliseconds: 200), child: _buildTextField(label: 'Weight (kg)', controller: _weightController, hint: 'Enter your weight', keyboardType: TextInputType.number)),
        const SizedBox(height: 16),
        AnimateIn(delay: const Duration(milliseconds: 300), child: _buildTextField(label: 'Height (cm)', controller: _heightController, hint: 'Enter your height', keyboardType: TextInputType.number)),
        const SizedBox(height: 24),
        const AnimateIn(delay: Duration(milliseconds: 400), child: Text('Activity Level', style: TextStyle(color: Color(0xFF024950), fontSize: 16))),
        const SizedBox(height: 8),
        ...['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'].asMap().entries.map((e) => 
          AnimateIn(delay: Duration(milliseconds: 500 + e.key * 100), child: Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildActivityOption(e.value)))
        ).toList(),
      ]),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AnimateIn(child: Text('Health Information', style: TextStyle(color: Color(0xFF003135), fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 24),
        AnimateIn(delay: const Duration(milliseconds: 200), child: _buildFileUploadSection(title: 'Medical Report', fileName: _medicalReportName, onTap: () => _pickFile(isMedical: true))),
        const SizedBox(height: 16),
        AnimateIn(delay: const Duration(milliseconds: 300), child: _buildFileUploadSection(title: 'InBody Report', fileName: _inBodyReportName, onTap: () => _pickFile(isMedical: false))),
        const SizedBox(height: 24),
        AnimateIn(delay: const Duration(milliseconds: 400), child: _buildMultiSelectSectionWithOther(
          title: 'Medical Conditions', options: _medicalConditionsOptions, selectedValues: _selectedMedicalConditions,
          otherSelected: _medicalConditionOtherSelected, otherController: _otherMedicalConditionController,
          onOptionTap: (opt) => setState(() => _selectedMedicalConditions.contains(opt) ? _selectedMedicalConditions.remove(opt) : _selectedMedicalConditions.add(opt)),
          onOtherTap: () => setState(() => _medicalConditionOtherSelected = !_medicalConditionOtherSelected),
        )),
      ]),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AnimateIn(child: Text('Goals & Experience', style: TextStyle(color: Color(0xFF003135), fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 24),
        AnimateIn(delay: const Duration(milliseconds: 200), child: _buildMultiSelectSectionWithOther(
          title: 'Fitness Goals', options: _fitnessGoalsOptions, selectedValues: _selectedFitnessGoals,
          otherSelected: _fitnessGoalOtherSelected, otherController: _otherFitnessGoalController,
          onOptionTap: (opt) => setState(() => _selectedFitnessGoals.contains(opt) ? _selectedFitnessGoals.remove(opt) : _selectedFitnessGoals.add(opt)),
          onOtherTap: () => setState(() => _fitnessGoalOtherSelected = !_fitnessGoalOtherSelected),
        )),
        const SizedBox(height: 24),
        AnimateIn(delay: const Duration(milliseconds: 300), child: _buildSingleSelectSectionWithOther(
          title: 'Experience Level', options: _experienceLevelOptions, selectedValue: _selectedExperienceLevel,
          otherSelected: _experienceOtherSelected, otherController: _otherExperienceController,
          onOptionTap: (opt) => setState(() => _selectedExperienceLevel = opt),
          onOtherTap: () => setState(() => _experienceOtherSelected = !_experienceOtherSelected),
        )),
      ]),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, String? hint, TextInputType? keyboardType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0xFF024950), fontSize: 16)),
      const SizedBox(height: 8),
      TextField(
        controller: controller, keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint, filled: true, fillColor: Theme.of(context).colorScheme.surface,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFAFDDE5))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF024950))),
        ),
      ),
    ]);
  }

  Widget _buildGenderOption(String gender) {
    bool isSelected = _selectedGender == gender;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        height: 50, decoration: BoxDecoration(color: isSelected ? const Color(0xFF024950) : Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? const Color(0xFF024950) : const Color(0xFFAFDDE5))),
        alignment: Alignment.center,
        child: Text(gender, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF024950))),
      ),
    ));
  }

  Widget _buildActivityOption(String level) {
    bool isSelected = _selectedActivityLevel == level;
    return GestureDetector(
      onTap: () => setState(() => _selectedActivityLevel = level),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF024950) : Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? const Color(0xFF024950) : const Color(0xFFAFDDE5))),
        child: Text(level, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF024950))),
      ),
    );
  }

  Widget _buildFileUploadSection({required String title, String? fileName, required VoidCallback onTap}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Color(0xFF024950), fontSize: 16)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFAFDDE5))),
          child: Row(children: [
            Icon(fileName != null ? Icons.check_circle : Icons.upload_file, color: const Color(0xFF024950)),
            const SizedBox(width: 12),
            Expanded(child: Text(fileName ?? 'Upload file', overflow: TextOverflow.ellipsis)),
          ]),
        ),
      ),
    ]);
  }

  Future<void> _pickFile({required bool isMedical}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => isMedical ? _medicalReportName = image.name : _inBodyReportName = image.name);
  }

  Widget _buildMultiSelectSectionWithOther({required String title, required List<String> options, required List<String> selectedValues, required bool otherSelected, required TextEditingController otherController, required Function(String) onOptionTap, required Function() onOtherTap}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Color(0xFF024950), fontSize: 16)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        ...options.map((opt) => FilterChip(label: Text(opt), selected: selectedValues.contains(opt), onSelected: (_) => onOptionTap(opt))),
        ActionChip(label: const Text('Other'), onPressed: onOtherTap, backgroundColor: otherSelected ? const Color(0xFF024950) : null, labelStyle: TextStyle(color: otherSelected ? Colors.white : null)),
      ]),
      if (otherSelected) ...[
        const SizedBox(height: 12),
        TextField(
          controller: otherController,
          decoration: InputDecoration(
            hintText: 'Please specify...',
            filled: true, fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    ]);
  }

  Widget _buildSingleSelectSectionWithOther({required String title, required List<String> options, String? selectedValue, required bool otherSelected, required TextEditingController otherController, required Function(String) onOptionTap, required Function() onOtherTap}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Color(0xFF024950), fontSize: 16)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        ...options.map((opt) => ChoiceChip(label: Text(opt), selected: selectedValue == opt, onSelected: (_) => onOptionTap(opt))),
        ActionChip(label: const Text('Other'), onPressed: onOtherTap, backgroundColor: otherSelected ? const Color(0xFF024950) : null, labelStyle: TextStyle(color: otherSelected ? Colors.white : null)),
      ]),
      if (otherSelected) ...[
        const SizedBox(height: 12),
        TextField(
          controller: otherController,
          decoration: InputDecoration(
            hintText: 'Please specify...',
            filled: true, fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    ]);
  }
}