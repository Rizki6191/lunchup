<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class ProfileController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user();
        
        $profile = [
            'id' => $user->id,
            'username' => $user->username,
            'email' => $user->email,
            'role' => $user->role,
            'created_at' => $user->created_at,
            'updated_at' => $user->updated_at,
        ];
        
        if ($user->isJastiper()) {
            $profile['total_earnings'] = $user->deliveryHistories()->sum('commission');
            $profile['total_deliveries'] = $user->deliveryHistories()->count();
        } elseif ($user->isUser()) {
            $profile['total_orders'] = $user->orders()->count();
        } elseif ($user->isAdmin()) {
            $profile['products_created'] = $user->products()->count();
        }
        
        return response()->json([
            'success' => true,
            'data' => $profile,
            'message' => 'Profile retrieved successfully'
        ]);
    }

    public function update(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'username' => 'sometimes|string|max:255|unique:users,username,' . $user->id,
            'email' => 'sometimes|string|email|max:255|unique:users,email,' . $user->id,
            'current_password' => 'required_with:password',
            'password' => 'sometimes|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $updateData = [];
        
        if ($request->has('username')) {
            $updateData['username'] = $request->username;
        }
        
        if ($request->has('email')) {
            $updateData['email'] = $request->email;
        }
        
        if ($request->has('password')) {
            if (!Hash::check($request->current_password, $user->password)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Current password is incorrect'
                ], 400);
            }
            
            $updateData['password'] = Hash::make($request->password);
        }
        
        $user->update($updateData);
        
        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'username' => $user->username,
                'email' => $user->email,
                'role' => $user->role,
            ],
            'message' => 'Profile updated successfully'
        ]);
    }
}