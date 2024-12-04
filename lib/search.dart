import 'dart:convert';
import 'dart:async'; // Import for Timer
import 'package:apiintegration_biz/productlist.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'modelclass.dart'; // Assuming your model classes are in this file

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Category> categories = []; // Holds all categories from the API
  List<Product> filteredProducts = []; // Holds filtered products after search filtering
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true; // Track API loading state
  bool hasError = false; // Track API error state
  bool isSearchEmpty = false; // To show empty search state
  Timer? _debounce; // Change _debounce to be nullable

  @override
  void initState() {
    super.initState();
    fetchCategories();
    _searchController.addListener(_onSearchChanged);
  }

  // Fetch Categories from the API
  Future<void> fetchCategories() async {
    const String url = 'https://btobapi-production.up.railway.app/api/categories/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          categories = data.map((json) => Category.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  // Debounced Search Function
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel(); // Safely check for null and cancel
    _debounce = Timer(const Duration(milliseconds: 500), _filterProducts);
  }

  // Filter Products Based on Search Query
  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredProducts = [];
      } else {
        filteredProducts = [];
        for (var category in categories) {
          final categoryProducts = category.products.where((product) {
            return product.productName.toLowerCase().contains(query);
          }).toList();
          filteredProducts.addAll(categoryProducts);
        }
      }
      isSearchEmpty = filteredProducts.isEmpty;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel the debounce timer if it exists
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Circular Progress Loader while fetching categories or products
  Widget buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // Error state UI with retry button
  Widget buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Failed to load categories. Please try again.', style: TextStyle(color: Colors.red)),
          ElevatedButton(
            onPressed: fetchCategories, // Retry fetching categories
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Main category list UI with horizontal scroll
  Widget buildCategoryList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.black),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    filteredProducts = []; // Clear filtered products on clear search
                  });
                },
              ),
              hintText: 'Search Products',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
        isSearchEmpty
            ? const Expanded(
          child: Center(
            child: Text(
              'No products found',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        )
            : Expanded(
          child: ListView.builder(
            itemCount: filteredProducts.isNotEmpty
                ? filteredProducts.length
                : categories.length,
            itemBuilder: (context, index) {
              if (filteredProducts.isEmpty) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to product list of that category
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductList(
                          products: category.products,
                        ),
                      ),
                    );
                  },
                  child: Container(height: 100,
                    width: 120, // Adjust the card width
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon placeholder for category
                        Icon(
                          Icons.category, // Replace with the actual icon based on the category
                          color: index % 2 == 0 ? Colors.green : Colors.black, // Change color for variety
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        // Category label
                        Text(
                          category.label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Container(
                  //   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(12),
                  //     boxShadow: const [
                  //       BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(0, 2)),
                  //     ],
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.category, size: 40, color: Colors.blue),
                  //       const SizedBox(width: 16),
                  //       Text(
                  //         category.label,
                  //         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                );
              } else {
                final product = filteredProducts[index];
                return ListTile(
                  title: Text(product.productName),
                  subtitle: Text('Price: \$${product.price}'),
                  onTap: () {
                    // Navigate to the product details or another screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductList(products: [product]),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Search Products",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: isLoading
          ? buildLoadingIndicator() // Show Circular Progress Indicator while loading
          : hasError
          ? buildErrorState() // Show error state if the API call fails
          : buildCategoryList(), // Show categories or filtered products
    );
  }
}
