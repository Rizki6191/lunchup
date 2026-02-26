import 'package:flutter/material.dart';
import 'config/app_routes.dart';
// import 'core/storage/token_storage.dart';

void main() {
  runApp(const MyApp());
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await TokenStorage.clearAll(); // hapus token lama
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true, // debug masih wajar saat development
      title: 'LunchUp',
      theme: ThemeData(primarySwatch: Colors.orange),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
