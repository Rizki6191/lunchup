<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
{
    public function dashboard(Request $request)
    {
        $totalProducts = Product::count();
        
        $orderStats = Order::selectRaw("
            COUNT(*) as total_orders,
            SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_orders,
            SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_orders,
            SUM(CASE WHEN status = 'completed' THEN total_amount ELSE 0 END) as total_revenue,
            SUM(CASE WHEN status = 'completed' THEN jastiper_commission ELSE 0 END) as total_commission,
            SUM(CASE WHEN status = 'completed' THEN total_amount - jastiper_commission ELSE 0 END) as net_revenue
        ")->first();
        
        $recentOrders = Order::with(['user:id,username', 'jastiper:id,username'])
                            ->orderBy('created_at', 'desc')
                            ->limit(10)
                            ->get();
        
        $lowStockProducts = Product::where('stock', '<', 10)
                                  ->orderBy('stock', 'asc')
                                  ->limit(10)
                                  ->get(['id', 'name', 'stock', 'price']);
        
        return response()->json([
            'success' => true,
            'data' => [
                'stats' => [
                    'products' => [
                        'total' => $totalProducts,
                        'low_stock' => $lowStockProducts->count(),
                    ],
                    'orders' => [
                        'total' => $orderStats->total_orders ?? 0,
                        'pending' => $orderStats->pending_orders ?? 0,
                        'completed' => $orderStats->completed_orders ?? 0,
                    ],
                    'revenue' => [
                        'total' => $orderStats->total_revenue ?? 0,
                        'commission' => $orderStats->total_commission ?? 0,
                        'net' => $orderStats->net_revenue ?? 0,
                    ]
                ],
                'recent_orders' => $recentOrders,
                'low_stock_products' => $lowStockProducts,
            ],
            'message' => 'Dashboard stats retrieved successfully'
        ]);
    }

    public function allOrders(Request $request)
    {
        $query = Order::with(['user:id,username', 'jastiper:id,username']);
        
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }
        
        if ($request->has('start_date')) {
            $query->whereDate('created_at', '>=', $request->start_date);
        }
        
        if ($request->has('end_date')) {
            $query->whereDate('created_at', '<=', $request->end_date);
        }
        
        $orders = $query->orderBy('created_at', 'desc')
                       ->paginate($request->get('per_page', 20));
        
        return response()->json([
            'success' => true,
            'data' => $orders,
            'message' => 'All orders retrieved successfully'
        ]);
    }

    public function orderDetail(Request $request, Order $order)
    {
        $order->load(['items.product', 'user', 'jastiper']);
        
        return response()->json([
            'success' => true,
            'data' => $order,
            'message' => 'Order details retrieved successfully'
        ]);
    }

    public function updateOrderStatus(Request $request, Order $order)
    {
        $request->validate([
            'status' => 'required|in:pending,accepted,heading_to_canteen,heading_to_customer,completed,cancelled',
        ]);
        
        $oldStatus = $order->status;
        $newStatus = $request->status;
        
        DB::beginTransaction();
        try {
            $order->update(['status' => $newStatus]);
            
            if ($oldStatus !== 'cancelled' && $newStatus === 'cancelled') {
                foreach ($order->items as $item) {
                    Product::where('id', $item->product_id)
                          ->increment('stock', $item->quantity);
                }
                
                if ($order->jastiper_id) {
                    $order->update(['jastiper_id' => null]);
                }
            }
            
            DB::commit();
            
            return response()->json([
                'success' => true,
                'data' => $order,
                'message' => 'Order status updated successfully'
            ]);
            
        } catch (\Exception $e) {
            DB::rollBack();
            
            return response()->json([
                'success' => false,
                'message' => 'Failed to update order status: ' . $e->getMessage()
            ], 500);
        }
    }
}