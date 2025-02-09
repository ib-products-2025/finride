class AccountDetails {
  final List<String> products;
  final int balance;
  final int loanAmount;

  const AccountDetails({
    required this.products, 
    required this.balance,
    required this.loanAmount,
  });

  factory AccountDetails.fromJson(Map<String, dynamic> json) {
    return AccountDetails(
      products: List<String>.from(json['products']),
      balance: json['balance'],
      loanAmount: json['loan_amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'products': products,
    'balance': balance,
    'loan_amount': loanAmount,
  };
}