import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AreaPrompt {
  final String area;
  final List<String> prompts;

  AreaPrompt({required this.area, required this.prompts});
}

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService;
  Map<String, dynamic>? _stats;
  List<AreaPrompt> _areaPrompts = [];
  List<String> _insights = [];
  bool _isLoading = false;
  String? _error;

  DashboardProvider(this._apiService) {
    loadDashboardData();
  }

  Map<String, dynamic>? get stats => _stats;
  List<AreaPrompt> get areaPrompts => _areaPrompts;
  List<String> get insights => _insights;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Map<String, dynamic>> get sentimentData => [
    {'positive': 75, 'neutral': 20, 'negative': 5}
  ];

  List<Map<String, dynamic>> get productRecommendations => [
    {'name': 'Business Loan', 'matches': 28, 'confidence': 85}
  ];

  List<Map<String, dynamic>> get topTriggerWords => [
    {'word': 'expansion', 'count': 15},
    {'word': 'savings', 'count': 12}
  ];

  List<Map<String, dynamic>> get customerSegments => [
    {'segment': 'Small Business', 'percentage': 45}
  ];

  Map<String, dynamic> get metrics => {
    'totalConversations': {'value': 42, 'trend': 15},
    'avgSentiment': {'value': 8.5, 'trend': 0.5}
  };

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final dashboardData = await _apiService.getDashboardAnalytics();
      _stats = dashboardData['conversationMetrics'];
      
      _areaPrompts = [
        AreaPrompt(
          area: 'Business District',
          prompts: ['Mention expansion', 'Mention savings'],
        ),
      ];

      _insights = [
        'Hot product: Business Loan (85% match)',
      ];

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }
}