/// Comprehensive User Model containing all user data from profile setup and usage
class UserModel {
  // Basic Information (Step 1 of Profile Setup)
  final String? fullName;
  final int? age;
  final String? gender; // 'Male', 'Female', 'Other'

  // Body Metrics (Step 2 of Profile Setup)
  final double? weightKg;
  final double? heightCm;
  final String? activityLevel; // 'Sedentary', 'Light', 'Moderate', 'Active', 'Very Active'

  // Health Information (Step 3 of Profile Setup)
  final List<String> medicalConditions;
  final String? otherMedicalCondition;
  final String? medicalReportPath;
  final String? medicalReportName;
  final String? inBodyReportPath;
  final String? inBodyReportName;
  final List<String> allergies;
  final String? otherAllergy;
  final List<String> currentInjuries;
  final String? otherInjury;
  final String? medicalReportText;
  final String? inBodyReportText;

  // Goals & Experience (Step 4 of Profile Setup)
  final List<String> fitnessGoals; // 'Lose weight', 'Build muscle', etc.
  final String? otherFitnessGoal;
  final String? experienceLevel; // 'Beginner', 'Intermediate', 'Advanced'
  final String? otherExperience;

  // Authentication Data
  final String? email;
  final String? userId;
  
  // Profile Data
  final String? profilePicturePath;
  final String? profileInitial; // For avatar display (e.g., 'J')
  final bool isPremiumMember;

  // Current Stats (updated during app usage)
  final int? currentCalories;
  final int? dailyCalorieGoal;
  final int? workoutsCompletedThisWeek;
  final int? workoutsGoalPerWeek;
  final int? currentStreak;
  final double? currentWeightKg;
  final double? goalWeightKg;
  final Map<int, List<int>> completedMeals; // Map of dayIndex -> List of meal indices
  final Map<int, List<int>> completedHomeExercises; // Map of dayIndex -> List of home exercise IDs
  final Map<int, List<int>> completedGymExercises; // Map of dayIndex -> List of gym exercise IDs

  // Preferences
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool dataSharingEnabled;

  UserModel({
    // Basic Information
    this.fullName,
    this.age,
    this.gender,
    
    // Body Metrics
    this.weightKg,
    this.heightCm,
    this.activityLevel,
    
    // Health Information
    this.medicalConditions = const [],
    this.otherMedicalCondition,
    this.medicalReportPath,
    this.medicalReportName,
    this.inBodyReportPath,
    this.inBodyReportName,
    this.allergies = const [],
    this.otherAllergy,
    this.currentInjuries = const [],
    this.otherInjury,
    
    // Goals & Experience
    this.fitnessGoals = const [],
    this.otherFitnessGoal,
    this.experienceLevel,
    this.otherExperience,
    
    // Authentication
    this.email,
    this.userId,
    
    // Profile
    this.profilePicturePath,
    this.profileInitial,
    this.isPremiumMember = false,
    
    // Current Stats
    this.currentCalories,
    this.dailyCalorieGoal = 2200,
    this.workoutsCompletedThisWeek,
    this.workoutsGoalPerWeek = 5,
    this.currentStreak,
    this.currentWeightKg,
    this.goalWeightKg,
    this.completedMeals = const {},
    this.completedHomeExercises = const {},
    this.completedGymExercises = const {},
    this.medicalReportText,
    this.inBodyReportText,
    
    // Preferences
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.dataSharingEnabled = false,
  });

  /// Calculate BMI if height and weight are available
  double? get bmi {
    if (weightKg != null && heightCm != null && heightCm! > 0) {
      final heightM = heightCm! / 100;
      return weightKg! / (heightM * heightM);
    }
    return null;
  }

  /// Get weight remaining to goal
  double? get weightRemainingToGoal {
    if (currentWeightKg != null && goalWeightKg != null) {
      return (currentWeightKg! - goalWeightKg!).abs();
    }
    return null;
  }

