import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../core/services/order_service.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  OrderDetail? _order;
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_order == null && _loading) {
      final orderId = ModalRoute.of(context)!.settings.arguments as int;
      _load(orderId);
    }
  }

  Future<void> _load(int id) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await OrderService.getOrderDetail(id);
      setState(() {
        _order = detail;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'delivered':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _rupiah(String value) {
    return "Rp ${double.parse(value).toStringAsFixed(0)}";
  }

  String _formatDate(String? iso) {
    if (iso == null) return "-";
    final dt = DateTime.parse(iso);
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_order != null ? _order!.orderCode : "Detail Pesanan"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              "Gagal memuat detail",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final id = ModalRoute.of(context)!.settings.arguments as int;
                _load(id);
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Coba Lagi"),
            ),
          ],
        ),
      );
    }

    final o = _order!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// STATUS HEADER
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: _statusColor(o.status).withOpacity(.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                o.status.toUpperCase(),
                style: TextStyle(
                  color: _statusColor(o.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          /// ORDER INFO
          _sectionTitle("Informasi Pesanan"),
          _infoRow("Kode", o.orderCode),
          _infoRow("Total", _rupiah(o.totalAmount)),
          if (o.jastiperCommission != null)
            _infoRow("Komisi Jastiper", _rupiah(o.jastiperCommission!)),
          _infoRow("Alamat Pengiriman", o.deliveryAddress),
          if (o.notes != null && o.notes!.isNotEmpty)
            _infoRow("Catatan", o.notes!),
          const Divider(height: 28),

          /// TIMESTAMPS
          _sectionTitle("Waktu"),
          _infoRow("Dibuat", _formatDate(o.createdAt)),
          _infoRow("Diterima", _formatDate(o.acceptedAt)),
          _infoRow("Dikirim", _formatDate(o.deliveredAt)),
          _infoRow("Selesai", _formatDate(o.completedAt)),
          const Divider(height: 28),

          /// USER INFO
          _sectionTitle("Pemesan"),
          _infoRow("Username", o.user.username),
          if (o.user.email != null) _infoRow("Email", o.user.email!),
          if (o.user.role != null) _infoRow("Role", o.user.role!),
          const Divider(height: 28),

          /// JASTIPER INFO
          if (o.jastiper != null) ...[
            _sectionTitle("Jastiper"),
            _infoRow("Username", o.jastiper!.username),
            if (o.jastiper!.email != null)
              _infoRow("Email", o.jastiper!.email!),
            const Divider(height: 28),
          ],

          /// ORDER ITEMS
          _sectionTitle("Item Pesanan"),
          const SizedBox(height: 8),
          ...o.items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  /// Product image or placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: item.product.imageUrl != null
                        ? Image.network(
                            item.product.imageUrl!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.fastfood,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${item.quantity}x ${_rupiah(item.priceAtTime)}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _rupiah(item.subtotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
