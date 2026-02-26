import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../../models/order_model.dart';

class UserOrderService {
  /// GET MY ORDERS
  static Future<Map<String, dynamic>> getMyOrders({int page = 1}) async {
    final res = await DioClient.client.get('/orders/my-orders?page=$page');
    final data = res.data;

    if (data['success'] != true) {
      throw Exception('Gagal memuat pesanan saya');
    }

    final paginatedData = data['data'];
    final List<Order> orders = (paginatedData['data'] as List)
        .map((e) => Order.fromJson(e))
        .toList();

    return {
      'orders': orders,
      'currentPage': paginatedData['current_page'],
      'lastPage': paginatedData['last_page'],
      'total': paginatedData['total'],
    };
  }

  /// GET ORDER DETAIL
  static Future<OrderDetail> getOrderDetail(int id) async {
    try {
      final res = await DioClient.client.get('/orders/$id');
      final data = res.data;

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Gagal memuat detail pesanan');
      }

      return OrderDetail.fromJson(data['data']);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Gagal memuat detail pesanan',
      );
    }
  }

  /// CHECKOUT
  static Future<void> checkout({
    required String deliveryAddress,
    required String paymentMethod, // Parameter wajib
    required String notes,
  }) async {
    try {
      final res = await DioClient.client.post(
        '/orders/checkout',
        data: {
          'delivery_address': deliveryAddress,
          'payment_method': paymentMethod,
          'notes': notes,
        },
      );

      if (res.data['success'] != true) {
        throw Exception(res.data['message'] ?? 'Checkout gagal');
      }
    } on DioException catch (e) {
      print("CHECKOUT ERROR: ${e.response?.data}");
      final errorMsg = e.response?.data['message'] ?? 'Checkout gagal';
      throw Exception(errorMsg);
    }
  }

  /// CONFIRM ORDER
  static Future<void> confirmReceived(int orderId) async {
    try {
      final res = await DioClient.client.post('/orders/$orderId/confirm');
      if (res.data['success'] != true) {
        throw Exception(res.data['message'] ?? 'Gagal konfirmasi');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal konfirmasi');
    }
  }
}
