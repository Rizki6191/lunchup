class Profile {
  final int id;
  final String username;
  final String email;
  final String role;
  final int productsCreated;
  final String createdAt;
  final String updatedAt;

  Profile({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.productsCreated,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      productsCreated: json['products_created'] ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
