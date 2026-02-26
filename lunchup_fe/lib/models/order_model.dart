class Order {
  final int id;
  final String orderCode;
  final int userId;
  final int? jastiperId;
  final String totalAmount;
  final String status;
  final String deliveryAddress;
  final String? notes;
  final String? jastiperCommission;
  final String? acceptedAt;
  final String? deliveredAt;
  final String? completedAt;
  final String createdAt;
  final String updatedAt;
  final OrderUser? user;
  final OrderUser? jastiper;

  Order({
    required this.id,
    required this.orderCode,
    required this.userId,
    this.jastiperId,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    this.notes,
    this.jastiperCommission,
    this.acceptedAt,
    this.deliveredAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.jastiper,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderCode: json['order_code'],
      userId: json['user_id'],
      jastiperId: json['jastiper_id'],
      totalAmount: json['total_amount'],
      status: json['status'],
      deliveryAddress: json['delivery_address'] ?? '',
      notes: json['notes'],
      jastiperCommission: json['jastiper_commission'],
      acceptedAt: json['accepted_at'],
      deliveredAt: json['delivered_at'],
      completedAt: json['completed_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? OrderUser.fromJson(json['user']) : null,
      jastiper: json['jastiper'] != null
          ? OrderUser.fromJson(json['jastiper'])
          : null,
    );
  }
}

class OrderUser {
  final int id;
  final String username;
  final String? email;
  final String? role;

  OrderUser({required this.id, required this.username, this.email, this.role});

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }
}

class OrderDetail {
  final int id;
  final String orderCode;
  final String totalAmount;
  final String status;
  final String deliveryAddress;
  final String? notes;
  final String? jastiperCommission;
  final String? acceptedAt;
  final String? deliveredAt;
  final String? completedAt;
  final String createdAt;
  final List<OrderItem> items;
  final OrderUser user;
  final OrderUser? jastiper;

  OrderDetail({
    required this.id,
    required this.orderCode,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    this.notes,
    this.jastiperCommission,
    this.acceptedAt,
    this.deliveredAt,
    this.completedAt,
    required this.createdAt,
    required this.items,
    required this.user,
    this.jastiper,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      orderCode: json['order_code'],
      totalAmount: json['total_amount'],
      status: json['status'],
      deliveryAddress: json['delivery_address'] ?? '',
      notes: json['notes'],
      jastiperCommission: json['jastiper_commission'],
      acceptedAt: json['accepted_at'],
      deliveredAt: json['delivered_at'],
      completedAt: json['completed_at'],
      createdAt: json['created_at'],
      items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
      user: OrderUser.fromJson(json['user']),
      jastiper: json['jastiper'] != null
          ? OrderUser.fromJson(json['jastiper'])
          : null,
    );
  }
}

class OrderItem {
  final int id;
  final int quantity;
  final String priceAtTime;
  final String subtotal;
  final OrderProduct product;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.priceAtTime,
    required this.subtotal,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      quantity: json['quantity'],
      priceAtTime: json['price_at_time'],
      subtotal: json['subtotal'],
      product: OrderProduct.fromJson(json['product']),
    );
  }
}

class OrderProduct {
  final int id;
  final String name;
  final String description;
  final String price;
  final String? imageUrl;

  OrderProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: json['price'],
      imageUrl: json['image_url'],
    );
  }
}
