class BusinessInsights {
  final String segment;
  final int age;
  final double aum;
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
      segment: json['segment'] ?? 'Unknown',
      age: json['age'] ?? 0,
      aum: (json['aum'] ?? 0).toDouble(),
      industry: json['industry'] ?? 'Unknown',
      status: json['status'] ?? 'Unknown',
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