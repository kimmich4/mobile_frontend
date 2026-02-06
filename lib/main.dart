import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/screens/splash_screen.dart';
import 'core/theme/theme_manager.dart';
import 'viewmodels/splash_view_model.dart';
import 'viewmodels/onboarding_view_model.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/signup_view_model.dart';
import 'viewmodels/profile_setup_view_model.dart';
import 'viewmodels/main_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/workout_view_model.dart';
import 'viewmodels/diet_view_model.dart';
import 'viewmodels/settings_view_model.dart';
import 'viewmodels/progress_tracking_view_model.dart';
import 'viewmodels/ai_assistant_view_model.dart';
import 'viewmodels/edit_profile_view_model.dart';
import 'viewmodels/video_view_model.dart';

void main() {
  runApp(const FitBiteApp());
}

class FitBiteApp extends StatelessWidget {
  const FitBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileSetupViewModel()),
        ChangeNotifierProvider(create: (_) => MainViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => WorkoutViewModel()),
        ChangeNotifierProvider(create: (_) => DietViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => ProgressTrackingViewModel()),
        ChangeNotifierProvider(create: (_) => AiAssistantViewModel()),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
        ChangeNotifierProvider(create: (_) => VideoViewModel()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeManager.themeMode,
        builder: (context, mode, child) {
          return MaterialApp(
            title: 'FitBite',
            debugShowCheckedModeBanner: false,
            theme: ThemeManager.lightTheme,
            darkTheme: ThemeManager.darkTheme,
            themeMode: mode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
