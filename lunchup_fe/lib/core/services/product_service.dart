import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../../models/product_model.dart';

class ProductService {
  /// GET ALL PRODUCTS (with auth token via DioClient interceptor)
  static Future<List<Product>> getProducts() async {
    final res = await DioClient.client.get('/products');

    final data = res.data;

    // Handle both { data: [...] } and { data: { data: [...] } } structures
    final List list;
    if (data['data'] is List) {
      list = data['data'];
    } else if (data['data'] is Map && data['data']['data'] is List) {
      list = data['data']['data'];
    } else {
      throw Exception('Unexpected API response format');
    }

    return list.map((e) => Product.fromJson(e)).toList();
  }

  /// ADD PRODUCT
  static Future<void> addProduct({
    required String name,
    required String description,
    required String price,
    required String stock,
    required String category,
    String? imagePath,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
    };

    if (imagePath != null && imagePath.isNotEmpty) {
      data['image_url'] = await MultipartFile.fromFile(imagePath);
    }

    final res = await DioClient.client.post(
      '/admin/products',
      data: FormData.fromMap(data),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal menambah produk');
    }
  }

  /// UPDATE PRODUCT
  static Future<void> updateProduct({
    required int id,
    required String name,
    required String description,
    required String price,
    required String stock,
    required String category,
    String? imagePath,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
    };

    if (imagePath != null && imagePath.isNotEmpty) {
      data['image_url'] = await MultipartFile.fromFile(imagePath);
    }

    final res = await DioClient.client.put(
      '/admin/products/$id',
      data: FormData.fromMap(data),
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengupdate produk');
    }
  }

  /// DELETE PRODUCT
  static Future<void> deleteProduct(int id) async {
    final res = await DioClient.client.delete('/admin/products/$id');

    if (res.statusCode != 200) {
      throw Exception('Gagal menghapus produk');
    }
  }

  /// GET PRODUCT DETAIL
  static Future<Product> getProduct(int id) async {
    final res = await DioClient.client.get('/products/$id');
    final data = res.data;

    if (data['success'] != true) {
      throw Exception('Gagal memuat produk');
    }

    return Product.fromJson(data['data']);
  }
}
