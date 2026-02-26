<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;
use App\Models\User;
use App\Models\Cart;
use App\Models\OrderItem;

class Product extends Model
{
     protected $fillable = [
        'name', 'description', 'price', 'stock', 
        'category', 'image', 'created_by', 'place'
    ];

    protected $appends = ['image_url'];

    protected $hidden = ['image'];

    public function getImageUrlAttribute()
    {
        if (!$this->image) {
            return null;
        }
        
        // If it's already a full URL (legacy data), return it directly
        if (filter_var($this->image, FILTER_VALIDATE_URL)) {
            return $this->image;
        }

        return url(\Illuminate\Support\Facades\Storage::url($this->image));
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function carts()
    {
        return $this->hasMany(Cart::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }
}
