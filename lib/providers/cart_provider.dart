import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get total => product.price * quantity;
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};
  
  int get itemCount => _items.length;
  
  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalAmount => _items.values.fold(0, (sum, item) => sum + item.total);

  void addItem(ProductModel product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items[productId]!.quantity--;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  void increaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
      notifyListeners();
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (_items.containsKey(productId)) {
      if (quantity <= 0) {
        _items.remove(productId);
      } else {
        _items[productId]!.quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  List<OrderItem> toOrderItems() {
    return _items.values.map((cartItem) => OrderItem(
      productId: cartItem.product.id,
      productName: cartItem.product.name,
      price: cartItem.product.price,
      quantity: cartItem.quantity,
      imageUrl: cartItem.product.imageUrl,
    )).toList();
  }

  bool isInCart(String productId) => _items.containsKey(productId);
  
  int getQuantity(String productId) => _items[productId]?.quantity ?? 0;
}
