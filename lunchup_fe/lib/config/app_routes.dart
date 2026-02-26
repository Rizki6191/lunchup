import 'package:flutter/material.dart';

import '../features/splash/splash_page.dart';
import '../features/home/home_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/user/user_dashboard.dart';
import '../features/courier/jastiper_dashboard.dart';
import '../features/admin/menu_page.dart';
import '../features/admin/order_page.dart';
import '../features/admin/order_detail_page.dart';
import '../features/admin/profile_page.dart';

// User pages
import '../features/user/product_detail_page.dart';
import '../features/user/payment_page.dart';
import '../features/user/user_order_detail_page.dart';

// Jastiper pages
import '../features/courier/jastiper_order_detail_page.dart';

class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
  static const admin = '/admin';
  static const user = '/user';
  static const jastiper = '/jastiper';
  static const menu = '/menu';
  static const orders = '/orders';
  static const orderDetail = '/order-detail';
  static const profile = '/profile';

  // User specific routes
  static const userProductDetail = '/user-product-detail';
  static const userPayment = '/user-payment';
  static const userOrderDetail = '/user-order-detail';

  static const jastiperOrderDetail = '/jastiper-order-detail';

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashPage(),
    home: (_) => const HomePage(),
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    admin: (_) => const AdminDashboard(),
    menu: (_) => const MenuPage(),
    orders: (_) => const OrderPage(),
    orderDetail: (_) => const OrderDetailPage(),
    profile: (_) => const ProfilePage(),
    user: (_) => const UserDashboard(),
    jastiper: (_) => const JastiperDashboardPage(),
    jastiperOrderDetail: (_) => const JastiperOrderDetailPage(),

    // User routes
    userProductDetail: (_) => const ProductDetailPage(),
    userPayment: (_) => const PaymentPage(),
    userOrderDetail: (_) => const UserOrderDetailPage(),
  };
}
