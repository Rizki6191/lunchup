import 'package:flutter/material.dart';
import '../../core/services/jastiper/jastiper_order_service.dart';
import '../../models/jastiper_order_model.dart';

class JastiperOrderDetailPage extends StatefulWidget {
  const JastiperOrderDetailPage({super.key});

  @override
  State<JastiperOrderDetailPage> createState() => _JastiperOrderDetailPageState();
}

class _JastiperOrderDetailPageState extends State<JastiperOrderDetailPage> {
  JastiperOrderDetail? _detail;
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  int? _orderId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_orderId != null) return;
    _orderId = ModalRoute.of(context)!.settings.arguments as int;
    _fetch();
  }

  Future<void> _fetch() async {
    if (_orderId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await JastiperOrderService.getOrderDetail(_orderId!);
      if (!mounted) return;
      setState(() {
        _detail = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _acceptOrder() async {
    final order = _detail?.order;
    if (order == null) return;

    setState(() => _submitting = true);
    try {
      await JastiperOrderService.acceptOrder(order.id);
      await _fetch();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal accept order: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _advanceStatus() async {
    final order = _detail?.order;
    if (order == null) return;

    setState(() => _submitting = true);
    try {
      await JastiperOrderService.updateStatus(order.id);
      await _fetch();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update status: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  bool _canAdvanceStatus(String status) =>
      status == 'accepted' || status == 'heading_to_canteen';

  String _advanceButtonText(String status) {
    if (status == 'accepted') return 'Menuju Kantin';
    if (status == 'heading_to_canteen') return 'Menuju Customer';
    return 'Update Status';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Order')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_error ?? 'Data order tidak ditemukan'),
          ),
        ),
      );
    }

    final order = _detail!.order;

    return Scaffold(
      appBar: AppBar(title: Text(order.orderCode)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              order.deliveryAddress,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Status: ${order.status}'),
            const Divider(height: 32),
            const Text(
              'Order Items',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _detail!.items.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(_detail!.items[i].productName),
                  trailing: Text('${_detail!.items[i].quantity}x'),
                ),
              ),
            ),
            if (order.payment != null) ...[
              const Divider(height: 16),
              Text('Pembayaran: ${order.payment!.metodePembayaran}'),
              Text(order.payment!.totalFormatted),
              if (order.payment!.instruksi != null) Text(order.payment!.instruksi!),
              if (order.payment!.catatan != null) Text(order.payment!.catatan!),
              if (order.payment!.qrImageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Image.network(
                    order.payment!.qrImageUrl!,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
            ],
            const SizedBox(height: 20),
            if (order.status == 'pending')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: _submitting ? null : _acceptOrder,
                  child: _submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Accept Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )
            else if (_canAdvanceStatus(order.status))
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  onPressed: _submitting ? null : _advanceStatus,
                  child: _submitting
                      ? const CircularProgressIndicator()
                      : Text(
                          _advanceButtonText(order.status),
                          style: const TextStyle(color: Colors.black87),
                        ),
                ),
              )
            else
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'Menunggu konfirmasi buyer untuk menyelesaikan order.',
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
