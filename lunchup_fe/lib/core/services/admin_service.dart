import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../storage/token_storage.dart';
import '../../models/admin_dashboard_models.dart';

class AdminService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    headers: {"Accept": "application/json"},
  ));

  static Future<AdminDashboardModel> getDashboard() async {
    final token = await TokenStorage.getToken();

    final res = await _dio.get(
      "/admin/dashboard",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return AdminDashboardModel.fromJson(res.data);
  }
}
