class BusinessInsights {
  final String segment;  // Business Owner, Household or Payroll
  final int age;
  final double aum;  // in VND billions
  final String industry;
  final String status;

  BusinessInsights({
    required this.segment,
    required this.age,
    required this.aum,
    required this.industry,
    required this.status,
  });

  factory BusinessInsights.fromJson(Map<String, dynamic> json) {
    return BusinessInsights(
      segment: json['segment'],
      age: json['age'],
      aum: json['aum'].toDouble(),
      industry: json['industry'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'segment': segment,
    'age': age,
    'aum': aum,
    'industry': industry,
    'status': status,
  };
}