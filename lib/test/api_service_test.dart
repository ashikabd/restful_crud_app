import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_application_1/services/api_service.dart';

// Simple manual mock without build_runner
class MockClient extends http.BaseClient {
  Function(http.Request)? onRequest;
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (onRequest != null) {
      return onRequest!(request as http.Request);
    }
    throw UnimplementedError();
  }
}

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      apiService = ApiService(client: mockClient);
    });

    test('getObjects returns list of objects on success', () async {
      // Arrange
      final mockResponse = [
        {'id': '1', 'name': 'Test Object 1', 'data': {'key': 'value1'}},
        {'id': '2', 'name': 'Test Object 2', 'data': {'key': 'value2'}},
      ];

      mockClient.onRequest = (request) async {
        if (request.url.toString() == 'https://api.restful-api.dev/objects') {
          return http.StreamedResponse(
            Stream.value(utf8.encode(json.encode(mockResponse))),
            200,
          );
        }
        return http.StreamedResponse(Stream.value([]), 404);
      };

      // Act
      final result = await apiService.getObjects();

      // Assert
      expect(result.length, 2);
      expect(result[0].name, 'Test Object 1');
      expect(result[1].id, '2');
    });

    test('getObjects throws exception on error', () async {
      // Arrange
      mockClient.onRequest = (request) async {
        return http.StreamedResponse(
          Stream.value(utf8.encode('Error')),
          500,
        );
      };

      // Act & Assert
      expect(() => apiService.getObjects(), throwsException);
    });
  });
}