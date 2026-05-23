/// comprehensive user model containing all user data from profile setup and usage
class UserModel {
  // basic information (step 1 of profile setup)
  final String? fullName;
  final int? age;
  final String? gender; // 'male', 'female', 'other'

  // body metrics (step 2 of profile setup)
  final double? weightKg;
  final double? heightCm;
  final String? activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very active'

  // health information (step 3 of profile setup)
  final List<String> medicalConditions;
  final String? otherMedicalCondition;
  final String? medicalReportPath;
  final String? medicalReportName;
  final String? inBodyReportPath;
  final String? inBodyReportName;
  final List<String> allergies;
  final String? otherAllergy;
  final String? dislikedFoods;
  final List<String> currentInjuries;
  final String? otherInjury;
  final String? medicalReportText;
  final String? inBodyReportText;

  // goals & experience (step 4 of profile setup)
  final List<String> fitnessGoals; // 'lose weight', 'build muscle', etc.
  final String? otherFitnessGoal;
  final String? experienceLevel; // 'beginner', 'intermediate', 'advanced'
  final String? otherExperience;
  final int? trainingDaysPerWeek;
  final String? preferredWorkoutSplit;

  // authentication data
  final String? email;
  final String? userId;
  
  // profile data
  final String? profilePicturePath;
  final String? profileInitial; // for avatar display (e.g., 'j')
  final bool isPremiumMember;

  // current stats (updated during app usage)
  final int? currentCalories;
  final int? dailyCalorieGoal;
  final int? workoutsCompletedThisWeek;
  final int? workoutsGoalPerWeek;
  final int? currentStreak;
  final int waterIntake; // glasses of water today
  final double? currentWeightKg;
  final double? goalWeightKg;
  // progress tracking weight - entered by user in the progress screen (separate from signup weightkg)
  final double? trackedWeightKg;
  final Map<int, List<int>> completedMeals; // map of dayindex - list of meal indices
  final Map<int, List<int>> completedHomeExercises; // map of dayindex - list of home exercise ids
  final Map<int, List<int>> completedGymExercises; // map of dayindex - list of gym exercise ids

  // preferences
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool dataSharingEnabled;

  UserModel({
    // basic information
    this.fullName,
    this.age,
    this.gender,
    
    // body metrics
    this.weightKg,
    this.heightCm,
    this.activityLevel,
    
    // health information
    this.medicalConditions = const [],
    this.otherMedicalCondition,
    this.medicalReportPath,
    this.medicalReportName,
    this.inBodyReportPath,
    this.inBodyReportName,
    this.allergies = const [],
    this.otherAllergy,
    this.dislikedFoods,
    this.currentInjuries = const [],
    this.otherInjury,
    
    // goals & experience
    this.fitnessGoals = const [],
    this.otherFitnessGoal,
    this.experienceLevel,
    this.otherExperience,
    this.trainingDaysPerWeek,
    this.preferredWorkoutSplit,
    
    // authentication
    this.email,
    this.userId,
    
    // profile
    this.profilePicturePath,
    this.profileInitial,
    this.isPremiumMember = false,
    
    // current stats
    this.currentCalories,
    this.dailyCalorieGoal = 2200,
    this.workoutsCompletedThisWeek,
    this.workoutsGoalPerWeek = 5,
    this.currentStreak,
    this.waterIntake = 0,
    this.currentWeightKg,
    this.goalWeightKg,
    this.trackedWeightKg,
    this.completedMeals = const {},
    this.completedHomeExercises = const {},
    this.completedGymExercises = const {},
    this.medicalReportText,
    this.inBodyReportText,
    
    // preferences
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.dataSharingEnabled = false,
  });

  /// calculate bmi if height and weight are available
  double? get bmi {
    if (weightKg != null && heightCm != null && heightCm! > 0) {
      final heightM = heightCm! / 100;
      return weightKg! / (heightM * heightM);
    }
    return null;
  }

  /// get weight remaining to goal
  double? get weightRemainingToGoal {
    if (currentWeightKg != null && goalWeightKg != null) {
      return (currentWeightKg! - goalWeightKg!).abs();
    }
    return null;
  }

  /// get calorie consumption percentage
  double? get calorieConsumptionPercentage {
    if (currentCalories != null && dailyCalorieGoal != null && dailyCalorieGoal! > 0) {
      return currentCalories! / dailyCalorieGoal!;
    }
    return null;
  }

