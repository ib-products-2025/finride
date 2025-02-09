// lib/providers/analytics_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart';
import '../models/customer.dart';
import '../models/interaction.dart';

class AnalyticsProvider extends ChangeNotifier {
  final ApiService _apiService;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  String? _error;

  AnalyticsProvider(this._apiService);

  Map<String, dynamic>? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dashboardData = await _apiService.getDashboardAnalytics();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}