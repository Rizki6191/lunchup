import 'package:flutter/material.dart';
import '../../models/cart_model.dart';
import '../../core/services/cart_service.dart';
import '../../core/services/user_order_service.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<CartItem> _items = [];
  bool _loading = true;
  String? _error;

  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _selectedPayment = 'cash'; 
  bool _processing = false;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await CartService.getCart();
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  double get _total {
    return _items.fold(
      0,
      (sum, i) => sum + (double.parse(i.product.price) * i.quantity),
    );
  }

  /// DIALOG INSTRUKSI (QRIS / CASH)
  void _showInstructionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _selectedPayment == 'qris' ? "Pembayaran QRIS" : "Pembayaran Tunai",
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedPayment == 'qris') ...[
              const Text("Silahkan scan QRIS di bawah ini:", textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  "https://yourdomain.com/qris-statis.png", // SESUAIKAN URL BACKEND
                  height: 200,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.qr_code_scanner, size: 100, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Simpan bukti bayar untuk ditunjukkan ke Jastiper.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const Icon(Icons.account_balance_wallet_outlined, size: 70, color: Colors.green),
              const SizedBox(height: 16),
              const Text("Silahkan siapkan uang tunai sebesar:"),
              const SizedBox(height: 8),
              Text(
                "Rp ${_total.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              const SizedBox(height: 12),
              const Text("Bayar langsung ke Jastiper saat pesanan tiba.", textAlign: TextAlign.center),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                _finalizeOrder(); // Jalankan proses selesai
              },
              child: Text(
                _selectedPayment == 'qris' ? "SAYA SUDAH BAYAR" : "OKE, SAYA SIAP",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// FINALISASI SETELAH KLIK OKE DI DIALOG
  Future<void> _finalizeOrder() async {
    try {
      await CartService.clearCart();
    } catch (e) {
      debugPrint("Clear cart failed: $e");
    }

    setState(() {
      _success = true;
      _items.clear();
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/user', (route) => false);
    });
  }

  Future<void> _checkout() async {
    if (_addressCtrl.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alamat pengiriman minimal 10 karakter"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _processing = true);
    try {
      // MEMANGGIL SERVICE DENGAN PARAMETER LENGKAP
      await UserOrderService.checkout(
        deliveryAddress: _addressCtrl.text,
        paymentMethod: _selectedPayment, // SUDAH DITAMBAHKAN
        notes: _notesCtrl.text,
      );

      if (!mounted) return;
      _showInstructionDialog(); 
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal checkout: $e"), backgroundColor: Colors.red),
      );
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran"), elevation: 0),
      body: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text("Error: $_error"))
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Pesanan Anda", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 12),
                                ..._items.map((i) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("${i.quantity}x ${i.product.name}"),
                                          Text("Rp ${(double.parse(i.product.price) * i.quantity).toStringAsFixed(0)}",
                                              style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    )),
                                const Divider(height: 32),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Total Tagihan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text("Rp ${_total.toStringAsFixed(0)}",
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Text("Alamat Pengiriman", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _addressCtrl,
                                  decoration: const InputDecoration(
                                      hintText: "Contoh: Gedung C Lt. 3, Lab Komputer", border: OutlineInputBorder()),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 16),
                                const Text("Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      RadioListTile<String>(
                                        title: const Text("Tunai (Cash)"),
                                        value: 'cash',
                                        groupValue: _selectedPayment,
                                        activeColor: Colors.orange,
                                        onChanged: (v) => setState(() => _selectedPayment = v!),
                                      ),
                                      const Divider(height: 1),
                                      RadioListTile<String>(
                                        title: const Text("QRIS"),
                                        value: 'qris',
                                        groupValue: _selectedPayment,
                                        activeColor: Colors.orange,
                                        onChanged: (v) => setState(() => _selectedPayment = v!),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text("Catatan (Opsional)", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _notesCtrl,
                                  decoration: const InputDecoration(
                                      hintText: "Contoh: Sambalnya dipisah ya", border: OutlineInputBorder()),
                                ),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _processing ? null : _checkout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _processing
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text("Checkout Sekarang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
          if (_success)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 80),
                      const SizedBox(height: 16),
                      const Text("Berhasil!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 8),
                      const Text("Pesanan Anda sedang menunggu Jastiper.", textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}