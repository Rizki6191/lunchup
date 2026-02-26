<?php

namespace App\Http\Controllers;

use App\Models\DeliveryHistory;
use Illuminate\Http\Request;

class JastiperController extends Controller
{
    public function earnings(Request $request)
    {
        $user = $request->user();
        
        $totalEarnings = $user->jastiperOrders()
                             ->where('status', 'completed')
                             ->sum('jastiper_commission');
        
        $monthEarnings = $user->jastiperOrders()
                             ->where('status', 'completed')
                             ->whereMonth('completed_at', now()->month)
                             ->whereYear('completed_at', now()->year)
                             ->sum('jastiper_commission');
        
        $deliveryHistory = DeliveryHistory::with(['order.user:id,username'])
                                         ->where('jastiper_id', $user->id)
                                         ->orderBy('delivered_at', 'desc')
                                         ->paginate(10);
        
        return response()->json([
            'success' => true,
            'data' => [
                'summary' => [
                    'total_earnings' => $totalEarnings,
                    'month_earnings' => $monthEarnings,
                    'total_deliveries' => $deliveryHistory->total(),
                ],
                'history' => $deliveryHistory,
            ],
            'message' => 'Earnings retrieved successfully'
        ]);
    }

    public function deliveryHistory(Request $request)
    {
        $history = DeliveryHistory::with(['order.user:id,username', 'order.items.product:id,name'])
                                 ->where('jastiper_id', $request->user()->id)
                                 ->orderBy('delivered_at', 'desc')
                                 ->paginate(15);
        
        return response()->json([
            'success' => true,
            'data' => $history,
            'message' => 'Delivery history retrieved successfully'
        ]);
    }
}