  /// get workout completion percentage for the week
  double? get workoutCompletionPercentage {
    if (workoutsCompletedThisWeek != null && workoutsGoalPerWeek != null && workoutsGoalPerWeek! > 0) {
      return workoutsCompletedThisWeek! / workoutsGoalPerWeek!;
    }
    return null;
  }

  /// create a copy of this user with updated fields
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
    String? dislikedFoods,
    List<String>? currentInjuries,
    String? otherInjury,
    List<String>? fitnessGoals,
    String? otherFitnessGoal,
    String? experienceLevel,
    String? otherExperience,
    int? trainingDaysPerWeek,
    String? preferredWorkoutSplit,
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
    int? waterIntake,
    double? currentWeightKg,
    double? goalWeightKg,
    double? trackedWeightKg,
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
      dislikedFoods: dislikedFoods ?? this.dislikedFoods,
      currentInjuries: currentInjuries ?? this.currentInjuries,
      otherInjury: otherInjury ?? this.otherInjury,
      fitnessGoals: fitnessGoals ?? this.fitnessGoals,
      otherFitnessGoal: otherFitnessGoal ?? this.otherFitnessGoal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      otherExperience: otherExperience ?? this.otherExperience,
      trainingDaysPerWeek: trainingDaysPerWeek ?? this.trainingDaysPerWeek,
      preferredWorkoutSplit: preferredWorkoutSplit ?? this.preferredWorkoutSplit,
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
      waterIntake: waterIntake ?? this.waterIntake,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
      trackedWeightKg: trackedWeightKg ?? this.trackedWeightKg,
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

  /// convert to json (for potential future storage/api integration)
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
      'dislikedFoods': dislikedFoods,
      'currentInjuries': currentInjuries,
      'otherInjury': otherInjury,
      'medicalReportText': medicalReportText,
      'inBodyReportText': inBodyReportText,
      'fitnessGoals': fitnessGoals,
      'otherFitnessGoal': otherFitnessGoal,
      'experienceLevel': experienceLevel,
      'otherExperience': otherExperience,
      'trainingDaysPerWeek': trainingDaysPerWeek,
      'preferredWorkoutSplit': preferredWorkoutSplit,
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
      'waterIntake': waterIntake,
      'currentWeightKg': currentWeightKg,
      'goalWeightKg': goalWeightKg,
      'trackedWeightKg': trackedWeightKg,
      // convert map keys to string for json
      'completedMeals': completedMeals.map((k, v) => MapEntry(k.toString(), v)),
      'completedHomeExercises': completedHomeExercises.map((k, v) => MapEntry(k.toString(), v)),
      'completedGymExercises': completedGymExercises.map((k, v) => MapEntry(k.toString(), v)),
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'dataSharingEnabled': dataSharingEnabled,
    };
  }

  /// create from json
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      activityLevel: json['activityLevel'] as String?,
      medicalConditions: (json['medicalConditions'] as List<dynamic>?)?.cast<String>() ?? [],
      otherMedicalCondition: json['otherMedicalCondition'] as String?,
      medicalReportPath: json['medicalReportPath'] as String?,
      medicalReportName: json['medicalReportName'] as String?,
      inBodyReportPath: json['inBodyReportPath'] as String?,
      inBodyReportName: json['inBodyReportName'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)?.cast<String>() ?? [],
      otherAllergy: json['otherAllergy'] as String?,
      dislikedFoods: json['dislikedFoods'] as String?,
      currentInjuries: (json['currentInjuries'] as List<dynamic>?)?.cast<String>() ?? [],
      otherInjury: json['otherInjury'] as String?,
      medicalReportText: json['medicalReportText'] as String?,
      inBodyReportText: json['inBodyReportText'] as String?,
      fitnessGoals: (json['fitnessGoals'] as List<dynamic>?)?.cast<String>() ?? [],
      otherFitnessGoal: json['otherFitnessGoal'] as String?,
      experienceLevel: json['experienceLevel'] as String?,
      otherExperience: json['otherExperience'] as String?,
      trainingDaysPerWeek: (json['trainingDaysPerWeek'] as num?)?.toInt(),
      preferredWorkoutSplit: json['preferredWorkoutSplit'] as String?,
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
      waterIntake: json['waterIntake'] as int? ?? 0,
      currentWeightKg: (json['currentWeightKg'] as num?)?.toDouble(),
      goalWeightKg: (json['goalWeightKg'] as num?)?.toDouble(),
      trackedWeightKg: (json['trackedWeightKg'] as num?)?.toDouble(),
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
            (value as List<dynamic>).map((e) => (e as num).toInt()).toList(),
          ));
    }
    return {};
  }
}
