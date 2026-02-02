import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'animate_in.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          AnimateIn(delay: const Duration(milliseconds: 100), child: _buildTextField(_nameController, 'Full Name', 'John Doe')),
          const SizedBox(height: 16),
          AnimateIn(delay: const Duration(milliseconds: 200), child: _buildTextField(_ageController, 'Age', '28', kb: TextInputType.number)),
          const SizedBox(height: 16),
          AnimateIn(delay: const Duration(milliseconds: 300), child: _genderSelect()),

          const SizedBox(height: 40),
          const AnimateIn(delay: Duration(milliseconds: 400), child: SectionHeader('Body Metrics')),
          const SizedBox(height: 24),
          AnimateIn(delay: const Duration(milliseconds: 500), child: _buildTextField(_weightController, 'Weight (kg)', '70', kb: TextInputType.number)),
          const SizedBox(height: 16),
          AnimateIn(delay: const Duration(milliseconds: 600), child: _buildTextField(_heightController, 'Height (cm)', '175', kb: TextInputType.number)),
          const SizedBox(height: 16),
          _activitySelectAnimated(delay: 700),

          const SizedBox(height: 40),
          const AnimateIn(delay: Duration(milliseconds: 1000), child: SectionHeader('Health Information')),
          const SizedBox(height: 24),
          AnimateIn(delay: const Duration(milliseconds: 1100), child: _multiSelect('Medical Conditions', _medicalConditionsOptions, _selectedMedicalConditions, _medicalConditionOtherSelected, _otherMedicalConditionController, (v) => _toggle(v, _selectedMedicalConditions), () => setState(() => _medicalConditionOtherSelected = !_medicalConditionOtherSelected))),
          const SizedBox(height: 24),
          AnimateIn(delay: const Duration(milliseconds: 1200), child: _uploadTile('Medical Report', _medicalReportName, (v) => setState(() => _medicalReportName = v))),
          const SizedBox(height: 16),
          AnimateIn(delay: const Duration(milliseconds: 1300), child: _uploadTile('InBody Report', _inBodyReportName, (v) => setState(() => _inBodyReportName = v))),

          const SizedBox(height: 40),
          AnimateIn(delay: const Duration(milliseconds: 1400), child: _saveBtn()),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String l, String h, {TextInputType? kb}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l, style: const TextStyle(color: Color(0xFF024950), fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: c, keyboardType: kb,
        decoration: InputDecoration(hintText: h, filled: true, fillColor: Theme.of(context).colorScheme.surface, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
      ),
    ]);
  }

  Widget _genderSelect() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Gender', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: ['Male', 'Female', 'Other'].map((g) {
        bool isSelected = _selectedGender == g;
        return Expanded(child: GestureDetector(
          onTap: () => setState(() => _selectedGender = g),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: isSelected ? const Color(0xFF024950) : Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Text(g, style: TextStyle(color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
          ),
        ));
      }).toList()),
    ]);
  }

  Widget _activitySelectAnimated({required int delay}) {
    final activities = ['Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Activity Level', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ...activities.asMap().entries.map((e) => AnimateIn(
        delay: Duration(milliseconds: delay + (e.key * 100)),
        child: RadioListTile(
          title: Text(e.value), value: e.value, groupValue: _selectedActivityLevel,
          onChanged: (v) => setState(() => _selectedActivityLevel = v.toString()),
          activeColor: const Color(0xFF0FA4AF),
        ),
      )),
    ]);
  }

  Widget _multiSelect(String l, List<String> o, List<String> s, bool os, TextEditingController oc, Function(String) t, VoidCallback oot) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: o.map((v) => FilterChip(label: Text(v), selected: s.contains(v), onSelected: (_) => t(v))).toList()),
    ]);
  }

  Widget _uploadTile(String l, String? n, Function(String) onPick) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(n != null ? Icons.check_circle : Icons.cloud_upload, color: const Color(0xFF0FA4AF)),
        title: Text(l, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(n ?? 'Tap to upload'),
        onTap: () async {
          final XFile? i = await _picker.pickImage(source: ImageSource.gallery);
          if (i != null) onPick(i.name);
        },
      ),
    );
  }

  Widget _saveBtn() {
    return Container(
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF024950), Color(0xFF0FA4AF)]), borderRadius: BorderRadius.circular(14)),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(double.infinity, 56)),
        child: const Text('SAVE CHANGES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
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

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface));
  }
}
