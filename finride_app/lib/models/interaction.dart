import 'customer.dart';
import 'conversation_analysis.dart';

class Interaction {
  final String date;
  final String note;
  final Customer? customer;
  final ConversationAnalysis? conversationAnalysis;

  Interaction({
    required this.date, 
    required this.note, 
    this.customer, 
    this.conversationAnalysis
  });

  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      date: json['date'],
      note: json['note'],
      customer: json['customer'] != null 
          ? Customer.fromJson(json['customer']) 
          : null,
      conversationAnalysis: json['conversationAnalysis'] != null
          ? ConversationAnalysis.fromJson(json['conversationAnalysis'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'note': note,
    'customer': customer?.toJson(),
    'conversationAnalysis': conversationAnalysis?.toJson(),
  };
}