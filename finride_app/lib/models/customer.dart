import 'business_insights.dart';
import 'conversation_analysis.dart';
import 'next_step.dart';

class Customer {
  final String phoneNumber;
  final String name;
  final BusinessInsights businessInsights;
  final List<String> financialGoals;
  final List<ProductMatch>? nbo;
  final List<NextStep>? nba;

  const Customer({
    required this.phoneNumber,
    required this.name,
    required this.businessInsights,
    required this.financialGoals,
    this.nbo,
    this.nba,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      phoneNumber: json['phone_number'] ?? '',
      name: json['name'] ?? 'Unknown',
      businessInsights: json['businessInsights'] != null 
          ? BusinessInsights.fromJson(json['businessInsights'])
          : BusinessInsights(
              segment: 'Unknown',
              age: 0,
              aum: 0.0,
              industry: 'Unknown',
              status: 'medium'
            ),
      financialGoals: json['financialGoals'] != null 
          ? List<String>.from(json['financialGoals'])
          : [],
      nbo: json['nbo'] != null
          ? (json['nbo'] as List).map((p) => ProductMatch.fromJson(p)).toList()
          : [],
      nba: json['nba'] != null
          ? (json['nba'] as List).map((n) => NextStep.fromJson(n)).toList()
          : []
    );
  }

  Map<String, dynamic> toJson() => {
    'phone_number': phoneNumber,
    'name': name,
    'businessInsights': businessInsights.toJson(),
    'financialGoals': financialGoals,
    'nbo': nbo?.map((p) => p.toJson()).toList(),
    'nba': nba?.map((n) => n.toJson()).toList()
  };

  factory Customer.empty() => Customer(
    phoneNumber: '',
    name: 'Unknown',
    businessInsights: BusinessInsights(
      segment: 'Unknown',
      age: 0,
      aum: 0.0,
      industry: 'Unknown',
      status: 'medium'
    ),
    financialGoals: const [],
  );
}