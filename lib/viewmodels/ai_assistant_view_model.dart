import 'base_view_model.dart';

/// ViewModel for AI Assistant Screen
class AiAssistantViewModel extends BaseViewModel {
  // Welcome message
  final String welcomeMessage = "Hello! I'm your AI fitness assistant. I can help you with personalized diet plans, workout recommendations, and answer any health-related questions. How can I assist you today?";

  // Quick action categories
  final List<QuickAction> quickActions = [
    QuickAction(title: 'Diet Plan', iconName: 'restaurant_menu'),
    QuickAction(title: 'Workout', iconName: 'fitness_center'),
    QuickAction(title: 'Progress', iconName: 'analytics'),
    QuickAction(title: 'Tips', iconName: 'lightbulb'),
  ];

  /// Handle quick action tap
  void onQuickActionTap(String actionTitle) {
    // In a real app, this would handle quick actions
    // For now, just placeholder
    notifyListeners();
  }

  /// Send message
  void sendMessage(String message) {
    // In a real app, this would send message to AI service
    // For now, just placeholder
    notifyListeners();
  }
}

/// Quick action model
class QuickAction {
  final String title;
  final String iconName;

  QuickAction({required this.title, required this.iconName});
}
