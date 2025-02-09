class KeyTopic {
  final String topic;
  final double confidence;

  KeyTopic({required this.topic, required this.confidence});

  factory KeyTopic.fromJson(Map<String, dynamic> json) {
    return KeyTopic(
      topic: json['topic'],
      confidence: json['confidence'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'topic': topic,
    'confidence': confidence,
  };
}

class ProductMatch {
  final String product;
  final double confidence;
  final List<String> reasons;
  final List<String> features;

  ProductMatch({
    required this.product,
    required this.confidence,
    required this.reasons,
    required this.features,
  });

  factory ProductMatch.fromJson(Map<String, dynamic> json) {
    return ProductMatch(
      product: json['product'],
      confidence: json['confidence'].toDouble(),
      reasons: List<String>.from(json['reasons']),
      features: List<String>.from(json['features']),
    );
  }

  Map<String, dynamic> toJson() => {
    'product': product,
    'confidence': confidence,
    'reasons': reasons,
    'features': features,
  };
}

class ConversationAnalysis {
  final List<String> summary;
  final List<KeyTopic> keyTopics;
  final List<String> keywords;
  final Map<String, dynamic> sentiment;
  final List<ProductMatch> productMatches;

  ConversationAnalysis({
    required this.summary,
    required this.keyTopics,
    required this.keywords,
    required this.sentiment,
    required this.productMatches,
  });

  factory ConversationAnalysis.fromJson(Map<String, dynamic> json) {
    return ConversationAnalysis(
      summary: List<String>.from(json['summary']),
      keyTopics: (json['keyTopics'] as List)
          .map((t) => KeyTopic.fromJson(t))
          .toList(),
      keywords: List<String>.from(json['keywords']),
      sentiment: json['sentiment'],
      productMatches: (json['productMatches'] as List)
          .map((p) => ProductMatch.fromJson(p))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'keyTopics': keyTopics.map((t) => t.toJson()).toList(),
      'keywords': keywords,
      'sentiment': sentiment,
      'productMatches': productMatches.map((p) => p.toJson()).toList(),
    };
  }
}