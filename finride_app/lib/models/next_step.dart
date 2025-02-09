class NextStep {
  final String action;
  final String priority;
  final String deadline;
  final String status;

  NextStep({
    required this.action,
    required this.priority,
    required this.deadline,
    required this.status,
  });

  factory NextStep.fromJson(Map<String, dynamic> json) {
    return NextStep(
      action: json['action'] ?? '',
      priority: json['priority'] ?? '',
      deadline: json['deadline'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'action': action,
    'priority': priority,
    'deadline': deadline,
    'status': status,
  };
}