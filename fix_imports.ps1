# Screen Import Fix Script
# This script fixes all broken imports between screens after reorganization

$ErrorActionPreference = "SilentlyContinue"

# Define import mapping (old class name -> new file name)
$importMap = @{
    'AuthScreen' = 'login_screen';
    'Signupscreen' = 'signup_screen';  
    'ProfileSetupScreen' = 'profile_setup_screen';
    'MainScreen' = 'main_screen';
    'HomeScreen' = 'home_screen';
    'OnboardingScreen' = 'onboarding_screen';
    'WorkoutPlanScreen' = 'workout_plan_screen';
    'DietScreen' = 'diet_screen';
    'SettingsScreen' = 'settings_screen';
    'ProgressTrackingScreen' = 'progress_tracking_screen';
    'AiAssistantScreen' = 'ai_assistant_screen';
    'EditProfileScreen' = 'edit_profile_screen';
    'VideoScreen' = 'video_screen'
}

# Get all screen files
$screenFiles = Get-ChildItem -Path "lib\ui\screens\*.dart"

foreach ($file in $screenFiles) {
    $content = Get-Content $file.FullName -Raw
    $modified = $false
    
    # Check each class name and add import if referenced
    foreach ($className in $importMap.Keys) {
        $fileName = $importMap[$className]
        
        # If the class is referenced but not imported
        if ($content -match $className -and $content -notmatch "import '$fileName\.dart';") {
            # Add import after the first import line
            $content = $content -replace "(import 'package:flutter/material\.dart';\r?\n)", "`$1import '$fileName.dart';`r`n"
            $modified = $true
        }
    }
    
    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Fixed imports in: $($file.Name)"
    }
}

Write-Host "Import fix completed!"
