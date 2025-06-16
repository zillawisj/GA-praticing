import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:ecommerce_app/src/features/authentication/data/fake_auth_repository.dart';
import 'package:ecommerce_app/src/features/cart/data/local/local_cart_repository.dart';
import 'package:ecommerce_app/src/features/cart/data/remote/remote_cart_repository.dart';
import 'package:ecommerce_app/src/features/cart/domain/cart.dart';
import 'package:ecommerce_app/src/features/cart/domain/item.dart';
import 'package:ecommerce_app/src/features/cart/domain/mutable_cart.dart';

import 'package:ecommerce_app/src/features/products/domain/product.dart';
import 'package:ecommerce_app/src/features/products/data/fake_products_repository.dart';

part 'cart_service.g.dart';

class CartService {
  CartService(this.ref);
  final Ref ref;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<Cart> _fetchCart() {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      return ref.read(remoteCartRepositoryProvider).fetchCart(user.uid);
    } else {
      return ref.read(localCartRepositoryProvider).fetchCart();
    }
  }

  Future<void> _setCart(Cart cart) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await ref.read(remoteCartRepositoryProvider).setCart(user.uid, cart);
    } else {
      await ref.read(localCartRepositoryProvider).setCart(cart);
    }
  }

  Future<void> setItem(Item item) async {
    final cart = await _fetchCart();
    final updated = cart.setItem(item);
    await _setCart(updated);
  }

  Future<void> addItem(Item item) async {
    final cart = await _fetchCart();
    final updated = cart.addItem(item);
    await _setCart(updated);

    final productsList = await ref.read(productsListFutureProvider.future);
    final product = productsList.firstWhereOrNull((p) => p.id == item.productId);

    if (product != null) {
      await _analytics.logAddToCart(
        currency: 'THB',
        value: product.price * item.quantity,
        items: [
          AnalyticsEventItem(
            itemId: product.id,
            itemName: product.title,
            quantity: item.quantity,
            price: product.price/1000000,
          ),
        ],
      );
    } else {
      print('[DEBUG] product not found: ${item.productId}');
    }
  }

  Future<void> removeItemById(ProductID productId) async {
    final cart = await _fetchCart();
    final quantity = cart.items[productId];

    final updated = cart.removeItemById(productId);
    await _setCart(updated);

    final productsList = await ref.read(productsListFutureProvider.future);
    final product = productsList.firstWhereOrNull((p) => p.id == productId);

    if (quantity != null && product != null) {
      await _analytics.logRemoveFromCart(
        currency: 'THB',
        value: product.price * quantity,
        items: [
          AnalyticsEventItem(
            itemId: product.id,
            itemName: product.title,
            quantity: quantity,
            price: product.price/1000000,
          ),
        ],
      );
    } else {
      print('[DEBUG] product or quantity not found when removing: $productId');
    }
  }

}

@Riverpod(keepAlive: true)
CartService cartService(Ref ref) => CartService(ref);

@Riverpod(keepAlive: true)
Stream<Cart> cart(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user != null) {
    return ref.watch(remoteCartRepositoryProvider).watchCart(user.uid);
  } else {
    return ref.watch(localCartRepositoryProvider).watchCart();
  }
}

@Riverpod(keepAlive: true)
int cartItemsCount(Ref ref) {
  return ref.watch(cartProvider).maybeMap(
    data: (cart) => cart.value.items.length,
    orElse: () => 0,
  );
}

@riverpod
double cartTotal(Ref ref) {
  final cart = ref.watch(cartProvider).value ?? const Cart();
  final productsList = ref.watch(productsListStreamProvider).value ?? [];
  if (cart.items.isNotEmpty && productsList.isNotEmpty) {
    var total = 0.0;
    for (final item in cart.items.entries) {
      final product =
      productsList.firstWhere((product) => product.id == item.key);
      total += product.price * item.value;
    }
    return total;
  } else {
    return 0.0;
  }
}

@riverpod
int itemAvailableQuantity(Ref ref, Product product) {
  final cart = ref.watch(cartProvider).value;
  if (cart != null) {
    final quantity = cart.items[product.id] ?? 0;
    return max(0, product.availableQuantity - quantity);
  } else {
    return product.availableQuantity;
  }
}
