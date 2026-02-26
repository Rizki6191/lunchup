import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../core/services/user_order_service.dart';

class UserOrderDetailPage extends StatefulWidget {
  const UserOrderDetailPage({super.key});

  @override
  State<UserOrderDetailPage> createState() => _UserOrderDetailPageState();
}

class _UserOrderDetailPageState extends State<UserOrderDetailPage> {
  OrderDetail? _order;
  bool _loading = true;
  bool _confirming = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_order == null && _loading) {
      final orderId = ModalRoute.of(context)!.settings.arguments as int;
      _load(orderId);
    }
  }

  Future<void> _confirmOrder() async {
    if (_order == null) return;
    setState(() => _confirming = true);
    try {
      await UserOrderService.confirmReceived(_order!.id);
      await _load(_order!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pesanan berhasil dikonfirmasi")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal konfirmasi: $e")),
      );
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Future<void> _load(int id) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await UserOrderService.getOrderDetail(id);
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
      case 'heading_to_canteen':
        return Colors.deepPurple;
      case 'heading_to_customer':
        return Colors.indigo;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_order?.orderCode ?? "Detail Pesanan")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text("Error: $_error"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(_order!.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        _order!.status.toUpperCase(),
                        style: TextStyle(
                          color: _statusColor(_order!.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// ITEMS
                  const Text(
                    "Item Pesanan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ..._order!.items.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.shade200,
                            child: item.product.imageUrl != null
                                ? Image.network(
                                    item.product.imageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.fastfood,
                                    color: Colors.grey,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "${item.quantity}x ${item.product.name}",
                            ),
                          ),
                          Text(
                            "Rp ${double.parse(item.subtotal).toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 32),

                  /// INFO
                  _row(
                    "Total Harga",
                    "Rp ${double.parse(_order!.totalAmount).toStringAsFixed(0)}",
                    isBold: true,
                  ),
                  const SizedBox(height: 8),
                  _row("Tanggal", _order!.createdAt),
                  const SizedBox(height: 8),
                  _row("Alamat", _order!.deliveryAddress),
                  const SizedBox(height: 8),
                  if (_order!.notes != null) _row("Catatan", _order!.notes!),

                  const SizedBox(height: 24),
                  if (_order!.jastiper != null) ...[
                    const Text(
                      "Jastiper",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_order!.jastiper!.username),
                    Text(_order!.jastiper!.email ?? "-"),
                  ],
                  if (_order!.status == 'heading_to_customer') ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirming ? null : _confirmOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _confirming
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("ACC Pesanan Diterima"),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
