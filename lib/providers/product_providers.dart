import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/api_service.dart';

final productsProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  return ProductsNotifier();
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ApiService _apiService = ApiService();
  final _favoritesKey = 'favorites';

  ProductsNotifier() : super(const AsyncValue.loading()) {
    _loadFavorites();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await _apiService.getProducts();
      state = AsyncValue.data(products);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void toggleFavorite(int productId) {
    state.whenData((products) {
      final updatedProducts = products.map((product) {
        if (product.id == productId) {
          return Product(
            id: product.id,
            title: product.title,
            price: product.price,
            description: product.description,
            image: product.image,
            isFavorite: !product.isFavorite,
          );
        }
        return product;
      }).toList();
      state = AsyncValue.data(updatedProducts);
      _saveFavorites(updatedProducts);
    });
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      if (favoritesJson != null) {
        final favoriteProducts = (jsonDecode(favoritesJson) as List)
            .map((json) => Product.fromJson(json))
            .toList();
        state = AsyncValue.data(favoriteProducts);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> _saveFavorites(List<Product> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson =
          jsonEncode(favorites.map((product) => product.toJson()).toList());
      await prefs.setString(_favoritesKey, favoritesJson);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
