<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    public function isCash()
    {
        return $this->payment_method === 'cash';
    }

    public function isQris()
    {
        return $this->payment_method === 'qris';
    }

    protected $fillable = [
        'order_code', 'user_id', 'jastiper_id', 'total_amount',
        'status', 'delivery_address', 'notes', 'jastiper_commission', 'payment_method',
    ];

    protected $appends = ['status_label'];

    // Label status dalam bahasa Indonesia
    public function getStatusLabelAttribute(): string
    {
        return match ($this->status) {
            'pending'             => 'Menunggu Jastiper',
            'accepted'            => 'Diterima Jastiper',
            'heading_to_canteen'  => 'Menuju Kantin',
            'heading_to_customer' => 'Menuju Customer',
            'completed'           => 'Selesai',
            'cancelled'           => 'Dibatalkan',
            default               => ucfirst($this->status),
        };
    }

    protected $casts = [
        'total_amount' => 'decimal:2',
        'jastiper_commission' => 'decimal:2',
        'accepted_at' => 'datetime',
        'delivered_at' => 'datetime',
        'completed_at' => 'datetime',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function jastiper()
    {
        return $this->belongsTo(User::class, 'jastiper_id');
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function deliveryHistory()
    {
        return $this->hasOne(DeliveryHistory::class);
    }

    // Scopes
    public function scopePending($query)
    {
        return $query->where('status', 'pending');
    }

    public function scopeActive($query, $jastiperId = null)
    {
        $query = $query->whereIn('status', ['accepted', 'heading_to_canteen', 'heading_to_customer']);

        if ($jastiperId) {
            $query->where('jastiper_id', $jastiperId);
        }

        return $query;
    }

    public function scopeCompleted($query, $jastiperId = null)
    {
        $query = $query->where('status', 'completed');

        if ($jastiperId) {
            $query->where('jastiper_id', $jastiperId);
        }

        return $query;
    }
}
