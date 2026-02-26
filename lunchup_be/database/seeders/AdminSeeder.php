<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Cek apakah admin sudah ada
        $existingAdmin = User::where('email', 'testadmin@example.com')->first();
        
        if ($existingAdmin) {
            echo "⚠️ Admin sudah ada:\n";
            echo "   Email: " . $existingAdmin->email . "\n";
            echo "   Role: " . $existingAdmin->role . "\n";
            
            // FIX: Jangan cek password dengan Hash::check jika tidak yakin formatnya
            // Update langsung password ke hash yang benar
            $existingAdmin->update([
                'password' => Hash::make('12345678'), // Reset ke hash yang benar
                'role' => 'admin'
            ]);
            
            echo "   🔒 Password direset ke: 12345678 (hash baru)\n";
            echo "   ✅ Admin sudah siap digunakan\n";
            return;
        }
        
        // Buat admin baru
        $admin = User::create([
            'username' => 'admin',
            'email' => 'testadmin@example.com',
            'password' => Hash::make('12345678'),
            'role' => 'admin',
        ]);
        
        echo "✅ Admin berhasil dibuat:\n";
        echo "   👤 Username: admin\n";
        echo "   📧 Email: testadmin@example.com\n";
        echo "   🔑 Password: 12345678\n";
        echo "   🎯 Role: admin\n";
        echo "   🆔 ID: " . $admin->id . "\n";
    }
}