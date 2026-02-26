import 'package:flutter/material.dart';
import '../../core/storage/token_storage.dart';
// import '../../core/services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  Future<void> checkAuth() async {
    // Tambah delay biar ga terlalu kenceng (keren dikit)
    await Future.delayed(const Duration(seconds: 2));

    final token = await TokenStorage.getToken();
    final role = await TokenStorage.getRole();

    if (!mounted) return;

    if (token == null || role == null) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    switch (role) {
      case 'seller':
      case 'admin': // Tambah admin karena di login case-nya admin
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case 'user':
        Navigator.pushReplacementNamed(context, '/user');
        break;
      case 'jastiper':
        Navigator.pushReplacementNamed(context, '/jastiper');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
