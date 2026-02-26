import '../network/dio_client.dart';
import '../storage/token_storage.dart';

class AuthService {
  /// REGISTER + AUTO LOGIN
  static Future<String> register({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    await DioClient.client.post(
      '/auth/register',
      data: {
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      },
    );

    return await login(email: email, password: password);
  }

  /// LOGIN
  static Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await DioClient.client.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final data = response.data;

    final token = data['token'];
    final role = data['user']['role'];

    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    await TokenStorage.saveToken(token);
    await TokenStorage.saveRole(role);
    return role;
  }

  /// LOGOUT
  static Future<void> logout() async {
    try {
      await DioClient.client.post('/auth/logout');
    } catch (_) {
      // Ignore API errors (e.g. 401) and force clear local storage
    }
    await TokenStorage.clearAll();
  }

  /// GET ROLE (dipakai splash)
  static Future<String> getRole() async {
    final response = await DioClient.client.get('/profile');

    final body = response.data;

    if (body["success"] != true) {
      throw Exception("Get role gagal");
    }

    return body["data"]["role"];
  }
}