  /// Get calorie consumption percentage
  double? get calorieConsumptionPercentage {
    if (currentCalories != null && dailyCalorieGoal != null && dailyCalorieGoal! > 0) {
      return currentCalories! / dailyCalorieGoal!;
    }
    return null;
  }

  /// Get workout completion percentage for the week
  double? get workoutCompletionPercentage {
    if (workoutsCompletedThisWeek != null && workoutsGoalPerWeek != null && workoutsGoalPerWeek! > 0) {
      return workoutsCompletedThisWeek! / workoutsGoalPerWeek!;
    }
    return null;
  }

  /// Create a copy of this user with updated fields
  UserModel copyWith({
    String? fullName,
    int? age,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? activityLevel,
    List<String>? medicalConditions,
    String? otherMedicalCondition,
    String? medicalReportPath,
    String? medicalReportName,
    String? inBodyReportPath,
    String? inBodyReportName,
    List<String>? allergies,
    String? otherAllergy,
    List<String>? currentInjuries,
    String? otherInjury,
    List<String>? fitnessGoals,
    String? otherFitnessGoal,
    String? experienceLevel,
    String? otherExperience,
    String? medicalReportText,
    String? inBodyReportText,
    String? email,
    String? userId,
    String? profilePicturePath,
    String? profileInitial,
    bool? isPremiumMember,
    int? currentCalories,
    int? dailyCalorieGoal,
    int? workoutsCompletedThisWeek,
    int? workoutsGoalPerWeek,
    int? currentStreak,
    double? currentWeightKg,
    double? goalWeightKg,
    Map<int, List<int>>? completedMeals,
    Map<int, List<int>>? completedHomeExercises,
    Map<int, List<int>>? completedGymExercises,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    bool? dataSharingEnabled,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      activityLevel: activityLevel ?? this.activityLevel,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      otherMedicalCondition: otherMedicalCondition ?? this.otherMedicalCondition,
      medicalReportPath: medicalReportPath ?? this.medicalReportPath,
      medicalReportName: medicalReportName ?? this.medicalReportName,
      inBodyReportPath: inBodyReportPath ?? this.inBodyReportPath,
      inBodyReportName: inBodyReportName ?? this.inBodyReportName,
      allergies: allergies ?? this.allergies,
      otherAllergy: otherAllergy ?? this.otherAllergy,
      currentInjuries: currentInjuries ?? this.currentInjuries,
      otherInjury: otherInjury ?? this.otherInjury,
      fitnessGoals: fitnessGoals ?? this.fitnessGoals,
      otherFitnessGoal: otherFitnessGoal ?? this.otherFitnessGoal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      otherExperience: otherExperience ?? this.otherExperience,
      email: email ?? this.email,
      userId: userId ?? this.userId,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      profileInitial: profileInitial ?? this.profileInitial,
      isPremiumMember: isPremiumMember ?? this.isPremiumMember,
      currentCalories: currentCalories ?? this.currentCalories,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      workoutsCompletedThisWeek: workoutsCompletedThisWeek ?? this.workoutsCompletedThisWeek,
      workoutsGoalPerWeek: workoutsGoalPerWeek ?? this.workoutsGoalPerWeek,
      currentStreak: currentStreak ?? this.currentStreak,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
      completedMeals: completedMeals ?? this.completedMeals,
      completedHomeExercises: completedHomeExercises ?? this.completedHomeExercises,
      completedGymExercises: completedGymExercises ?? this.completedGymExercises,
      medicalReportText: medicalReportText ?? this.medicalReportText,
      inBodyReportText: inBodyReportText ?? this.inBodyReportText,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      dataSharingEnabled: dataSharingEnabled ?? this.dataSharingEnabled,
    );
  }

