<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_code')->unique();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('jastiper_id')->nullable()->constrained('users')->onDelete('set null');
            $table->decimal('total_amount', 12, 2);
            $table->enum('status', ['pending', 'accepted', 'delivered', 'completed', 'cancelled'])->default('pending');
            $table->text('delivery_address');
            $table->text('notes')->nullable();
            $table->decimal('jastiper_commission', 10, 2)->nullable();
            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('delivered_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
