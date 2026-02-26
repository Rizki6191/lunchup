<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\JastiperController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Public routes (no authentication required)
Route::prefix('auth')->group(function () {
    Route::post('/register', [RegisterController::class, 'register']);
    Route::post('/login', [LoginController::class, 'login']);
});

// Protected routes (require authentication)
Route::middleware('auth:sanctum')->group(function () {

    // Auth routes
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [LoginController::class, 'logout']);
        // Route::get('/me', [LoginController::class, 'me']);
    });

    // Profile routes - semua role bisa akses
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::put('/profile', [ProfileController::class, 'update']);

    // Products routes
    // GET routes - semua role bisa akses
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/products/{product}', [ProductController::class, 'show']);
    Route::get('/products/category/{category}', [ProductController::class, 'byCategory']);

    // Cart routes - hanya user & admin (admin mungkin mau test)
    Route::middleware('role:user,admin')->prefix('cart')->group(function () {
        Route::get('/', [CartController::class, 'index']);
        Route::post('/', [CartController::class, 'store']);
        Route::put('/{cart}', [CartController::class, 'update']);
        Route::delete('/{cart}', [CartController::class, 'destroy']);
        Route::delete('/', [CartController::class, 'clear']); // Clear all cart items
    });

    Route::middleware('role:user,admin')->prefix('orders')->group(function () {
        Route::get('/my-orders', [OrderController::class, 'userOrders']);       // Riwayat order user
        Route::post('/checkout', [OrderController::class, 'checkout']);         // Checkout keranjang
        // Route::get('/{order}', [OrderController::class, 'show']);               // Detail order
        Route::post('/{order}/confirm', [OrderController::class, 'confirm']);   // Buyer ACC / terima pesanan
    });

    Route::middleware('role:user,admin,jastiper')
    ->get('/orders/{order}', [OrderController::class, 'show'])
    ->whereNumber('order');;

    // Jastiper routes
    Route::middleware('role:jastiper')->prefix('jastiper')->group(function () {
        // Orders management
        Route::get('/orders/available', [OrderController::class, 'availableOrders']); // Pending orders
        Route::get('/orders/active', [OrderController::class, 'activeDeliveries']); // Active deliveries
        Route::post('/orders/{order}/accept', [OrderController::class, 'acceptOrder']); // Accept order
        Route::put('/orders/{order}/status', [OrderController::class, 'updateStatus']); // Update status

        // Dashboard & earnings
        Route::get('/earnings', [JastiperController::class, 'earnings']); // Earnings summary
        Route::get('/delivery-history', [JastiperController::class, 'deliveryHistory']); // Delivery history
    });

    // Admin routes
    Route::middleware('role:admin')->prefix('admin')->group(function () {
        // Products CRUD
        Route::post('/products', [ProductController::class, 'store']);
        Route::put('/products/{product}', [ProductController::class, 'update']);
        Route::delete('/products/{product}', [ProductController::class, 'destroy']);

        // Dashboard
        Route::get('/dashboard', [AdminController::class, 'dashboard']);

        // Orders management
        Route::get('/orders', [AdminController::class, 'allOrders']);
        Route::get('/orders/{order}', [AdminController::class, 'orderDetail']);
        Route::put('/orders/{order}/status', [AdminController::class, 'updateOrderStatus']);
    });

    // Route untuk semua role yang sudah login (contoh dashboard sederhana)
    Route::get('/dashboard', function (Request $request) {
        $user = $request->user();
        $role = $user->role;

        $dashboard = [
            'user' => [
                'id' => $user->id,
                'username' => $user->username,
                'role' => $role,
            ]
        ];

        // Tambahkan data berdasarkan role
        if ($role === 'user') {
            $dashboard['cart_count'] = $user->carts()->count();
            $dashboard['order_count'] = $user->orders()->count();
            $dashboard['message'] = 'User Dashboard';
        } elseif ($role === 'jastiper') {
            $dashboard['available_orders'] = \App\Models\Order::where('status', 'pending')->count();
            $dashboard['active_deliveries'] = $user->jastiperOrders()
                ->whereIn('status', ['accepted', 'heading_to_canteen', 'heading_to_customer'])
                ->count();
            $dashboard['total_earnings'] = $user->deliveryHistories()->sum('commission');
            $dashboard['total_completed_amount'] = $user->jastiperOrders()
                ->where('status', 'completed')
                ->sum('total_amount');
            $dashboard['message'] = 'Jastiper Dashboard';
        } elseif ($role === 'admin') {
            $dashboard['total_products'] = \App\Models\Product::count();
            $dashboard['total_orders'] = \App\Models\Order::count();
            $dashboard['pending_orders'] = \App\Models\Order::where('status', 'pending')->count();
            $dashboard['message'] = 'Admin Dashboard';
        }

        return response()->json([
            'success' => true,
            'data' => $dashboard,
            'message' => 'Dashboard retrieved successfully'
        ]);
    });
});

// Fallback route untuk 404
Route::fallback(function () {
    return response()->json([
        'success' => false,
        'message' => 'Route not found'
    ], 404);
});