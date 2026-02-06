import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/animate_in.dart';
import '../../viewmodels/edit_profile_view_model.dart';
// Remove local ImagePicker import as it's handled in ViewModel

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfileViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF003135),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const AnimateIn(child: SectionHeader('Basic Information')),
              const SizedBox(height: 24),
              AnimateIn(delay: const Duration(milliseconds: 100), child: _buildTextField(context, viewModel.nameController, 'Full Name', 'John Doe')),
              const SizedBox(height: 16),
              AnimateIn(delay: const Duration(milliseconds: 200), child: _buildTextField(context, viewModel.ageController, 'Age', '28', kb: TextInputType.number)),
              const SizedBox(height: 16),
              AnimateIn(delay: const Duration(milliseconds: 300), child: _genderSelect(context, viewModel)),

              const SizedBox(height: 40),
              const AnimateIn(delay: Duration(milliseconds: 400), child: SectionHeader('Body Metrics')),
              const SizedBox(height: 24),
              AnimateIn(delay: const Duration(milliseconds: 500), child: _buildTextField(context, viewModel.weightController, 'Weight (kg)', '70', kb: TextInputType.number)),
              const SizedBox(height: 16),
              AnimateIn(delay: const Duration(milliseconds: 600), child: _buildTextField(context, viewModel.heightController, 'Height (cm)', '175', kb: TextInputType.number)),
              const SizedBox(height: 16),
              _activitySelectAnimated(context, viewModel, delay: 700),

              const SizedBox(height: 40),
              const AnimateIn(delay: Duration(milliseconds: 1000), child: SectionHeader('Health Information')),
              const SizedBox(height: 24),
              
              // Medical Conditions
              AnimateIn(delay: const Duration(milliseconds: 1050), child: _buildSectionTitle('Medical Conditions')),
              const SizedBox(height: 16),
              AnimateIn(
                delay: const Duration(milliseconds: 1100),
                child: _buildCustomMultiSelect(
                  context,
                  options: viewModel.medicalConditionsOptions,
                  selectedValues: viewModel.selectedMedicalConditions,
                  otherSelected: viewModel.medicalConditionOtherSelected,
                  otherController: viewModel.otherMedicalConditionController,
                  onOptionTap: viewModel.toggleMedicalCondition,
                  onOtherTap: () => viewModel.setMedicalConditionOtherSelected(!viewModel.medicalConditionOtherSelected),
                ),
              ),

              const SizedBox(height: 24),
              
              // Allergies
              AnimateIn(delay: const Duration(milliseconds: 1200), child: _buildSectionTitle('Allergies')),
              const SizedBox(height: 16),
              AnimateIn(
                delay: const Duration(milliseconds: 1250),
                child: _buildCustomMultiSelect(
                  context,
                  options: viewModel.allergiesOptions,
                  selectedValues: viewModel.selectedAllergies,
                  otherSelected: viewModel.allergyOtherSelected,
                  otherController: viewModel.otherAllergyController,
                  onOptionTap: viewModel.toggleAllergy,
                  onOtherTap: () => viewModel.setAllergyOtherSelected(!viewModel.allergyOtherSelected),
                ),
              ),

              const SizedBox(height: 24),
              
              // Injuries
              AnimateIn(delay: const Duration(milliseconds: 1300), child: _buildSectionTitle('Current Injuries')),
              const SizedBox(height: 16),
              AnimateIn(
                delay: const Duration(milliseconds: 1350),
                child: _buildCustomMultiSelect(
                  context,
                  options: viewModel.injuriesOptions,
                  selectedValues: viewModel.selectedInjuries,
                  otherSelected: viewModel.injuryOtherSelected,
                  otherController: viewModel.otherInjuryController,
                  onOptionTap: viewModel.toggleInjury,
                  onOtherTap: () => viewModel.setInjuryOtherSelected(!viewModel.injuryOtherSelected),
                ),
              ),

              const SizedBox(height: 24),
              AnimateIn(delay: const Duration(milliseconds: 1400), child: _uploadTile(context, 'Medical Report', viewModel.medicalReportName, (_) => viewModel.pickFile(true))),
              const SizedBox(height: 16),
              AnimateIn(delay: const Duration(milliseconds: 1450), child: _uploadTile(context, 'InBody Report', viewModel.inBodyReportName, (_) => viewModel.pickFile(false))),
 
              const SizedBox(height: 40),
              AnimateIn(delay: const Duration(milliseconds: 1500), child: _saveBtn(context, viewModel)),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController c, String l, String h, {TextInputType? kb}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l, style: const TextStyle(color: Color(0xFF024950), fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: c, keyboardType: kb,
        decoration: InputDecoration(hintText: h, filled: true, fillColor: Theme.of(context).colorScheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
      ),
    ]);
  }

  Widget _genderSelect(BuildContext context, EditProfileViewModel viewModel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Gender', style: const TextStyle(color: Color(0xFF024950), fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Male', 'Female', 'Other'].map((g) {
            bool isSelected = viewModel.selectedGender == g;
            return GestureDetector(
              onTap: () => viewModel.setSelectedGender(g),
              child: _buildPill(context, g, isSelected),
            );
          }).toList(),
        ),
    ]);
  }

  Widget _activitySelectAnimated(BuildContext context, EditProfileViewModel viewModel, {required int delay}) {
    final activities = ['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Activity Level', style: const TextStyle(color: Color(0xFF024950), fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: activities.map((a) {
          bool isSelected = viewModel.selectedActivityLevel == a;
          return GestureDetector(
            onTap: () => viewModel.setSelectedActivityLevel(a),
            child: _buildPill(context, a, isSelected),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF024950),
        fontSize: 16,
        fontFamily: 'Arial',
        fontWeight: FontWeight.w400,
        height: 1.50,
      ),
    );
  }

  Widget _buildCustomMultiSelect(
    BuildContext context, {
    required List<String> options,
    required List<String> selectedValues,
    required bool otherSelected,
    required TextEditingController otherController,
    required Function(String) onOptionTap,
    required VoidCallback onOtherTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...options.map((opt) {
              bool isSelected = selectedValues.contains(opt);
              return GestureDetector(
                onTap: () => onOptionTap(opt),
                child: _buildPill(context, opt, isSelected),
              );
            }),
            GestureDetector(
              onTap: onOtherTap,
              child: _buildPill(context, 'Other', otherSelected),
            ),
          ],
        ),
        if (otherSelected) ...[
          const SizedBox(height: 12),
          TextField(
            controller: otherController,
            decoration: InputDecoration(
              hintText: 'Please specify...',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPill(BuildContext context, String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: ShapeDecoration(
        color: isSelected ? const Color(0xFF024950) : Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1.60,
            color: isSelected ? const Color(0xFF024950) : const Color(0xFFAFDDE5),
          ),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF024950),
          fontSize: 16,
          fontFamily: 'Arial',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _uploadTile(BuildContext context, String l, String? n, Function(String) onPick) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(n != null ? Icons.check_circle : Icons.cloud_upload, color: const Color(0xFF0FA4AF)),
        title: Text(l, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(n ?? 'Tap to upload'),
        onTap: () => onPick(''),
      ),
    );
  }

  Widget _saveBtn(BuildContext context, EditProfileViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF024950), Color(0xFF0FA4AF)]), borderRadius: BorderRadius.circular(14)),
      child: ElevatedButton(
        onPressed: () => viewModel.saveChanges(() => Navigator.pop(context)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(double.infinity, 56)),
        child: const Text('SAVE CHANGES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface));
  }
}

