import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Product>? _products;
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;

  ProductProvider(this._apiService);

  List<Product>? get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final productsJson = await _apiService.getProducts();
      _products = productsJson
          .map<Product>((json) => Product.fromJson(json))
          .toList();
      
      _selectedProduct = _products?.isNotEmpty == true ? _products![0] : null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectProduct(String productId) {
    if (_products == null) return;
    
    final product = _products!.firstWhere(
      (p) => p.id == productId,
      orElse: () => _products![0],
    );
    
    _selectedProduct = product;
    notifyListeners();
  }
}