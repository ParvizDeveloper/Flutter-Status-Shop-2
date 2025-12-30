import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartStorage {
  static const _cartKey = 'user_cart';

  static Future<void> addToCart(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> cart = await getCart();
    cart.add(item);
    await prefs.setString(_cartKey, jsonEncode(cart));
  }

  static Future<void> setCart(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartKey, jsonEncode(items));
  }

  static Future<List<Map<String, dynamic>>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cartKey);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  static Future<void> removeFromCart(String tag) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = await getCart();
    cart.removeWhere((item) => item['tag'] == tag);
    await prefs.setString(_cartKey, jsonEncode(cart));
  }
}
