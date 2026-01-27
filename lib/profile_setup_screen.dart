import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'main_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Step 1: Basic Info
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = 'Male'; // Default

  // Step 2: Body Metrics
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _selectedActivityLevel = 'Sedentary (little to no exercise)';

  // Step 3: Health Info
  // Medical Conditions
  final List<String> _medicalConditionsOptions = [
    'Diabetes',
    'Hypertension',
    'Heart Disease',
    'Asthma',
    'None',
  ];
  final List<String> _selectedMedicalConditions = [];
  final TextEditingController _otherMedicalConditionController = TextEditingController();
  bool _medicalConditionOtherSelected = false;

  // Allergies
  final List<String> _allergiesOptions = [
    'Peanuts',
    'Dairy',
    'Gluten',
    'Shellfish',
    'Soy',
    'Eggs',
    'None',
  ];
  final List<String> _selectedAllergies = [];
  final TextEditingController _otherAllergyController = TextEditingController();
  bool _allergyOtherSelected = false;

  // Current Injuries
  final List<String> _injuriesOptions = [
    'Knee',
    'Back',
    'Shoulder',
    'Ankle',
    'None',
  ];
  final List<String> _selectedInjuries = [];
  final TextEditingController _otherInjuryController = TextEditingController();
  bool _injuryOtherSelected = false;


  // Step 4: Goals & Experience
  // Fitness Goals
  final List<String> _fitnessGoalsOptions = [
    'Lose weight',
    'Build muscle',
    'Improve endurance',
    'Flexibility',
  ];
  final List<String> _selectedFitnessGoals = [];
  final TextEditingController _otherFitnessGoalController = TextEditingController();
  bool _fitnessGoalOtherSelected = false;

  // Experience Level
  final List<String> _experienceLevelOptions = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];
  String? _selectedExperienceLevel;
  final TextEditingController _otherExperienceController = TextEditingController();
  bool _experienceOtherSelected = false;

  // New Upload Fields
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
    _otherAllergyController.dispose();
    _otherInjuryController.dispose();
    _otherFitnessGoalController.dispose();
    _otherExperienceController.dispose();
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

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeSetup() {
    // Process final data, handle "Other" inputs
    // For demo, just navigate
    print('Profile Setup Complete');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
  }

  double get _progressPercentage => (_currentPage + 1) / 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAFDDE5), // Background color from Figma
      body: Column(
        children: [
          // Header Container
          Container(
             width: double.infinity,
             padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 24),
             decoration: const BoxDecoration(
               gradient: LinearGradient(
                 begin: Alignment(0.50, 0.00),
                 end: Alignment(0.50, 1.00),
                 colors: [Color(0xFF003135), Color(0xFF024950)],
               ),
               borderRadius: BorderRadius.only(
                 bottomLeft: Radius.circular(30), // Slightly rounded if needed, but Figma shows straight or rounded? 
                 // Figma shows Container inside another with rounded border radius 40 for whole screen?
                 // I will stick to standard header or match Figma exactly.
                 // Figma: Positioned container inside main container with 40 radius.
                 // I'll assume standard app bar style for full screen.
               )
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
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
                 const SizedBox(height: 16),
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
                       ),
                     ),
                     Text(
                       '${(_progressPercentage * 100).toInt()}%',
                       style: const TextStyle(
                         color: Color(0xFFAFDDE5),
                         fontSize: 14,
                         fontFamily: 'Arial',
                         fontWeight: FontWeight.w400,
                       ),
                     ),
                   ],
                 ),
                 const SizedBox(height: 8),
                 // Progress Bar
                 Container(
                   height: 8,
                   clipBehavior: Clip.antiAlias,
                   decoration: ShapeDecoration(
                     color: const Color(0xFF024950),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(100),
                     ),
                   ),
                   child: FractionallySizedBox(
                     widthFactor: _progressPercentage,
                     alignment: Alignment.centerLeft,
                     child: Container(
                       decoration: const BoxDecoration(
                         gradient: LinearGradient(
                           begin: Alignment(0.50, 0.00),
                           end: Alignment(0.50, 1.00),
                           colors: [Color(0xFF0FA4AF), Color(0xFF964734)],
                         ),
                       ),
                     ),
                   ),
                 ),
               ],
             ),
          ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe to enforce validation/buttons
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
          
          // Navigation Buttons Area
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white, // Bottom bar background
            child: Row(
              children: [
                if (_currentPage > 0)
                  GestureDetector(
                    onTap: _previousPage,
                    child: Container(
                      width: 112,
                      height: 59,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1.60, color: Color(0xFF024950)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: Color(0xFF024950),
                            fontSize: 16,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      height: 59,
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
                            blurRadius: 15,
                            offset: Offset(0, 10),
                            spreadRadius: -3,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _currentPage == 3 ? 'Finish' : 'Continue', // Step 4 is Finish
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Arial',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
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

  // --- Step 1: Basic Information ---
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Basic Information'),
          const SizedBox(height: 24),
          _buildTextField(label: 'Full Name', controller: _nameController, hint: 'John Doe'),
          const SizedBox(height: 16),
          _buildTextField(label: 'Age', controller: _ageController, hint: 'Enter your age', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          const Text(
            'Gender',
            style: TextStyle(
              color: Color(0xFF024950),
              fontSize: 16,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildGenderOption('Male'),
              const SizedBox(width: 12),
              _buildGenderOption('Female'),
              const SizedBox(width: 12),
              _buildGenderOption('Other'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    bool isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        child: Container(
          height: 51,
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
              ),
            ),
          ),
        ),
      ),
    );
  }

    // --- Step 2: Body Metrics ---
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Body Metrics'),
          const SizedBox(height: 24),
          _buildTextField(label: 'Weight (kg)', controller: _weightController, hint: 'Enter your weight', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _buildTextField(label: 'Height (cm)', controller: _heightController, hint: 'Enter your height', keyboardType: TextInputType.number),
          const SizedBox(height: 24),
          const Text(
            'Activity Level',
            style: TextStyle(
              color: Color(0xFF024950),
              fontSize: 16,
              fontFamily: 'Arial',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          _buildActivityOption('Sedentary (little to no exercise)'),
          const SizedBox(height: 8),
          _buildActivityOption('Light (1-3 days/week)'),
          const SizedBox(height: 8),
          _buildActivityOption('Moderate (3-5 days/week)'),
          const SizedBox(height: 8),
          _buildActivityOption('Active (6-7 days/week)'),
          const SizedBox(height: 8),
          _buildActivityOption('Very Active (intense daily)'),
        ],
      ),
    );
  }

  Widget _buildActivityOption(String level) {
    bool isSelected = _selectedActivityLevel == level;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedActivityLevel = level;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          level,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF024950),
            fontSize: 16,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }


  // --- Step 3: Health Info ---
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Health Information'),
          const SizedBox(height: 24),
          
          // Medical Conditions
          _buildMultiSelectSectionWithOther(
            title: 'Medical Conditions',
            options: _medicalConditionsOptions,
            selectedValues: _selectedMedicalConditions,
            otherSelected: _medicalConditionOtherSelected,
            otherController: _otherMedicalConditionController,
            onOptionTap: (option) {
              setState(() {
                if (_selectedMedicalConditions.contains(option)) {
                  _selectedMedicalConditions.remove(option);
                } else {
                  if (option == 'None') {
                    _selectedMedicalConditions.clear();
                  } else {
                    _selectedMedicalConditions.remove('None');
                  }
                  _selectedMedicalConditions.add(option);
                }
              });
            },
            onOtherTap: () {
              setState(() {
                _medicalConditionOtherSelected = !_medicalConditionOtherSelected;
                if (_medicalConditionOtherSelected) {
                  _selectedMedicalConditions.remove('None');
                }
              });
            },
          ),
          const SizedBox(height: 24),

          // Allergies
          _buildMultiSelectSectionWithOther(
            title: 'Allergies',
            options: _allergiesOptions,
            selectedValues: _selectedAllergies,
            otherSelected: _allergyOtherSelected,
            otherController: _otherAllergyController,
            onOptionTap: (option) {
               setState(() {
                if (_selectedAllergies.contains(option)) {
                  _selectedAllergies.remove(option);
                } else {
                  if (option == 'None') {
                    _selectedAllergies.clear();
                  } else {
                    _selectedAllergies.remove('None');
                  }
                  _selectedAllergies.add(option);
                }
              });
            },
            onOtherTap: () {
              setState(() {
                _allergyOtherSelected = !_allergyOtherSelected;
                 if (_allergyOtherSelected) {
                   _selectedAllergies.remove('None');
                 }
              });
            },
          ),
          const SizedBox(height: 24),

          // Current Injuries
          _buildMultiSelectSectionWithOther(
            title: 'Current Injuries',
            options: _injuriesOptions,
            selectedValues: _selectedInjuries,
            otherSelected: _injuryOtherSelected,
            otherController: _otherInjuryController,
            onOptionTap: (option) {
              setState(() {
                if (_selectedInjuries.contains(option)) {
                  _selectedInjuries.remove(option);
                } else {
                  if (option == 'None') {
                    _selectedInjuries.clear();
                  } else {
                    _selectedInjuries.remove('None');
                  }
                  _selectedInjuries.add(option);
                }
              });
            },
             onOtherTap: () {
              setState(() {
                _injuryOtherSelected = !_injuryOtherSelected;
                 if (_injuryOtherSelected) {
                   _selectedInjuries.remove('None');
                 }
              });
            },
          ),
          const SizedBox(height: 24),

          // Medical Report Upload
          _buildFileUploadSection(
            title: 'Medical Report',
            fileName: _medicalReportName,
            onTap: () => _pickFile(isMedical: true),
          ),
          const SizedBox(height: 24),

          // InBody Upload
          _buildFileUploadSection(
            title: 'InBody Report',
            fileName: _inBodyReportName,
            onTap: () => _pickFile(isMedical: false),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile({required bool isMedical}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isMedical) {
          _medicalReportName = image.name;
        } else {
          _inBodyReportName = image.name;
        }
      });
    }
  }

  Widget _buildFileUploadSection({required String title, String? fileName, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF024950),
            fontSize: 16,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1.60, color: Color(0xFFAFDDE5)),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  fileName != null ? Icons.check_circle : Icons.upload_file,
                  color: fileName != null ? const Color(0xFF0FA4AF) : const Color(0xFF024950),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName ?? 'Upload photo or document',
                    style: TextStyle(
                      color: fileName != null ? const Color(0xFF024950) : const Color(0x7F0A0A0A),
                      fontSize: 16,
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (fileName != null)
                  const Icon(Icons.edit, size: 20, color: Color(0xFF024950)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Step 4: Goals & Experience ---
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Goals & Experience'),
          const SizedBox(height: 24),

          // Fitness Goals
          _buildMultiSelectSectionWithOther(
            title: 'Fitness Goals',
            options: _fitnessGoalsOptions,
            selectedValues: _selectedFitnessGoals,
            otherSelected: _fitnessGoalOtherSelected,
            otherController: _otherFitnessGoalController,
            onOptionTap: (option) {
              setState(() {
                if (_selectedFitnessGoals.contains(option)) {
                  _selectedFitnessGoals.remove(option);
                } else {
                  _selectedFitnessGoals.add(option);
                }
              });
            },
            onOtherTap: () {
              setState(() {
                _fitnessGoalOtherSelected = !_fitnessGoalOtherSelected;
              });
            },
          ),
          const SizedBox(height: 24),

          // Experience Level (Single Select)
          _buildSingleSelectSectionWithOther(
            title: 'Experience Level',
            options: _experienceLevelOptions,
            selectedValue: _selectedExperienceLevel,
            otherSelected: _experienceOtherSelected,
            otherController: _otherExperienceController,
            onOptionTap: (option) {
              setState(() {
                _selectedExperienceLevel = option;
                _experienceOtherSelected = false; // Deselect other if option picked
              });
            },
            onOtherTap: () {
              setState(() {
                _experienceOtherSelected = true;
                _selectedExperienceLevel = null; // Clear main selection if other picked
              });
            },
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF003135),
        fontSize: 16,
        fontFamily: 'Arial',
        fontWeight: FontWeight.w400,
        height: 1.50,
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, String? hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF024950),
            fontSize: 16,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0x7F0A0A0A)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFAFDDE5), width: 1.6),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF024950), width: 1.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectSectionWithOther({
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required bool otherSelected,
    required TextEditingController otherController,
    required Function(String) onOptionTap,
    required Function() onOtherTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF024950),
            fontSize: 16,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...options.map((option) {
              bool isSelected = selectedValues.contains(option);
              return GestureDetector(
                onTap: () => onOptionTap(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: ShapeDecoration(
                    color: isSelected ? const Color(0xFF024950) : Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1.60,
                        color: isSelected ? const Color(0xFF024950) : const Color(0xFFAFDDE5),
                      ),
                      borderRadius: BorderRadius.circular(14), // Figma rounded style
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
            }),
            // Other Button
            GestureDetector(
              onTap: onOtherTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: ShapeDecoration(
                  color: otherSelected ? const Color(0xFF024950) : Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1.60,
                      color: otherSelected ? const Color(0xFF024950) : const Color(0xFFAFDDE5),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Other',
                  style: TextStyle(
                    color: otherSelected ? Colors.white : const Color(0xFF024950),
                    fontSize: 14,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (otherSelected) ...[
          const SizedBox(height: 8),
          TextField(
            controller: otherController,
            decoration: InputDecoration(
              hintText: 'Please specify...',
              hintStyle: const TextStyle(color: Color(0x7F0A0A0A)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFAFDDE5), width: 1.6),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF024950), width: 1.6),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSingleSelectSectionWithOther({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required bool otherSelected,
    required TextEditingController otherController,
    required Function(String) onOptionTap,
    required Function() onOtherTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF024950),
            fontSize: 16,
            fontFamily: 'Arial',
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...options.map((option) {
              bool isSelected = selectedValue == option;
              return GestureDetector(
                onTap: () => onOptionTap(option),
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
            }),
            // Other Button
            GestureDetector(
              onTap: onOtherTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: ShapeDecoration(
                  color: otherSelected ? const Color(0xFF024950) : Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1.60,
                      color: otherSelected ? const Color(0xFF024950) : const Color(0xFFAFDDE5),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Other',
                  style: TextStyle(
                    color: otherSelected ? Colors.white : const Color(0xFF024950),
                    fontSize: 14,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (otherSelected) ...[
          const SizedBox(height: 8),
          TextField(
            controller: otherController,
            decoration: InputDecoration(
              hintText: 'Please specify...',
              hintStyle: const TextStyle(color: Color(0x7F0A0A0A)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFAFDDE5), width: 1.6),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF024950), width: 1.6),
              ),
            ),
          ),
        ],
      ],
    );
  }
}