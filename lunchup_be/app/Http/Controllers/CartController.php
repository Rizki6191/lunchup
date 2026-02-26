<?php

namespace App\Http\Controllers;

use App\Models\Cart;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CartController extends Controller
{
    public function index(Request $request)
    {
        $cartItems = Cart::with('product')
                        ->where('user_id', $request->user()->id)
                        ->get();
        
        $total = 0;
        $itemsCount = 0;
        
        foreach ($cartItems as $item) {
            $total += $item->product->price * $item->quantity;
            $itemsCount += $item->quantity;
        }
        
        return response()->json([
            'success' => true,
            'data' => [
                'items' => $cartItems,
                'summary' => [
                    'items_count' => $itemsCount,
                    'total_amount' => $total,
                ]
            ],
            'message' => 'Cart retrieved successfully'
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $product = Product::findOrFail($request->product_id);
        
        if ($product->stock < $request->quantity) {
            return response()->json([
                'success' => false,
                'message' => 'Stock tidak cukup. Stock tersedia: ' . $product->stock
            ], 400);
        }

        $existingCart = Cart::where('user_id', $request->user()->id)
                           ->where('product_id', $request->product_id)
                           ->first();
        
        if ($existingCart) {
            $existingCart->quantity += $request->quantity;
            
            if ($product->stock < $existingCart->quantity) {
                return response()->json([
                    'success' => false,
                    'message' => 'Stock tidak cukup untuk tambahan quantity ini'
                ], 400);
            }
            
            $existingCart->save();
            $cart = $existingCart;
        } else {
            $cart = Cart::create([
                'user_id' => $request->user()->id,
                'product_id' => $request->product_id,
                'quantity' => $request->quantity,
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $cart->load('product'),
            'message' => 'Product added to cart successfully'
        ], 201);
    }

    public function update(Request $request, Cart $cart)
    {
        if ($cart->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'quantity' => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        if ($cart->product->stock < $request->quantity) {
            return response()->json([
                'success' => false,
                'message' => 'Stock tidak cukup. Stock tersedia: ' . $cart->product->stock
            ], 400);
        }

        $cart->update(['quantity' => $request->quantity]);

        return response()->json([
            'success' => true,
            'data' => $cart->load('product'),
            'message' => 'Cart updated successfully'
        ]);
    }

    public function destroy(Request $request, Cart $cart)
    {
        if ($cart->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $cart->delete();

        return response()->json([
            'success' => true,
            'message' => 'Item removed from cart successfully'
        ]);
    }

    public function clear(Request $request)
    {
        Cart::where('user_id', $request->user()->id)->delete();
        
        return response()->json([
            'success' => true,
            'message' => 'Cart cleared successfully'
        ]);
    }
}
