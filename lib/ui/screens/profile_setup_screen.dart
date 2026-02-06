import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_screen.dart';
import '../components/animate_in.dart';
import '../../viewmodels/profile_setup_view_model.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileSetupViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              AnimateIn(child: _buildHeader(context, viewModel)),
              Expanded(
                child: PageView(
                  controller: viewModel.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => viewModel.setCurrentPage(index),
                  children: [
                    _buildStep1(context, viewModel),
                    _buildStep2(context, viewModel),
                    _buildStep3(context, viewModel),
                    _buildStep4(context, viewModel),
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
                      if (viewModel.currentPage > 0) ...[
                        Expanded(
                          child: _buildNavButton(
                            context,
                            'Back',
                            isPrimary: false,
                            onTap: viewModel.previousPage,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: _buildNavButton(
                          context,
                          viewModel.currentPage == 3 ? 'Finish' : 'Continue',
                          isPrimary: true,
                          onTap: () {
                            viewModel.nextPage(() {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const MainScreen()),
                              );
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavButton(BuildContext context, String label, {required bool isPrimary, required VoidCallback onTap}) {
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

  Widget _buildHeader(BuildContext context, ProfileSetupViewModel viewModel) {
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
          Text('Step ${viewModel.currentPage + 1} of 4', style: const TextStyle(color: Color(0xFFAFDDE5))),
          Text('${(viewModel.progressPercentage * 100).toInt()}%', style: const TextStyle(color: Color(0xFFAFDDE5))),
        ]),
        const SizedBox(height: 8),
        _buildProgressBar(viewModel),
      ]),
    );
  }

  Widget _buildProgressBar(ProfileSetupViewModel viewModel) {
    return Container(
      height: 8, clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0xFF024950), borderRadius: BorderRadius.circular(10)),
      child: FractionallySizedBox(
        widthFactor: viewModel.progressPercentage, alignment: Alignment.centerLeft,
        child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0FA4AF), Color(0xFF964734)]))),
      ),
    );
  }

  Widget _buildStep1(BuildContext context, ProfileSetupViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AnimateIn(child: Text('Basic Information', style: TextStyle(color: Color(0xFF003135), fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 24),
        AnimateIn(delay: const Duration(milliseconds: 200), child: _buildTextField(context, label: 'Full Name', controller: viewModel.nameController, hint: 'e.g. John Doe')),
        const SizedBox(height: 16),
        AnimateIn(delay: const Duration(milliseconds: 300), child: _buildTextField(context, label: 'Age', controller: viewModel.ageController, hint: 'Enter your age', keyboardType: TextInputType.number)),
        const SizedBox(height: 16),
        const AnimateIn(delay: Duration(milliseconds: 400), child: Text('Gender', style: TextStyle(color: Color(0xFF024950), fontSize: 16))),
        const SizedBox(height: 8),
        AnimateIn(delay: const Duration(milliseconds: 500), child: Row(children: [
          _buildGenderOption(context, viewModel, 'Male'), const SizedBox(width: 12),
          _buildGenderOption(context, viewModel, 'Female'), const SizedBox(width: 12),
          _buildGenderOption(context, viewModel, 'Other'),
        ])),
      ]),
    );
  }

  Widget _buildStep2(BuildContext context, ProfileSetupViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AnimateIn(child: Text('Body Metrics', style: TextStyle(color: Color(0xFF003135), fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 24),
        AnimateIn(delay: const Duration(milliseconds: 200), child: _buildTextField(context, label: 'Weight (kg)', controller: viewModel.weightController, hint: 'Enter your weight', keyboardType: TextInputType.number)),
        const SizedBox(height: 16),
        AnimateIn(delay: const Duration(milliseconds: 300), child: _buildTextField(context, label: 'Height (cm)', controller: viewModel.heightController, hint: 'Enter your height', keyboardType: TextInputType.number)),
        const SizedBox(height: 24),
        const AnimateIn(delay: Duration(milliseconds: 400), child: Text('Activity Level', style: TextStyle(color: Color(0xFF024950), fontSize: 16))),
        const SizedBox(height: 8),
        ...['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'].asMap().entries.map((e) => 
          AnimateIn(delay: Duration(milliseconds: 500 + e.key * 100), child: Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildActivityOption(context, viewModel, e.value)))
        ).toList(),
      ]),
    );
  }

  Widget _buildStep3(BuildContext context, ProfileSetupViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AnimateIn(child: Text('Health Information', style: TextStyle(color: Color(0xFF003135), fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 24),
        AnimateIn(delay: const Duration(milliseconds: 200), child: _buildFileUploadSection(context, title: 'Medical Report', fileName: viewModel.medicalReportName, onTap: () => viewModel.pickFile(isMedical: true))),
        const SizedBox(height: 16),
        AnimateIn(delay: const Duration(milliseconds: 300), child: _buildFileUploadSection(context, title: 'InBody Report', fileName: viewModel.inBodyReportName, onTap: () => viewModel.pickFile(isMedical: false))),
        const SizedBox(height: 24),
        AnimateIn(delay: const Duration(milliseconds: 400), child: _buildMultiSelectSectionWithOther(
          context,
          title: 'Medical Conditions', 
          options: viewModel.medicalConditionsOptions, 
          selectedValues: viewModel.selectedMedicalConditions,
          otherSelected: viewModel.medicalConditionOtherSelected, 
          otherController: viewModel.otherMedicalConditionController,
          onOptionTap: (opt) => viewModel.toggleMedicalCondition(opt),
          onOtherTap: () => viewModel.setMedicalConditionOtherSelected(!viewModel.medicalConditionOtherSelected),
        )),
      ]),
    );
  }

  Widget _buildStep4(BuildContext context, ProfileSetupViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AnimateIn(child: Text('Goals & Experience', style: TextStyle(color: Color(0xFF003135), fontSize: 20, fontWeight: FontWeight.bold))),
        const SizedBox(height: 24),
        AnimateIn(delay: const Duration(milliseconds: 200), child: _buildMultiSelectSectionWithOther(
          context,
          title: 'Fitness Goals', 
          options: viewModel.fitnessGoalsOptions, 
          selectedValues: viewModel.selectedFitnessGoals,
          otherSelected: viewModel.fitnessGoalOtherSelected, 
          otherController: viewModel.otherFitnessGoalController,
          onOptionTap: (opt) => viewModel.toggleFitnessGoal(opt),
          onOtherTap: () => viewModel.setFitnessGoalOtherSelected(!viewModel.fitnessGoalOtherSelected),
        )),
        const SizedBox(height: 24),
        AnimateIn(delay: const Duration(milliseconds: 300), child: _buildSingleSelectSectionWithOther(
          context,
          title: 'Experience Level', 
          options: viewModel.experienceLevelOptions, 
          selectedValue: viewModel.selectedExperienceLevel,
          otherSelected: viewModel.experienceOtherSelected, 
          otherController: viewModel.otherExperienceController,
          onOptionTap: (opt) => viewModel.setSelectedExperienceLevel(opt),
          onOtherTap: () => viewModel.setExperienceOtherSelected(!viewModel.experienceOtherSelected),
        )),
      ]),
    );
  }

  Widget _buildTextField(BuildContext context, {required String label, required TextEditingController controller, String? hint, TextInputType? keyboardType}) {
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

  Widget _buildGenderOption(BuildContext context, ProfileSetupViewModel viewModel, String gender) {
    bool isSelected = viewModel.selectedGender == gender;
    return Expanded(child: GestureDetector(
      onTap: () => viewModel.setSelectedGender(gender),
      child: Container(
        height: 50, decoration: BoxDecoration(color: isSelected ? const Color(0xFF024950) : Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? const Color(0xFF024950) : const Color(0xFFAFDDE5))),
        alignment: Alignment.center,
        child: Text(gender, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF024950))),
      ),
    ));
  }

  Widget _buildActivityOption(BuildContext context, ProfileSetupViewModel viewModel, String level) {
    bool isSelected = viewModel.selectedActivityLevel == level;
    return GestureDetector(
      onTap: () => viewModel.setSelectedActivityLevel(level),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF024950) : Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: isSelected ? const Color(0xFF024950) : const Color(0xFFAFDDE5))),
        child: Text(level, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF024950))),
      ),
    );
  }

  Widget _buildFileUploadSection(BuildContext context, {required String title, String? fileName, required VoidCallback onTap}) {
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

  Widget _buildMultiSelectSectionWithOther(BuildContext context, {required String title, required List<String> options, required List<String> selectedValues, required bool otherSelected, required TextEditingController otherController, required Function(String) onOptionTap, required Function() onOtherTap}) {
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

  Widget _buildSingleSelectSectionWithOther(BuildContext context, {required String title, required List<String> options, String? selectedValue, required bool otherSelected, required TextEditingController otherController, required Function(String) onOptionTap, required Function() onOtherTap}) {
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

