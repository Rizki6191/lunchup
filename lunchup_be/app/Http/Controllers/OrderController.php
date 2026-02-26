<?php

namespace App\Http\Controllers;

use App\Models\Cart;
use App\Models\DeliveryHistory;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class OrderController extends Controller
{
    /**
     * Mengambil daftar pesanan milik user (Buyer)
     */
    public function userOrders(Request $request)
    {
        $orders = Order::with(['items.product', 'jastiper:id,username'])
            ->where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $orders,
            'message' => 'Orders retrieved successfully',
        ]);
    }

    /**
     * Proses Checkout: Membuat pesanan baru
     */
    public function checkout(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'delivery_address' => 'required|string|min:10',
            'notes' => 'nullable|string|max:500',
            'payment_method' => 'required|in:cash,qris',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = $request->user();
        $paymentMethod = $request->payment_method;

        $cartItems = Cart::with('product')
            ->where('user_id', $user->id)
            ->get();

        if ($cartItems->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Cart is empty',
            ], 400);
        }

        DB::beginTransaction();

        try {
            // Tentukan path QRIS jika metode pembayaran QRIS
            $qrisPath = ($paymentMethod === 'qris') ? 'payments/qris_test.jpg' : null;

            $order = Order::create([
                'order_code' => 'ORD'.time().rand(100, 999),
                'user_id' => $user->id,
                'total_amount' => 0, // Akan diupdate setelah loop
                'status' => 'pending',
                'payment_method' => $paymentMethod,
                'qris_image' => $qrisPath,
                'delivery_address' => $request->delivery_address,
                'notes' => $request->notes,
            ]);

            $totalAmount = 0;

            foreach ($cartItems as $cartItem) {
                $product = $cartItem->product()->lockForUpdate()->first();

                if ($cartItem->quantity > $product->stock) {
                    throw new \Exception('Stock tidak cukup untuk produk: '.$product->name);
                }

                $subtotal = $product->price * $cartItem->quantity;

                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $product->id,
                    'quantity' => $cartItem->quantity,
                    'price_at_time' => $product->price,
                    'subtotal' => $subtotal,
                ]);

                $totalAmount += $subtotal;
                $product->decrement('stock', $cartItem->quantity);
            }

            $order->update(['total_amount' => $totalAmount]);

            // Bersihkan keranjang
            Cart::where('user_id', $user->id)->delete();

            DB::commit();

            // Load data terbaru untuk response
            $order->load('items.product');
            $order->payment = $this->getPaymentDetail($order);

            return response()->json([
                'success' => true,
                'data' => $order,
                'message' => 'Order created successfully',
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to create order: '.$e->getMessage(),
            ], 500);
        }
    }

    /**
     * Menampilkan detail satu pesanan
     */
    public function show(Request $request, Order $order)
    {
        $user = $request->user();

        $isBuyer = $order->user_id === $user->id;
        $isAdmin = $user->role === 'admin';
        $isAssignedJastiper = $order->jastiper_id === $user->id;
        $isJastiperPending = $user->role === 'jastiper' && $order->status === 'pending';

        if (! ($isBuyer || $isAdmin || $isAssignedJastiper || $isJastiperPending)) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $order->load(['items.product', 'user:id,username', 'jastiper:id,username']);
        $order->payment = $this->getPaymentDetail($order);

        return response()->json([
            'success' => true,
            'data' => $order,
            'message' => 'Order details retrieved successfully',
        ]);
    }

    /**
     * List order yang masih 'pending' untuk diambil Jastiper
     */
    public function availableOrders()
    {
        $orders = Order::with(['user:id,username', 'items.product'])
            ->where('status', 'pending')
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return response()->json([
            'success' => true,
            'data' => [
                'available_orders' => $orders,
                'total_available' => Order::where('status', 'pending')->count(),
            ],
            'message' => 'Available orders retrieved successfully',
        ]);
    }

    /**
     * Jastiper menerima/mengambil orderan
     */
    public function acceptOrder(Request $request, Order $order)
    {
        if ($order->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Order tidak tersedia',
            ], 400);
        }

        $updated = Order::where('id', $order->id)
            ->where('status', 'pending')
            ->update([
                'jastiper_id' => $request->user()->id,
                'status' => 'accepted',
                'accepted_at' => now(),
            ]);

        if (! $updated) {
            return response()->json([
                'success' => false,
                'message' => 'Order already taken',
            ], 400);
        }

        return response()->json([
            'success' => true,
            'message' => 'Order accepted successfully',
        ]);
    }

    /**
     * Jastiper mengupdate status (menuju kantin -> menuju customer)
     */
    public function updateStatus(Request $request, Order $order)
    {
        $user = $request->user();

        if ($order->jastiper_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        // Alur transisi status sesuai diskusi
        $transitions = [
            'accepted' => 'heading_to_canteen',
            'heading_to_canteen' => 'heading_to_customer',
        ];

        $current = $order->status;

        if (! isset($transitions[$current])) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid status transition atau status sudah di tahap akhir Jastiper',
            ], 400);
        }

        $next = $transitions[$current];

        $updated = Order::where('id', $order->id)
            ->where('status', $current)
            ->where('jastiper_id', $user->id)
            ->update(['status' => $next]);

        if (! $updated) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update status',
            ], 400);
        }

        $order->refresh();
        $order->load(['items.product', 'user:id,username', 'jastiper:id,username']);
        $order->payment = $this->getPaymentDetail($order);

        return response()->json([
            'success' => true,
            'data' => $order,
            'message' => 'Status updated to '.$next,
        ]);
    }

    /**
     * Buyer mengonfirmasi pesanan diterima (Selesai)
     */
    public function confirm(Request $request, Order $order)
    {
        $user = $request->user();

        // VALIDASI: Hanya Buyer yang memesan yang bisa klik selesai
        if ($order->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Hanya pembeli yang bisa menyelesaikan pesanan ini',
            ], 403);
        }

        // VALIDASI: Hanya bisa selesai jika Jastiper sudah 'heading_to_customer'
        if ($order->status !== 'heading_to_customer') {
            return response()->json([
                'success' => false,
                'message' => 'Jastiper belum dalam perjalanan ke lokasimu',
            ], 400);
        }

        DB::beginTransaction();
        try {
            $commission = $order->total_amount * 0.10; // Komisi 10%

            $order->update([
                'status' => 'completed',
                'jastiper_commission' => $commission,
                'completed_at' => now(),
            ]);

            DeliveryHistory::create([
                'jastiper_id' => $order->jastiper_id,
                'order_id' => $order->id,
                'commission' => $commission,
                'delivered_at' => now(),
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Order completed successfully. Terima kasih!',
            ]);

        } catch (\Exception $e) {
            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Failed to confirm order',
            ], 500);
        }
    }

    /**
     * Daftar pengantaran aktif milik Jastiper
     */
    public function activeDeliveries(Request $request)
    {
        $orders = Order::with(['user:id,username'])
            ->where('jastiper_id', $request->user()->id)
            ->whereIn('status', ['accepted', 'heading_to_canteen', 'heading_to_customer'])
            ->orderBy('accepted_at', 'desc')
            ->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $orders,
            'message' => 'Active deliveries retrieved successfully',
        ]);
    }

    /**
     * Riwayat pendapatan Jastiper
     */
    public function deliveryHistory(Request $request)
    {
        $orders = Order::with(['user:id,username'])
            ->where('jastiper_id', $request->user()->id)
            ->where('status', 'completed')
            ->orderBy('completed_at', 'desc')
            ->paginate(10);

        $totalEarnings = Order::where('jastiper_id', $request->user()->id)
            ->where('status', 'completed')
            ->sum('jastiper_commission');

        return response()->json([
            'success' => true,
            'data' => [
                'history' => $orders,
                'total_earnings' => $totalEarnings,
                'total_deliveries' => $orders->total(),
            ],
            'message' => 'Delivery history retrieved successfully',
        ]);
    }

    /**
     * Helper: Format informasi pembayaran untuk dikirim ke Client (Mobile)
     * Saat status 'heading_to_customer', tampilkan detail tagihan ke Jastiper.
     */
    private function getPaymentDetail($order): array
    {
        $totalFormatted = 'Rp '.number_format($order->total_amount, 0, ',', '.');
        $paymentMethod = (string) ($order->payment_method ?? 'cash');

        $payment = [
            'metode_pembayaran' => strtoupper($paymentMethod),
            'total_yang_harus_dibayar' => (float) $order->total_amount,
            'total_yang_harus_dibayar_formatted' => $totalFormatted,
        ];

        if ($order->status === 'heading_to_customer') {
            if ($paymentMethod === 'qris') {
                $payment['instruksi'] = 'Tunjukkan QRIS berikut ke Customer untuk dibayar';
                $payment['qr_image_url'] = $order->qris_image
                    ? asset('storage/'.$order->qris_image)
                    : null;
            } else {
                $payment['instruksi'] = 'Tagih tunai ke Customer sebesar '.$totalFormatted;
            }
            $payment['catatan'] = 'Order hanya selesai setelah Customer menekan tombol Terima';
        } else {
            $payment['instruksi'] = $paymentMethod === 'qris'
                ? 'Customer akan membayar via QRIS saat pesanan tiba'
                : 'Customer akan membayar tunai saat pesanan tiba';
        }

        return $payment;
    }
}
