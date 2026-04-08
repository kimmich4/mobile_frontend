import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_frontend/viewmodels/ai_assistant_view_model.dart';
import 'package:mobile_frontend/data/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late AiAssistantViewModel viewModel;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    viewModel = AiAssistantViewModel(apiService: mockApiService);
  });

  group('AiAssistantViewModel', () {
    test('initial message should be present', () {
      expect(viewModel.messages.length, 1);
      expect(viewModel.messages.first.isUser, false);
    });

    test('sendMessage should add user message and then AI message', () async {
      when(() => mockApiService.chatWithAssistant(messages: any(named: 'messages')))
          .thenAnswer((_) async => "Response from AI");

      await viewModel.sendMessage("Hello AI");

      expect(viewModel.messages.length, 3); // Initial + User + AI
      expect(viewModel.messages[1].text, "Hello AI");
      expect(viewModel.messages[1].isUser, true);
      expect(viewModel.messages[2].text, "Response from AI");
      expect(viewModel.messages[2].isUser, false);
    });

    test('sendMessage should add error message on API failure', () async {
      when(() => mockApiService.chatWithAssistant(messages: any(named: 'messages')))
          .thenThrow(Exception("Network error"));

      await viewModel.sendMessage("Error test");

      expect(viewModel.messages.length, 3);
      expect(viewModel.messages[2].text.contains("trouble connecting"), true);
    });

    test('onQuickActionTap should send message for Progress', () async {
       when(() => mockApiService.chatWithAssistant(messages: any(named: 'messages')))
          .thenAnswer((_) async => "Progress response");

      viewModel.onQuickActionTap('Progress');
      
      // Since it's async internally but not returned, we might need a small delay or check state
      await Future.delayed(Duration(milliseconds: 10));
      expect(viewModel.messages.any((m) => m.text.contains("track my fitness progress")), true);
    });
  });
}
