import '../network/dio_client.dart';
import '../../models/order_model.dart';

class OrderService {
  /// GET ALL ORDERS (paginated)
  static Future<Map<String, dynamic>> getOrders({int page = 1}) async {
    final res = await DioClient.client.get('/admin/orders?page=$page');
    final data = res.data;

    if (data['success'] != true) {
      throw Exception('Gagal memuat pesanan');
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
    final res = await DioClient.client.get('/admin/orders/$id');
    final data = res.data;

    if (data['success'] != true) {
      throw Exception('Gagal memuat detail pesanan');
    }

    return OrderDetail.fromJson(data['data']);
  }
}
