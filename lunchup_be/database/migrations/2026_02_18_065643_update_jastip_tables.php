<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::table('products', function (Blueprint $table) {
            $table->string('place')->after('price')->nullable();
        });

        Schema::table('orders', function (Blueprint $table) {

            // Ubah status jadi string (bukan enum)
            $table->string('status')->default('pending')->change();

            // Payment method juga string
            $table->string('payment_method')->default('cash');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        //
    }
};
