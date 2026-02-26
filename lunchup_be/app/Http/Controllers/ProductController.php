<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
     public function index(Request $request)
    {
        $query = Product::query();
        
        if ($request->has('category')) {
            $query->where('category', $request->category);
        }
        
        if ($request->has('search')) {
            $query->where('name', 'like', '%' . $request->search . '%');
        }
        
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        $query->orderBy($sortBy, $sortOrder);
        
        $products = $query->paginate($request->get('per_page', 15));
        
        return response()->json([
            'success' => true,
            'data' => $products,
            'message' => 'Products retrieved successfully'
        ]);
    }

    /**
     *
     * 
     * @bodyParam name string required The name of the product. Example: Nasi Goreng
     * @bodyParam description string The description of the product. Example: Tasty fried rice.
     * @bodyParam price number required The price of the product. Example: 15000
     * @bodyParam stock integer required The stock of the product. Example: 50
     * @bodyParam category string The category of the product. Example: Food
     * @bodyParam image_url file The product image.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'category' => 'nullable|string|max:100',
            'image_url' => 'nullable|image|max:2048',
            'place' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $imagePath = null;
        if ($request->hasFile('image_url')) {
            $file = $request->file('image_url');
            $filename = $file->getClientOriginalName();
            $imagePath = $file->storeAs('products', $filename, 'public');
        }

        $product = Product::create([
            'name' => $request->name,
            'description' => $request->description,
            'price' => $request->price,
            'stock' => $request->stock,
            'category' => $request->category,
            'image' => $imagePath,
            'place' => $request->place,
            'created_by' => $request->user()->id,
        ]);

        return response()->json([
            'success' => true,
            'data' => $product,
            'message' => 'Product created successfully'
        ], 201);
    }

    public function show(Product $product)
    {
        return response()->json([
            'success' => true,
            'data' => $product,
            'message' => 'Product retrieved successfully'
        ]);
    }

    /**
     * 
     * 
     * @bodyParam name string The name of the product.
     * @bodyParam description string The description of the product.
     * @bodyParam price number The price of the product.
     * @bodyParam stock integer The stock of the product.
     * @bodyParam category string The category of the product.
     * @bodyParam image_url file The product image.
     */
    public function update(Request $request, Product $product)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'price' => 'sometimes|numeric|min:0',
            'stock' => 'sometimes|integer|min:0',
            'category' => 'nullable|string|max:100',
            'image_url' => 'nullable|image|max:2048',
            'place' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $validator->validated();

        if ($request->hasFile('image_url')) {
            // Delete old image if exists
            if ($product->image && Storage::disk('public')->exists($product->image)) {
                Storage::disk('public')->delete($product->image);
            }
            
            $file = $request->file('image_url');
            $filename = $file->getClientOriginalName();
            unset($data['image_url']);
            $data['image'] = $file->storeAs('products', $filename, 'public');
        }

        $product->update($data);

        // If place was provided, ensure it's updated
        if ($request->has('place')) {
            $product->place = $request->place;
            $product->save();
        }

        return response()->json([
            'success' => true,
            'data' => $product,
            'message' => 'Product updated successfully'
        ]);
    }

    public function destroy(Product $product)
    {
        if ($product->image && Storage::disk('public')->exists($product->image)) {
            Storage::disk('public')->delete($product->image);
        }
        
        $product->delete();
        
        return response()->json([
            'success' => true,
            'message' => 'Product deleted successfully'
        ]);
    }

    public function byCategory($category)
    {
        $products = Product::where('category', $category)
                          ->where('stock', '>', 0)
                          ->paginate(15);
        
        return response()->json([
            'success' => true,
            'data' => $products,
            'message' => 'Products by category retrieved successfully'
        ]);
    }
}
