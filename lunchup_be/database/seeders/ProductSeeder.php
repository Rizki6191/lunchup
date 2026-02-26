<?php

namespace Database\Seeders;

use App\Models\Product;
use App\Models\User;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $admin = User::where('role', 'admin')->first();
        
        if (!$admin) {
            echo "❌ Admin user not found. Please run AdminSeeder first.\n";
            return;
        }

        $products = [
            [
                'name' => 'Nasi Goreng Spesial',
                'description' => 'Nasi goreng dengan telur, ayam, dan kerupuk.',
                'price' => 25000,
                'stock' => 50,
                'category' => 'Makanan',
                'image' => 'products/nasi-goreng.jpg',
                'created_by' => $admin->id,
            ],
            [
                'name' => 'Ayam Bakar Madu',
                'description' => 'Ayam bakar bumbu madu gurih manis.',
                'price' => 30000,
                'stock' => 30,
                'category' => 'Makanan',
                'image' => 'products/nasi-goreng.jpg',
                'created_by' => $admin->id,
            ],
            [
                'name' => 'Es Teh Manis',
                'description' => 'Es teh manis segar.',
                'price' => 5000,
                'stock' => 100,
                'category' => 'Minuman',
                'image' => 'products/nasi-goreng.jpg',
                'created_by' => $admin->id,
            ],
            [
                'name' => 'Jus Alpukat',
                'description' => 'Jus alpukat kental dengan coklat.',
                'price' => 15000,
                'stock' => 20,
                'category' => 'Minuman',
                'image' => 'products/nasi-goreng.jpg',
                'created_by' => $admin->id,
            ],
        ];

        foreach ($products as $product) {
            Product::create($product);
        }

        echo "✅ Product seeder finished with " . count($products) . " products.\n";
    }
}
