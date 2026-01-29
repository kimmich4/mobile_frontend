import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Variables exactly as in ProfileSetupScreen
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = 'Male';
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _selectedActivityLevel = 'Sedentary (little to no exercise)';

  final List<String> _medicalConditionsOptions = ['Diabetes', 'Hypertension', 'Heart Disease', 'Asthma', 'None'];
  final List<String> _selectedMedicalConditions = [];
  final TextEditingController _otherMedicalConditionController = TextEditingController();
  bool _medicalConditionOtherSelected = false;

  final List<String> _allergiesOptions = ['Peanuts', 'Dairy', 'Gluten', 'Shellfish', 'Soy', 'Eggs', 'None'];
  final List<String> _selectedAllergies = [];
  final TextEditingController _otherAllergyController = TextEditingController();
  bool _allergyOtherSelected = false;

  final List<String> _injuriesOptions = ['Knee', 'Back', 'Shoulder', 'Ankle', 'None'];
  final List<String> _selectedInjuries = [];
  final TextEditingController _otherInjuryController = TextEditingController();
  bool _injuryOtherSelected = false;

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
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _otherMedicalConditionController.dispose();
    _otherAllergyController.dispose();
    _otherInjuryController.dispose();
    _otherFitnessGoalController.dispose();
    _otherExperienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFDDE5),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF003135),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          _sectionHeader('Basic Information'),
          _spacing(),
          _input(_nameController, 'Full Name', 'John Doe'),
          _spacing(),
          _input(_ageController, 'Age', '28', kb: TextInputType.number),
          _spacing(),
          _genderSelect(),

          _bigSpacing(),
          _sectionHeader('Body Metrics'),
          _spacing(),
          _input(_weightController, 'Weight (kg)', '70', kb: TextInputType.number),
          _spacing(),
          _input(_heightController, 'Height (cm)', '175', kb: TextInputType.number),
          _spacing(),
          _activitySelect(),

          _bigSpacing(),
          _sectionHeader('Health Information'),
          _spacing(),
          _multi('Medical Conditions', _medicalConditionsOptions, _selectedMedicalConditions, _medicalConditionOtherSelected, _otherMedicalConditionController, (v) => _toggle(v, _selectedMedicalConditions), () => setState(() { _medicalConditionOtherSelected = !_medicalConditionOtherSelected; if (_medicalConditionOtherSelected) _selectedMedicalConditions.remove('None'); })),
          _spacing(),
          _multi('Allergies', _allergiesOptions, _selectedAllergies, _allergyOtherSelected, _otherAllergyController, (v) => _toggle(v, _selectedAllergies), () => setState(() { _allergyOtherSelected = !_allergyOtherSelected; if (_allergyOtherSelected) _selectedAllergies.remove('None'); })),
          _spacing(),
          _multi('Current Injuries', _injuriesOptions, _selectedInjuries, _injuryOtherSelected, _otherInjuryController, (v) => _toggle(v, _selectedInjuries), () => setState(() { _injuryOtherSelected = !_injuryOtherSelected; if (_injuryOtherSelected) _selectedInjuries.remove('None'); })),
          _spacing(),
          _upload('Medical Report', _medicalReportName, (v) => setState(() => _medicalReportName = v)),
          _spacing(),
          _upload('InBody Report', _inBodyReportName, (v) => setState(() => _inBodyReportName = v)),

          _bigSpacing(),
          _sectionHeader('Goals & Experience'),
          _spacing(),
          _multi('Fitness Goals', _fitnessGoalsOptions, _selectedFitnessGoals, _fitnessGoalOtherSelected, _otherFitnessGoalController, (v) => _toggle(v, _selectedFitnessGoals, allowNone: false), () => setState(() => _fitnessGoalOtherSelected = !_fitnessGoalOtherSelected)),
          _spacing(),
          _experienceSelect(),

          _bigSpacing(),
          _saveBtn(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // --- Highly Simplified Modular Widgets ---
  Widget _sectionHeader(String t) => Text(t, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF003135)));
  Widget _spacing() => const SizedBox(height: 24);
  Widget _bigSpacing() => const SizedBox(height: 48);

  Widget _input(TextEditingController c, String l, String h, {TextInputType? kb}) {
    return TextField(
      controller: c,
      keyboardType: kb,
      decoration: InputDecoration(labelText: l, hintText: h, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  Widget _genderSelect() {
    return Wrap(
      spacing: 12,
      children: ['Male', 'Female', 'Other'].map((g) => ChoiceChip(
        label: Text(g),
        selected: _selectedGender == g,
        onSelected: (_) => setState(() => _selectedGender = g),
        selectedColor: const Color(0xFF0FA4AF),
        labelStyle: TextStyle(color: _selectedGender == g ? Colors.white : Colors.black),
      )).toList(),
    );
  }

  Widget _activitySelect() {
    return Column(
      children: [
        'Sedentary (little to no exercise)',
        'Light (1-3 days/week)',
        'Moderate (3-5 days/week)',
        'Active (6-7 days/week)',
        'Very Active (intense daily)'
      ].map((lvl) => RadioListTile(
        title: Text(lvl, style: const TextStyle(fontSize: 14)),
        value: lvl,
        groupValue: _selectedActivityLevel,
        onChanged: (v) => setState(() => _selectedActivityLevel = v.toString()),
        activeColor: const Color(0xFF0FA4AF),
      )).toList(),
    );
  }

  Widget _multi(String l, List<String> o, List<String> s, bool os, TextEditingController oc, Function(String) t, VoidCallback oot) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ...o.map((v) => FilterChip(
              label: Text(v, style: const TextStyle(fontSize: 12)),
              selected: s.contains(v),
              onSelected: (_) => t(v),
              selectedColor: const Color(0xFF0FA4AF),
              labelStyle: TextStyle(color: s.contains(v) ? Colors.white : Colors.black),
            )),
            FilterChip(
              label: const Text('Other', style: TextStyle(fontSize: 12)),
              selected: os,
              onSelected: (_) => oot(),
              selectedColor: const Color(0xFF0FA4AF),
              labelStyle: TextStyle(color: os ? Colors.white : Colors.black),
            ),
          ],
        ),
        if (os) ...[const SizedBox(height: 8), TextField(controller: oc, decoration: const InputDecoration(hintText: 'Specify...', filled: true, fillColor: Colors.white))],
      ],
    );
  }

  Widget _upload(String l, String? n, Function(String) onPick) {
    return ListTile(
      leading: Icon(n != null ? Icons.check_circle : Icons.upload_file, color: const Color(0xFF0FA4AF)),
      title: Text(l, style: const TextStyle(fontSize: 14)),
      subtitle: Text(n ?? 'Tap to upload', style: const TextStyle(fontSize: 12)),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () async {
        final XFile? i = await _picker.pickImage(source: ImageSource.gallery);
        if (i != null) onPick(i.name);
      },
    );
  }

  Widget _experienceSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Experience Level', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ..._experienceLevelOptions.map((o) => ChoiceChip(
              label: Text(o, style: const TextStyle(fontSize: 12)),
              selected: _selectedExperienceLevel == o,
              onSelected: (_) => setState(() { _selectedExperienceLevel = o; _experienceOtherSelected = false; }),
              selectedColor: const Color(0xFF0FA4AF),
              labelStyle: TextStyle(color: _selectedExperienceLevel == o ? Colors.white : Colors.black),
            )),
            ChoiceChip(
              label: const Text('Other', style: TextStyle(fontSize: 12)),
              selected: _experienceOtherSelected,
              onSelected: (_) => setState(() { _experienceOtherSelected = true; _selectedExperienceLevel = null; }),
              selectedColor: const Color(0xFF0FA4AF),
              labelStyle: TextStyle(color: _experienceOtherSelected ? Colors.white : Colors.black),
            ),
          ],
        ),
        if (_experienceOtherSelected) ...[const SizedBox(height: 8), TextField(controller: _otherExperienceController, decoration: const InputDecoration(hintText: 'Specify...', filled: true, fillColor: Colors.white))],
      ],
    );
  }

  Widget _saveBtn() {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003135), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      child: const Text('SAVE PROFILE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  void _toggle(String v, List<String> l, {bool allowNone = true}) {
    setState(() {
      if (l.contains(v)) { l.remove(v); }
      else {
        if (allowNone && v == 'None') l.clear();
        else if (allowNone) l.remove('None');
        l.add(v);
      }
    });
  }
}
