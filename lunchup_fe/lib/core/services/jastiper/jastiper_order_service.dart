import 'package:dio/dio.dart';
import '../../network/dio_client.dart';
import '../../../models/jastiper_order_model.dart';
import '../../../models/jastiper_dashboard_model.dart';

class JastiperOrderService {
  static Future<List<JastiperOrder>> getAvailableOrders() async {
    final res = await DioClient.client.get('/jastiper/orders/available');
    return (res.data['data']['available_orders']['data'] as List)
        .map((e) => JastiperOrder.fromJson(e))
        .toList();
  }

  /// Pengiriman aktif: accepted, heading_to_canteen, heading_to_customer
  static Future<List<JastiperOrder>> getActiveOrders() async {
    final res = await DioClient.client.get('/jastiper/orders/active');
    return (res.data['data']['data'] as List)
        .map((e) => JastiperOrder.fromJson(e))
        .toList();
  }

  /// Riwayat pengiriman selesai
  static Future<List<JastiperOrder>> getDeliveryHistory() async {
    final res = await DioClient.client.get('/jastiper/delivery-history');
    final dynamic data = res.data['data'];

    // Support 2 shapes:
    // 1) { data: { history: { data: [...] } } }
    // 2) { data: { data: [...] } } (paginator langsung)
    final List rows =
        (data is Map && data['history'] is Map && data['history']['data'] is List)
        ? data['history']['data'] as List
        : (data is Map && data['data'] is List)
            ? data['data'] as List
            : <dynamic>[];

    // Jika endpoint mengembalikan DeliveryHistory rows, data order ada di key `order`.
    return rows
        .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
        .map((e) {
          final orderJson = e['order'];
          if (orderJson is Map<String, dynamic>) {
            return JastiperOrder.fromJson(orderJson);
          }
          return JastiperOrder.fromJson(e);
        })
        .toList();
  }

  static Future<JastiperOrderDetail> getOrderDetail(int id) async {
    final res = await DioClient.client.get('/orders/$id');
    return JastiperOrderDetail.fromJson(res.data['data']);
  }

  static Future<void> acceptOrder(int id) async =>
      await DioClient.client.post('/jastiper/orders/$id/accept');

  /// Update status: tidak perlu body — backend auto-advance ke tahap berikutnya
  /// accepted → heading_to_canteen → heading_to_customer
  static Future<JastiperOrder> updateStatus(int id) async {
    final res =
        await DioClient.client.put('/jastiper/orders/$id/status');
    return JastiperOrder.fromJson(res.data['data']);
  }

  static Future<Map<String, dynamic>> getEarnings() async {
    final res = await DioClient.client.get('/jastiper/earnings');
    return res.data['data']['summary'];
  }

  static Future<JastiperDashboard> getDashboard() async {
    try {
      final res = await DioClient.client.get('/dashboard');
      return JastiperDashboard.fromJson(res.data['data']);
    } on DioException catch (e) {
      throw Exception('Failed to load dashboard: ${e.message}');
    }
  }
}
