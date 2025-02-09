import 'customer.dart';
import 'conversation_analysis.dart';
import 'next_step.dart';

class RideInteraction {
 final int id;
 final Customer customer;
 final String timestamp;
 final String date;
 final String platform;
 final bool analysisComplete;
 final ConversationAnalysis? conversationAnalysis;
 final List<NextStep> nextSteps;

 const RideInteraction({
   required this.id,
   required this.customer,
   required this.timestamp,
   required this.date,
   required this.platform,
   this.analysisComplete = false,
   this.conversationAnalysis,
   this.nextSteps = const [],
 });

 factory RideInteraction.fromJson(Map<String, dynamic> json) {
   try {
     final customerData = json['customer'];
     if (customerData == null) {
       print('Customer data is null');
       return RideInteraction(
         id: json['id'] ?? 0,
         customer: Customer.empty(),
         timestamp: json['timestamp'] ?? '',
         date: json['date'] ?? '',
         platform: json['platform'] ?? '',
         analysisComplete: json['analysisComplete'] ?? false,
         nextSteps: [],
       );
     }

     print('Parsing customer data: $customerData');
     final customer = Customer.fromJson(customerData);

     return RideInteraction(
       id: json['id'] ?? 0,
       customer: customer,
       timestamp: json['timestamp'] ?? '',
       date: json['date'] ?? '',
       platform: json['platform'] ?? '',
       analysisComplete: json['analysisComplete'] ?? false,
       conversationAnalysis: json['conversationAnalysis'] != null
           ? ConversationAnalysis.fromJson(json['conversationAnalysis'])
           : null,
       nextSteps: json['nextSteps'] != null
           ? (json['nextSteps'] as List).map((s) => NextStep.fromJson(s)).toList()
           : [],
     );
   } catch (e, stackTrace) {
     print('Error parsing interaction: $e');
     print(stackTrace);
     rethrow;
   }
 }

 Map<String, dynamic> toJson() => {
   'id': id,
   'customer': customer.toJson(),
   'timestamp': timestamp,
   'date': date,
   'platform': platform,
   'analysisComplete': analysisComplete,
   'conversationAnalysis': conversationAnalysis?.toJson(),
   'nextSteps': nextSteps.map((s) => s.toJson()).toList(),
 };
}