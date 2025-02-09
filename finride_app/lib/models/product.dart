class FAQ {
  final String question;
  final String answer;

  FAQ({required this.question, required this.answer});

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      question: json['q'],
      answer: json['a'],
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double interestRate;
  final String quickPitch;
  final List<String> details;
  final List<FAQ> faq;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.interestRate,
    required this.quickPitch,
    required this.details,
    required this.faq,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      interestRate: json['interest_rate'].toDouble(),
      quickPitch: json['quick_pitch'] ?? '',
      details: List<String>.from(json['details'] ?? []),
      faq: (json['faq'] as List?)
          ?.map((f) => FAQ.fromJson(f))
          .toList() ?? [],
    );
  }
}