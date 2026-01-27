class Wallet {
  final String userId;
  final double balance;
  final List<Map<String, dynamic>> transactionHistory;

  Wallet({
    required this.userId,
    required this.balance,
    required this.transactionHistory,
  });

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      userId: map['user_id'],
      balance: map['balance'],
      transactionHistory: List<Map<String, dynamic>>.from(map['transaction_history']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'balance': balance,
      'transaction_history': transactionHistory,
    };
  }
}
