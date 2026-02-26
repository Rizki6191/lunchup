class AdminDashboardModel {
  final int totalProducts;
  final int lowStock;
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final String revenueTotal;
  final String revenueNet;
  final List<RecentOrder> recentOrders;

  AdminDashboardModel({
    required this.totalProducts,
    required this.lowStock,
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.revenueTotal,
    required this.revenueNet,
    required this.recentOrders,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    final data = (json["data"] as Map<String, dynamic>?) ?? {};
    final stats = (data["stats"] as Map<String, dynamic>?) ?? {};
    final products = (stats["products"] as Map<String, dynamic>?) ?? {};
    final orders = (stats["orders"] as Map<String, dynamic>?) ?? {};
    final revenue = (stats["revenue"] as Map<String, dynamic>?) ?? {};
    final recent = (data["recent_orders"] as List?) ?? const [];

    return AdminDashboardModel(
      totalProducts: _toInt(products["total"]),
      lowStock: _toInt(products["low_stock"]),
      totalOrders: _toInt(orders["total"]),
      pendingOrders: _toInt(orders["pending"]),
      completedOrders: _toInt(orders["completed"]),
      revenueTotal: _toStringValue(revenue["total"]),
      revenueNet: _toStringValue(revenue["net"]),
      recentOrders: List<RecentOrder>.from(
        recent.map((x) => RecentOrder.fromJson((x as Map).cast<String, dynamic>())),
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _toStringValue(dynamic value) {
    if (value == null) return '0';
    return value.toString();
  }
}

class RecentOrder {
  final String code;
  final String username;
  final String total;
  final String status;

  RecentOrder({
    required this.code,
    required this.username,
    required this.total,
    required this.status,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    return RecentOrder(
      code: json["order_code"]?.toString() ?? '-',
      username: (json["user"] as Map<String, dynamic>?)?["username"]?.toString() ?? '-',
      total: json["total_amount"]?.toString() ?? '0',
      status: json["status"]?.toString() ?? '-',
    );
  }
}
