<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DeliveryHistory extends Model
{
    protected $fillable = [
        'jastiper_id', 'order_id', 'commission',
        'delivered_at', 'rating', 'review'
    ];

    protected $casts = [
        'commission' => 'decimal:2',
        'delivered_at' => 'datetime'
    ];

    public function jastiper()
    {
        return $this->belongsTo(User::class, 'jastiper_id');
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}
