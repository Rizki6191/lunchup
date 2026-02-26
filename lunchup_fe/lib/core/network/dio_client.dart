import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import '../../config/api_config.dart';

class DioClient {
  static final Dio client =
      Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await TokenStorage.getToken();
              if (token != null) {
                print(
                  "DIO REQUEST: ${options.uri} with TOKEN: ${token.substring(0, 5)}...",
                );
                options.headers["Authorization"] = "Bearer $token";
              } else {
                print("DIO REQUEST: ${options.uri} WITHOUT TOKEN");
              }
              return handler.next(options);
            },
            onError: (DioException e, handler) {
              print(
                "DIO ERROR: ${e.message} ${e.response?.statusCode} ${e.response?.data}",
              );
              return handler.next(e);
            },
          ),
        );
}
