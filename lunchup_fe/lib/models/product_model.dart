import '../config/api_config.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final String price;
  final int stock;
  final String category;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final imageValue = json["image_url"] ?? json["image"];

    return Product(
      id: json["id"] is int ? json["id"] : int.parse(json["id"].toString()),
      name: json["name"] ?? '',
      description: json["description"] ?? '',
      price: json["price"]?.toString() ?? '0',
      stock: json["stock"] is int
          ? json["stock"]
          : int.tryParse(json["stock"]?.toString() ?? '0') ?? 0,
      category: json["category"] ?? '',
      imageUrl: _normalizeImageUrl(imageValue?.toString()),
    );
  }

  static String? _normalizeImageUrl(String? raw) {
    if (raw == null) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      final uri = Uri.tryParse(value);
      final apiUri = Uri.tryParse(ApiConfig.baseUrl);
      if (uri != null &&
          apiUri != null &&
          (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
        return uri.replace(
          scheme: apiUri.scheme,
          host: apiUri.host,
          port: apiUri.hasPort ? apiUri.port : uri.port,
        ).toString();
      }
      return value;
    }

    final apiBase = ApiConfig.baseUrl;
    final origin = apiBase.endsWith('/api')
        ? apiBase.substring(0, apiBase.length - 4)
        : apiBase;

    if (value.startsWith('/storage/')) {
      return '$origin$value';
    }
    if (value.startsWith('storage/')) {
      return '$origin/$value';
    }
    if (value.startsWith('/')) {
      return '$origin$value';
    }
    return '$origin/storage/$value';
  }
}
