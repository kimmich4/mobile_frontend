import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_frontend/data/models/message_model.dart';

void main() {
  group('MessageModel', () {
    test('toJson should format for AI API', () {
      final userMessage = ChatMessage(
        text: 'Hello',
        isUser: true,
        timestamp: DateTime.now(),
      );
      final assistantMessage = ChatMessage(
        text: 'Hi',
        isUser: false,
        timestamp: DateTime.now(),
      );

      expect(userMessage.toJson()['role'], 'user');
      expect(userMessage.toJson()['content'], 'Hello');
      expect(assistantMessage.toJson()['role'], 'assistant');
      expect(assistantMessage.toJson()['content'], 'Hi');
    });
  });
}
