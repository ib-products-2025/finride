import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/conversation_analysis.dart';
import '../models/ride_interaction.dart';
import 'dart:developer' as dev;

class ConversationProvider extends ChangeNotifier {
  final ApiService _apiService;
  RideInteraction? _currentInteraction;
  List<RideInteraction> _interactions = [];
  bool _isLoading = false;
  String? _error;

  ConversationProvider(this._apiService);

  RideInteraction? get currentInteraction => _currentInteraction;
  List<RideInteraction> get interactions => _interactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadInteractions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.getInteractions();
      
      // Log raw interaction data
      dev.log(
        'Raw Interaction Data: $data', 
        name: 'ConversationProvider.loadInteractions'
      );

      _interactions = data.map((i) {
        // Log individual interaction parsing
        dev.log(
          'Parsing Interaction: $i', 
          name: 'ConversationProvider.loadInteractions'
        );
        return RideInteraction.fromJson(i);
      }).toList();

      // Log parsed interactions
      dev.log(
        'Parsed Interactions: ${_interactions.length}', 
        name: 'ConversationProvider.loadInteractions'
      );

      _error = null;
    } catch (e) {
      dev.log(
        'Error loading interactions: $e', 
        name: 'ConversationProvider.loadInteractions',
        error: e
      );
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startNewRide(Map<String, dynamic> rideData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _apiService.createInteraction(rideData);
      _currentInteraction = RideInteraction.fromJson(data);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveAnalysis(int rideId, ConversationAnalysis analysis) async {
    try {
      await _apiService.saveAnalysis(rideId, analysis.toJson());
      await loadInteractions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}