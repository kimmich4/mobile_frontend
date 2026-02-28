import 'base_view_model.dart';
import '../data/models/message_model.dart';
import '../data/services/api_service.dart';

/// ViewModel for AI Assistant Screen
class AiAssistantViewModel extends BaseViewModel {
  final ApiService _apiService = ApiService();
  
  // Message history
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm your AI fitness assistant. I can help you with personalized diet plans, workout recommendations, and answer any health-related questions. How can I assist you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  List<ChatMessage> get messages => _messages;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _prefillText;
  String? get prefillText => _prefillText;

  void clearPrefill() {
    _prefillText = null;
  }

  // Quick action categories
  final List<QuickAction> quickActions = [
    QuickAction(title: 'Progress', iconName: 'analytics'),
    QuickAction(title: 'Tips', iconName: 'lightbulb'),
    QuickAction(title: 'Alternative', iconName: 'swap_horiz'),
  ];

  /// Handle quick action tap
  void onQuickActionTap(String actionTitle) {
    String message = "";
    bool shouldSend = true;

    switch (actionTitle) {
      case 'Progress':
        message = "How can I track my fitness progress?";
        break;
      case 'Tips':
        message = "Give me some quick fitness tips.";
        break;
      case 'Alternative':
        message = "Give me an alternative for ";
        shouldSend = false;
        break;
    }
    
    if (message.isNotEmpty) {
      if (shouldSend) {
        sendMessage(message);
      } else {
        _prefillText = message;
        notifyListeners();
      }
    }
  }

  /// Send message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    
    _isLoading = true;
    notifyListeners();

    try {
      // Prepare history for AI (limit to last 10 messages for context)
      final history = _messages
          .map((m) => m.toJson())
          .toList();
          
      final aiResponse = await _apiService.chatWithAssistant(messages: history);
      
      // Add AI response
      _messages.add(ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _messages.add(ChatMessage(
        text: "Sorry, I'm having trouble connecting. Let's try again.",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Quick action model
class QuickAction {
  final String title;
  final String iconName;

  QuickAction({required this.title, required this.iconName});
}
