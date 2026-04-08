import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:mobile_frontend/data/services/api_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late ApiService apiService;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    apiService = ApiService(client: mockHttpClient);
    registerFallbackValue(Uri.parse('http://localhost:3000'));
  });

  group('ApiService', () {
    test('chatWithAssistant should return response string on 200', () async {
      final mockResponse = {'response': 'Hello from AI'};
      
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await apiService.chatWithAssistant(messages: [{'role': 'user', 'content': 'Hi'}]);

      expect(result, 'Hello from AI');
    });

    test('chatWithAssistant should throw ApiException on 500', () async {
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Internal Error', 500));

      expect(
        () => apiService.chatWithAssistant(messages: []),
        throwsA(isA<ApiException>()),
      );
    });

    test('searchVideo should return videoId on 200', () async {
      final mockResponse = {'videoId': 'abc12345'};
      
      when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      final result = await apiService.searchVideo('pushups');

      expect(result, 'abc12345');
    });
  });
}
