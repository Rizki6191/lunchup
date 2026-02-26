import '../network/dio_client.dart';
import '../../models/profile_model.dart';

class ProfileService {
  /// GET PROFILE
  static Future<Profile> getProfile() async {
    final res = await DioClient.client.get('/profile');
    final data = res.data;

    if (data['success'] != true) {
      throw Exception('Gagal memuat profil');
    }

    return Profile.fromJson(data['data']);
  }

  /// UPDATE PROFILE
  static Future<void> updateProfile({
    String? username,
    String? email,
    String? currentPassword,
    String? password,
  }) async {
    final body = <String, dynamic>{};
    if (username != null && username.isNotEmpty) body['username'] = username;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (currentPassword != null && currentPassword.isNotEmpty) {
      body['current_password'] = currentPassword;
    }
    if (password != null && password.isNotEmpty) body['password'] = password;

    final res = await DioClient.client.put('/profile', data: body);

    if (res.statusCode != 200) {
      throw Exception('Gagal mengupdate profil');
    }
  }
}