  /// Convert to JSON (for potential future storage/API integration)
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'age': age,
      'gender': gender,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'activityLevel': activityLevel,
      'medicalConditions': medicalConditions,
      'otherMedicalCondition': otherMedicalCondition,
      'medicalReportPath': medicalReportPath,
      'medicalReportName': medicalReportName,
      'inBodyReportPath': inBodyReportPath,
      'inBodyReportName': inBodyReportName,
      'allergies': allergies,
      'otherAllergy': otherAllergy,
      'currentInjuries': currentInjuries,
      'otherInjury': otherInjury,
      'medicalReportText': medicalReportText,
      'inBodyReportText': inBodyReportText,
      'fitnessGoals': fitnessGoals,
      'otherFitnessGoal': otherFitnessGoal,
      'experienceLevel': experienceLevel,
      'otherExperience': otherExperience,
      'email': email,
      'userId': userId,
      'profilePicturePath': profilePicturePath,
      'profileInitial': profileInitial,
      'isPremiumMember': isPremiumMember,
      'currentCalories': currentCalories,
      'dailyCalorieGoal': dailyCalorieGoal,
      'workoutsCompletedThisWeek': workoutsCompletedThisWeek,
      'workoutsGoalPerWeek': workoutsGoalPerWeek,
      'currentStreak': currentStreak,
      'currentWeightKg': currentWeightKg,
      'goalWeightKg': goalWeightKg,
      // Convert map keys to string for JSON
      'completedMeals': completedMeals.map((k, v) => MapEntry(k.toString(), v)),
      'completedHomeExercises': completedHomeExercises.map((k, v) => MapEntry(k.toString(), v)),
      'completedGymExercises': completedGymExercises.map((k, v) => MapEntry(k.toString(), v)),
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'dataSharingEnabled': dataSharingEnabled,
    };
  }

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      weightKg: json['weightKg'] as double?,
      heightCm: json['heightCm'] as double?,
      activityLevel: json['activityLevel'] as String?,
      medicalConditions: (json['medicalConditions'] as List<dynamic>?)?.cast<String>() ?? [],
      otherMedicalCondition: json['otherMedicalCondition'] as String?,
      medicalReportPath: json['medicalReportPath'] as String?,
      medicalReportName: json['medicalReportName'] as String?,
      inBodyReportPath: json['inBodyReportPath'] as String?,
      inBodyReportName: json['inBodyReportName'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)?.cast<String>() ?? [],
      otherAllergy: json['otherAllergy'] as String?,
      currentInjuries: (json['currentInjuries'] as List<dynamic>?)?.cast<String>() ?? [],
      otherInjury: json['otherInjury'] as String?,
      medicalReportText: json['medicalReportText'] as String?,
      inBodyReportText: json['inBodyReportText'] as String?,
      fitnessGoals: (json['fitnessGoals'] as List<dynamic>?)?.cast<String>() ?? [],
      otherFitnessGoal: json['otherFitnessGoal'] as String?,
      experienceLevel: json['experienceLevel'] as String?,
      otherExperience: json['otherExperience'] as String?,
      email: json['email'] as String?,
      userId: json['userId'] as String?,
      profilePicturePath: json['profilePicturePath'] as String?,
      profileInitial: json['profileInitial'] as String?,
      isPremiumMember: json['isPremiumMember'] as bool? ?? false,
      currentCalories: json['currentCalories'] as int?,
      dailyCalorieGoal: json['dailyCalorieGoal'] as int? ?? 2200,
      workoutsCompletedThisWeek: json['workoutsCompletedThisWeek'] as int?,
      workoutsGoalPerWeek: json['workoutsGoalPerWeek'] as int? ?? 5,
      currentStreak: json['currentStreak'] as int?,
      currentWeightKg: json['currentWeightKg'] as double?,
      goalWeightKg: json['goalWeightKg'] as double?,
      completedMeals: _parseMap(json['completedMeals']),
      completedHomeExercises: _parseMap(json['completedHomeExercises']),
      completedGymExercises: _parseMap(json['completedGymExercises']),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      dataSharingEnabled: json['dataSharingEnabled'] as bool? ?? false,
    );
  }

  static Map<int, List<int>> _parseMap(dynamic jsonMap) {
    if (jsonMap == null) return {};
    if (jsonMap is Map) {
      return jsonMap.map((key, value) => MapEntry(
            int.parse(key.toString()),
            (value as List<dynamic>).cast<int>(),
          ));
    }
    return {};
  }
}
