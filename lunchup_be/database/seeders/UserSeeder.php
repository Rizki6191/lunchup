<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Sample Customer
        User::create([
            'username' => 'testuser',
            'email' => 'testuser@example.com',
            'password' => Hash::make('password'),
            'role' => 'user',
        ]);

        // Sample Jastiper
        User::create([
            'username' => 'testjastiper',
            'email' => 'testjastiper@example.com',
            'password' => Hash::make('password'),
            'role' => 'jastiper',
        ]);

        echo "✅ User & Jastiper seeders created successfully.\n";

        // passwordnya 'password'
    }
}
