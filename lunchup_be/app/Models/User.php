<?php

namespace App\Models;

// use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = [
        'username', 'email', 'password', 'role'
    ];

    protected $hidden = [
        'password', 'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    // Helper methods untuk check role
    public function isAdmin()
    {
        return $this->role === 'admin';
    }

    public function isJastiper()
    {
        return $this->role === 'jastiper';
    }

    public function isUser()
    {
        return $this->role === 'user';
    }

    // Relationships
    public function products()
    {
        return $this->hasMany(Product::class, 'created_by');
    }

    public function carts()
    {
        return $this->hasMany(Cart::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class, 'user_id');
    }

    public function jastiperOrders()
    {
        return $this->hasMany(Order::class, 'jastiper_id');
    }

    public function deliveryHistories()
    {
        return $this->hasMany(DeliveryHistory::class, 'jastiper_id');
    }
    
}
