import 'package:flutter/material.dart';
import '../../core/services/admin_service.dart';
import '../../models/admin_dashboard_models.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<AdminDashboardModel> futureDashboard;

  @override
  void initState() {
    super.initState();
    futureDashboard = AdminService.getDashboard();
  }

  Color statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;
      case "completed":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String rupiah(String value) {
    return "Rp ${double.parse(value).toStringAsFixed(0)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<AdminDashboardModel>(
        future: futureDashboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                /// HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Admin Dashboard",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// STATS ROW 1
                      Row(
                        children: [
                          // _statCard(
                          //   "Total Produk",
                          //   data.totalProducts.toString(),
                          // ),
                          _statCard("Total Pesanan", data.totalOrders.toString()),
                          const SizedBox(width: 10),
                          _statCard("Omzet", rupiah(data.revenueNet)),
                          // const SizedBox(width: 10),
                          // _statCard("Low Stock", data.lowStock.toString()),
                        ],
                      ),
                      const SizedBox(height: 10),

                      /// STATS ROW 2
                      // Row(
                      //   children: [
                      //     _statCard("Orders", data.totalOrders.toString()),
                      //     const SizedBox(width: 10),
                      //     _statCard("Pending", data.pendingOrders.toString()),
                      //   ],
                      // ),
                      // const SizedBox(height: 10),

                      /// STATS ROW 3
                      // Row(
                      //   children: [
                      //     _statCard(
                      //       "Completed",
                      //       data.completedOrders.toString(),
                      //     ),
                      //     // const SizedBox(width: 10),
                      //     // _statCard("Omzet", rupiah(data.revenueNet)),
                      //   ],
                      // ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                /// MENU BUTTONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _menu(Icons.restaurant, "Menu", () {
                          Navigator.pushNamed(context, "/menu");
                        }),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _menu(Icons.receipt_long, "Pesanan", () {
                          Navigator.pushNamed(context, "/orders");
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// RECENT ORDERS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pesanan Terbaru",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...data.recentOrders.map((o) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// row username + code
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    o.username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    o.code,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              /// row total + status
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    rupiah(o.total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor(
                                        o.status,
                                      ).withOpacity(.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      o.status.toUpperCase(),
                                      style: TextStyle(
                                        color: statusColor(o.status),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      /// BOTTOM BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        backgroundColor: Colors.orange,
        onTap: (i) {
          if (i == 1) Navigator.pushNamed(context, "/menu");
          if (i == 2) Navigator.pushNamed(context, "/profile");
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: "Menu",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  static Widget _statCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _menu extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _menu(this.icon, this.title, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            const SizedBox(height: 6),
            Text(title),
          ],
        ),
      ),
    );
  }
}
