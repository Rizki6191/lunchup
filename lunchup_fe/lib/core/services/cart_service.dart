import '../network/dio_client.dart';
import '../../models/cart_model.dart';

class CartService {
  /// GET CART
  static Future<List<CartItem>> getCart() async {
    final res = await DioClient.client.get('/cart');
    final data = res.data;

    if (data['success'] != true) {
      throw Exception('Gagal memuat keranjang');
    }

    // Handle both direct list and paginated structure
    print("CART RESPONSE: $data"); // Debugging
    List<dynamic> list = [];
    if (data['data'] is List) {
      list = data['data'];
    } else if (data['data'] is Map) {
      final inner = data['data'];
      if (inner['data'] is List) {
        list = inner['data'];
      } else if (inner['items'] is List) {
        list = inner['items'];
      } else if (inner['cart_items'] is List) {
        list = inner['cart_items'];
      } else {
        // Fallback: Check if any value is a list
        final values = inner.values.whereType<List>().toList();
        if (values.isNotEmpty) {
          list = values.first;
        } else {
          throw Exception(
            "Struktur JSON cart tidak dikenali. Keys: ${inner.keys.toList()}",
          );
        }
      }
    } else {
      throw Exception("Format data cart salah: ${data['data'].runtimeType}");
    }

    return list.map((e) => CartItem.fromJson(e)).toList();
  }

  /// ADD TO CART
  static Future<void> addToCart(int productId, int quantity) async {
    final res = await DioClient.client.post(
      '/cart?product_id=$productId&quantity=$quantity',
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal menambah ke keranjang');
    }
  }

  /// UPDATE CART ITEM
  static Future<void> updateCartItem(int id, int quantity) async {
    final res = await DioClient.client.put('/cart/$id?quantity=$quantity');

    if (res.statusCode != 200) {
      throw Exception('Gagal update keranjang');
    }
  }

  /// DELETE CART ITEM
  static Future<void> deleteCartItem(int id) async {
    final res = await DioClient.client.delete('/cart/$id');

    if (res.statusCode != 200) {
      throw Exception('Gagal menghapus item');
    }
  }

  /// CLEAR CART
  static Future<void> clearCart() async {
    // Calling delete without ID based on prompt "hapus semua yang ada di cart http://localhost:8000/api/cart"
    // Usually bulk delete uses DELETE /cart or similar.
    final res = await DioClient.client.delete('/cart');

    if (res.statusCode != 200) {
      throw Exception('Gagal mengosongkan keranjang');
    }
  }
}
