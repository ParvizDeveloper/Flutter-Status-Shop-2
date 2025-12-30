import 'package:flutter/foundation.dart';
import '../base/cart_storage.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  void seedFromBackend(List<Map<String, dynamic>> items) {
    _items
      ..clear()
      ..addAll(items);
    notifyListeners();
    CartStorage.setCart(_items);
  }

  void addItem(Map<String, dynamic> item) {
    _items.add(item);
    notifyListeners();
    CartStorage.addToCart(item);
  }

  Map<String, dynamic>? removeByTag(String tag) {
    final idx = _items.indexWhere((e) => e['tag'] == tag);
    if (idx >= 0) {
      final removed = _items.removeAt(idx);
      notifyListeners();
      CartStorage.removeFromCart(tag);
      return removed;
    }
    return null;
  }

  void clear() {
    _items.clear();
    notifyListeners();
    CartStorage.clearCart();
  }
}
