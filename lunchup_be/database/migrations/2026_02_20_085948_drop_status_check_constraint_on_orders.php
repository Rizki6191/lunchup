<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Drop the old enum check constraint on orders.status
     * so we can use any string values (heading_to_canteen, heading_to_customer, etc.)
     */
    public function up(): void
    {
        // Drop all check constraints on the orders table (from the old enum)
        $constraints = DB::select("
            SELECT conname
            FROM pg_constraint
            WHERE conrelid = 'orders'::regclass
              AND contype = 'c'
        ");

        foreach ($constraints as $constraint) {
            DB::statement("ALTER TABLE orders DROP CONSTRAINT IF EXISTS \"{$constraint->conname}\"");
        }

        // Ensure status column is plain varchar (no enum restriction)
        DB::statement("ALTER TABLE orders ALTER COLUMN status TYPE VARCHAR(50)");
        DB::statement("ALTER TABLE orders ALTER COLUMN status SET DEFAULT 'pending'");
    }

    public function down(): void
    {
        // Restore the original enum check constraint
        DB::statement("ALTER TABLE orders ADD CONSTRAINT orders_status_check CHECK (status IN ('pending','accepted','delivered','completed','cancelled'))");
    }
};
