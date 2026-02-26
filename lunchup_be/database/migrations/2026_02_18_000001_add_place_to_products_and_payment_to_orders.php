<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Add place to products (skip if already exists)
        if (!Schema::hasColumn('products', 'place')) {
            Schema::table('products', function (Blueprint $table) {
                $table->string('place')->nullable()->after('category');
            });
        }

        // Add payment_method to orders (skip if already exists)
        if (!Schema::hasColumn('orders', 'payment_method')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->string('payment_method')->default('cash')->after('total_amount');
            });
        }

        // Attempt to convert enum status to string safely depending on driver
        $driver = Schema::getConnection()->getDriverName();
        if ($driver === 'pgsql') {
            DB::statement("ALTER TABLE orders ALTER COLUMN status TYPE varchar USING status::text");
            DB::statement("ALTER TABLE orders ALTER COLUMN status SET DEFAULT 'pending'");
        } elseif ($driver === 'mysql') {
            DB::statement("ALTER TABLE orders MODIFY COLUMN status varchar(191) NOT NULL DEFAULT 'pending'");
        } else {
            // Fallback: try a schema change (requires doctrine/dbal)
            try {
                Schema::table('orders', function (Blueprint $table) {
                    $table->string('status')->default('pending')->change();
                });
            } catch (\Throwable $e) {
                // If change() is not available, leave enum as-is but default will be respected on new rows
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Remove place from products
        Schema::table('products', function (Blueprint $table) {
            $table->dropColumn('place');
        });

        // Remove payment_method from orders
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn('payment_method');
        });

        // Note: reverting enum change is non-trivial and not handled automatically
    }
};
