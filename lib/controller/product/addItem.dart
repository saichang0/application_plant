import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:plant_aplication/model/itemCart.dart';

// Cart state notifier
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  // Add item to cart
  void addItem({
    required String productId,
    required String name,
    required String image,
    required double price,
    required int quantity,
  }) {
    // Check if item already exists in cart
    final existingIndex = state.indexWhere((item) => item.id == productId);

    if (existingIndex >= 0) {
      // Update quantity if item exists
      final updatedCart = [...state];
      updatedCart[existingIndex] = updatedCart[existingIndex].copyWith(
        quantity: updatedCart[existingIndex].quantity + quantity,
      );
      state = updatedCart;
    } else {
      // Add new item
      state = [
        ...state,
        CartItem(
          id: productId,
          name: name,
          image: image,
          price: price,
          quantity: quantity,
        ),
      ];
    }
  }

  // Update item quantity
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    state = [
      for (final item in state)
        if (item.id == productId) item.copyWith(quantity: quantity) else item,
    ];
  }

  // Increment quantity
  void incrementQuantity(String productId) {
    state = [
      for (final item in state)
        if (item.id == productId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  // Decrement quantity
  void decrementQuantity(String productId) {
    state = [
      for (final item in state)
        if (item.id == productId)
          item.copyWith(quantity: item.quantity > 1 ? item.quantity - 1 : 1)
        else
          item,
    ];
  }

  // Remove item from cart
  void removeItem(String productId) {
    state = state.where((item) => item.id != productId).toList();
  }

  // Clear cart
  void clearCart() {
    state = [];
  }

  // Get total items count
  int get totalItems {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  // Get total price
  double get totalPrice {
    return state.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}

// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// Computed providers for cart info
final cartTotalItemsProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

final cartTotalPriceProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
});
