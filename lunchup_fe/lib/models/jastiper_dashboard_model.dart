class JastiperDashboard {
  final int userId;
  final String username;
  final int availableOrders;
  final int activeDeliveries;
  final double totalEarnings;
  final double totalCompletedAmount;

  JastiperDashboard({
    required this.userId,
    required this.username,
    required this.availableOrders,
    required this.activeDeliveries,
    required this.totalEarnings,
    required this.totalCompletedAmount,
  });

  factory JastiperDashboard.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return JastiperDashboard(
      userId: _toInt(user['id']),
      username: user['username'] ?? '',
      availableOrders: _toInt(json['available_orders']),
      activeDeliveries: _toInt(json['active_deliveries']),
      totalEarnings: _toDouble(json['total_earnings']),
      totalCompletedAmount: _toDouble(json['total_completed_amount']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
