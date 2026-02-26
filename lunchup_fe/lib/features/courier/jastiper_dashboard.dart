import 'package:flutter/material.dart';
import '../../core/services/jastiper/jastiper_order_service.dart';
import '../../core/services/profile_service.dart'; // Import service profil
import '../../models/jastiper_order_model.dart';
import '../../models/jastiper_dashboard_model.dart';
import '../../models/profile_model.dart'; // Import model profil
import '../../config/app_routes.dart';

class JastiperDashboardPage extends StatefulWidget {
  const JastiperDashboardPage({super.key});

  @override
  State<JastiperDashboardPage> createState() => _JastiperDashboardPageState();
}

class _JastiperDashboardPageState extends State<JastiperDashboardPage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const TabTersedia(),
    const TabHistory(),
    const TabProfilJastiper(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFFFF9933),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: "Requests"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// --- TAB REQUESTS ---
class TabTersedia extends StatefulWidget {
  const TabTersedia({super.key});
  @override
  State<TabTersedia> createState() => _TabTersediaState();
}

class _TabTersediaState extends State<TabTersedia> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Pesanan Tersedia", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<JastiperOrder>>(
        future: JastiperOrderService.getAvailableOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF9933)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada pesanan tersedia"));
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, i) => _JastiperOrderCard(order: snapshot.data![i]),
            ),
          );
        },
      ),
    );
  }
}

// --- TAB HISTORY ---
class TabHistory extends StatefulWidget {
  const TabHistory({super.key});

  @override
  State<TabHistory> createState() => _TabHistoryState();
}

class _TabHistoryState extends State<TabHistory> {
  late Future<List<JastiperOrder>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = JastiperOrderService.getDeliveryHistory();
  }

  Future<void> _refresh() async {
    setState(() {
      _historyFuture = JastiperOrderService.getDeliveryHistory();
    });
    await _historyFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Riwayat Pengiriman", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<JastiperOrder>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Gagal memuat riwayat: ${snapshot.error}"),
              ),
            );
          }
          if (snapshot.data!.isEmpty) return const Center(child: Text("Belum ada riwayat"));

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, i) {
                final o = snapshot.data![i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF5F5F5),
                      child: Icon(Icons.check_circle, color: Colors.green),
                    ),
                    title: Text(o.orderCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(o.status.toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.orange)),
                    trailing: Text("Rp ${o.totalAmount}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// --- TAB PROFILE (INTEGRATED WITH PROFILE SERVICE) ---
class TabProfilJastiper extends StatefulWidget {
  const TabProfilJastiper({super.key});

  @override
  State<TabProfilJastiper> createState() => _TabProfilJastiperState();
}

class _TabProfilJastiperState extends State<TabProfilJastiper> {
  late Future<List<dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = Future.wait([
      ProfileService.getProfile(),
      JastiperOrderService.getDashboard(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<List<dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF9933)));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Gagal memuat profil: ${snapshot.error}"),
              ),
            );
          }

          final Profile profile = snapshot.data![0];
          final JastiperDashboard dash = snapshot.data![1];

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF9933),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 50, color: Color(0xFFFF9933)),
                      ),
                      const SizedBox(height: 15),
                      Text(profile.username.toUpperCase(), 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(profile.email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 20),
                      const Text("TOTAL PENDAPATAN", style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.1)),
                      Text("Rp ${dash.totalEarnings.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildProfileTile(Icons.shopping_bag_outlined, "Pesanan Tersedia", "${dash.availableOrders}"),
                      _buildProfileTile(Icons.delivery_dining, "Pengiriman Aktif", "${dash.activeDeliveries}"),
                      _buildProfileTile(Icons.star_outline, "Rating Jastiper", "5.0"),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                        child: const Text("Log out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF9933)),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}

// --- REUSABLE CARD ---
class _JastiperOrderCard extends StatelessWidget {
  final JastiperOrder order;
  const _JastiperOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.jastiperOrderDetail, arguments: order.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFF9933).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(order.orderCode, style: const TextStyle(color: Color(0xFFFF9933), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  Text("Rp ${order.totalAmount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              const Text("ALAMAT PENGIRIMAN", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(order.deliveryAddress, style: const TextStyle(fontSize: 14, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
              const Divider(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Lihat Detail", style: TextStyle(color: Color(0xFFFF9933), fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 14, color: Color(0xFFFF9933)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
