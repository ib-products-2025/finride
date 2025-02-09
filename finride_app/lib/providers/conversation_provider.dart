import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/conversation_analysis.dart';
import '../models/ride_interaction.dart';

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
      _interactions = data.map((i) {
        debugPrint('Parsing Interaction: $i');
        return RideInteraction.fromJson(i);
      }).toList();

      debugPrint('Parsed Interactions: ${_interactions.length}');
      _error = null;
    } catch (e) {
      debugPrint('Error loading interactions: $e');
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