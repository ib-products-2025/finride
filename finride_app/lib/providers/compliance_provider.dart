// lib/providers/compliance_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart';
import '../models/customer.dart';
import '../models/interaction.dart';

class ComplianceProvider extends ChangeNotifier {
  final ApiService _apiService;
  Map<String, dynamic>? _currentCheck;
  int? _selectedRideId;
  bool _isLoading = false;
  String? _error;

  ComplianceProvider(this._apiService);

  Map<String, dynamic>? get currentCheck => _currentCheck;
  int? get selectedRideId => _selectedRideId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void selectRide(int rideId) {
    _selectedRideId = rideId;
    notifyListeners();
  }

  Future<void> loadCurrentRideCompliance() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentCheck = await _apiService.getCompliance();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}