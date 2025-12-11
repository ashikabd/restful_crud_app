import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_object.dart';

class ApiService {
  static const String baseUrl = 'https://api.restful-api.dev/objects';
  
  final http.Client _client;
  
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<ApiObject>> getObjects() async {
    try {
      final response = await _client.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ApiObject.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load objects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiObject> getObjectById(String id) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/$id'));
      
      if (response.statusCode == 200) {
        return ApiObject.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Object not found');
      } else {
        throw Exception('Failed to load object: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiObject> createObject(ApiObject object) async {
    try {
      final response = await _client.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(object.toJson()),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiObject.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create object: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ApiObject> updateObject(String id, ApiObject object) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(object.toJson()),
      );
      
      if (response.statusCode == 200) {
        return ApiObject.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Object not found');
      } else {
        throw Exception('Failed to update object: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteObject(String id) async {
    try {
      final response = await _client.delete(Uri.parse('$baseUrl/$id'));
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        if (response.statusCode == 404) {
          throw Exception('Object not found');
        }
        throw Exception('Failed to delete object: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}