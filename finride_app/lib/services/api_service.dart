// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  void _logRequest(String method, String endpoint, [dynamic body]) {
    debugPrint('\n🌐 API Request: $method $endpoint');
    if (body != null) {
      debugPrint('📦 Request Body: ${json.encode(body)}');
    }
  }

  void _logResponse(http.Response response, String endpoint) {
    final maxLength = 2000; // Increase from default
    final body = response.body.length > maxLength 
        ? '${response.body.substring(0, maxLength)}...(truncated)' 
        : response.body;
    debugPrint('📥 Response for $endpoint:');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: $body\n');
  }

  Future<Map<String, dynamic>> getCustomer(String phoneNumber) async {
    final endpoint = '/customers/$phoneNumber';
    _logRequest('GET', endpoint);
    
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    _logResponse(response, endpoint);
    _handleError(response);
    return json.decode(response.body);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    const endpoint = '/products';
    _logRequest('GET', endpoint);
    
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    _logResponse(response, endpoint);
    _handleError(response);
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<Map<String, dynamic>>> getInteractions() async {
    const endpoint = '/interactions';
    _logRequest('GET', endpoint);
    
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    _logResponse(response, endpoint);
    _handleError(response);
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<Map<String, dynamic>> createInteraction(Map<String, dynamic> data) async {
    const endpoint = '/interactions';
    _logRequest('POST', endpoint, data);
    
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    _logResponse(response, endpoint);
    _handleError(response);
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createOrUpdateCustomer(Map<String, dynamic> customerData) async {
    const endpoint = '/customers';
    _logRequest('POST', endpoint, customerData);
    
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(customerData),
    );
    _logResponse(response, endpoint);
    _handleError(response);
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createNewInteraction(Map<String, dynamic> interactionData) async {
    const endpoint = '/interactions';
    _logRequest('POST', endpoint, interactionData);
    
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(interactionData),
    );
    _logResponse(response, endpoint);
    _handleError(response);
    return json.decode(response.body);
  }

  Future<void> saveAnalysis(int rideId, dynamic analysis) async {
    final endpoint = '/interactions/$rideId/analysis';
    _logRequest('POST', endpoint, analysis);
    
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(analysis),
    );
    _logResponse(response, endpoint);
    _handleError(response);
  }

  Future<Map<String, dynamic>> getCompliance() async {
    const endpoint = '/compliance/current-ride';
    _logRequest('GET', endpoint);
    
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    _logResponse(response, endpoint);
    _handleError(response);
    return json.decode(response.body);
  }

  Future<void> updateCompliance(Map<String, dynamic> data) async {
    const endpoint = '/compliance/current-ride';
    _logRequest('POST', endpoint, data);
    
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    _logResponse(response, endpoint);
    _handleError(response);
  }

  Future<Map<String, dynamic>> getDashboardAnalytics() async {
    const endpoint = '/analytics/dashboard';
    _logRequest('GET', endpoint);
    
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    _logResponse(response, endpoint);
    _handleError(response);
    return json.decode(response.body);
  }

  Future<void> addInteraction(String phoneNumber, Map<String, dynamic> interaction) async {
    final endpoint = '/customers/$phoneNumber/interactions';
    _logRequest('POST', endpoint, interaction);
    
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(interaction),
    );
    _logResponse(response, endpoint);
    _handleError(response);
  }

  Future<List<Map<String, dynamic>>> getCustomers() async {
    const endpoint = '/customers';
    _logRequest('GET', endpoint);
    
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    _logResponse(response, endpoint);
    _handleError(response);
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      final error = 'API Error: ${response.statusCode} - ${response.body}';
      debugPrint('❌ $error');
      throw Exception(error);
    }
  }
}