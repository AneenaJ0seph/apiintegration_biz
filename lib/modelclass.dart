// Category Model
class Category {
  final int id;
  final String label;
  final List<Product> products; // List of Product instead of List<dynamic>

  Category({
    required this.id,
    required this.label,
    required this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0, // Default to 0 if id is null
      label: json['name'] ?? '', // Default to empty string if name is missing
      // Convert products field to List<Product> from JSON
      products: (json['products'] as List?)?.map((item) => Product.fromJson(item)).toList() ?? [],
    );
  }
}

// Product Model
class Product {
  final int id;
  final String productName;
  final String productDetails;
  final String image;
  final double price;
  final double wholesalePrice;
  final int minimumOrderQuantity;

  Product({
    required this.id,
    required this.productName,
    required this.productDetails,
    required this.image,
    required this.price,
    required this.wholesalePrice,
    required this.minimumOrderQuantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0, // Default to 0 if id is null
      productName: json['product_name'] ?? '', // Default to empty string if missing
      productDetails: json['product_details'] ?? '', // Default to empty string if missing
      image: json['image'] ?? '', // Default to empty string if missing
      // Parse price correctly
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      wholesalePrice: json['wholesale_price'] != null ? double.parse(json['wholesale_price'].toString()) : 0.0,
      minimumOrderQuantity: json['minimum_order_quantity'] ?? 0, // Default to 0 if missing
    );
  }
}
