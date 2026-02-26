class JastiperOrder {
  final int id;
  final String orderCode;
  final String totalAmount;
  final String status;
  final String deliveryAddress;
  final String? notes;
  final String? paymentMethod;
  final PaymentDetail? payment;

  JastiperOrder({
    required this.id,
    required this.orderCode,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    this.notes,
    this.paymentMethod,
    this.payment,
  });

  factory JastiperOrder.fromJson(Map<String, dynamic> json) {
    return JastiperOrder(
      id: json['id'] ?? 0,
      orderCode: json['order_code'] ?? '',
      totalAmount: json['total_amount']?.toString() ?? '0',
      status: json['status'] ?? 'pending',
      deliveryAddress: json['delivery_address'] ?? '',
      notes: json['notes'],
      paymentMethod: json['payment_method'],
      payment: json['payment'] != null
          ? PaymentDetail.fromJson(json['payment'])
          : null,
    );
  }
}

class PaymentDetail {
  final String metodePembayaran;
  final double totalYangHarusDibayar;
  final String totalFormatted;
  final String? instruksi;
  final String? qrImageUrl;
  final String? catatan;

  PaymentDetail({
    required this.metodePembayaran,
    required this.totalYangHarusDibayar,
    required this.totalFormatted,
    this.instruksi,
    this.qrImageUrl,
    this.catatan,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      metodePembayaran: json['metode_pembayaran'] ?? '',
      totalYangHarusDibayar:
          (json['total_yang_harus_dibayar'] as num?)?.toDouble() ?? 0.0,
      totalFormatted: json['total_yang_harus_dibayar_formatted'] ?? '',
      instruksi: json['instruksi'],
      qrImageUrl: json['qr_image_url'],
      catatan: json['catatan'],
    );
  }
}

class JastiperOrderDetail {
  final JastiperOrder order;
  final List<JastiperOrderItem> items;

  JastiperOrderDetail({required this.order, required this.items});

  factory JastiperOrderDetail.fromJson(Map<String, dynamic> json) {
    var itemList = json['items'] as List? ?? [];
    return JastiperOrderDetail(
      order: JastiperOrder.fromJson(json),
      items: itemList.map((i) => JastiperOrderItem.fromJson(i)).toList(),
    );
  }
}

class JastiperOrderItem {
  final String productName;
  final int quantity;
  JastiperOrderItem({required this.productName, required this.quantity});
  factory JastiperOrderItem.fromJson(Map<String, dynamic> json) {
    return JastiperOrderItem(
      productName:
          json['product'] != null ? json['product']['name'] : 'Product',
      quantity: json['quantity'] ?? 0,
    );
  }
}