import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../pages/order_page.dart';
import '../providers/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String tr(String lang, String ru, String uz, String en) {
    if (lang == 'ru') return ru;
    if (lang == 'uz') return uz;
    return en;
  }
  String trName(String lang, Map item) {
    final m = item['name'];
    if (m is Map) return m[lang] ?? m['ru'] ?? '';
    return m.toString();
  }
  String formatPrice(num value) {
    final formatter = NumberFormat('#,###', 'ru');
    return '${formatter.format(value)} UZS';
  }

  String? _uid;
  String? _token;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final uid = await ApiService.uid();
    final tok = await ApiService.token();
    _uid = uid;
    _token = tok;
    if (mounted) setState(() {});
    if (uid != null && tok != null) {
      final docs = await ApiService.getCart(uid);
      final items = docs.map((d) => d['data'] as Map<String, dynamic>).toList();
      if (mounted) {
        context.read<CartProvider>().seedFromBackend(items);
      }
    }
  }

  Future<void> _refresh() async {
    if (_uid != null) {
      final docs = await ApiService.getCart(_uid!);
      final items = docs.map((d) => d['data'] as Map<String, dynamic>).toList();
      context.read<CartProvider>().seedFromBackend(items);
    }
  }

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFFE53935);
    final lang = context.watch<LanguageProvider>().localeCode;
    final cart = context.watch<CartProvider>();

    if (_uid == null || _token == null) {
      return Scaffold(
        body: Center(
          child: Text(
            tr(lang, 'Войдите в аккаунт, чтобы просмотреть корзину', 'Kirish talab qilinadi', 'Login to view cart'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(lang, 'Корзина', 'Savat', 'Cart'),
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Builder(
        builder: (context) {
          final items = cart.items;
          if (items.isEmpty) return _emptyCart(lang, context);
          double total = 0;
          for (var item in items) {
            total += (item['total'] as num).toDouble();
          }
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final img = item['image'] as String? ?? '';
                      final isNet = img.startsWith('http');
                      final imageWidget = isNet
                          ? Image.network(img, width: 80, height: 80, fit: BoxFit.cover)
                          : Image.asset(img, width: 80, height: 80, fit: BoxFit.cover);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(borderRadius: BorderRadius.circular(8), child: imageWidget),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trName(lang, item),
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildItemDetails(lang, item),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatPrice(item['total']),
                                    style: const TextStyle(color: redColor, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () async {
                                final removed = context.read<CartProvider>().removeByTag(item['tag']);
                                try {
                                  await ApiService.deleteCartItem(_uid!, item['tag']);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Удалено')));
                                } catch (e) {
                                  if (removed != null) {
                                    context.read<CartProvider>().addItem(removed);
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка удаления')));
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr(lang, 'Итого:', 'Jami:', 'Total:'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          formatPrice(total),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: redColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final cartItems = List<Map<String, dynamic>>.from(items);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderPage(totalAmount: total, cartItems: cartItems),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: redColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          tr(lang, 'Оформить заказ', 'Buyurtma berish', 'Checkout'),
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _emptyCart(String lang, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/empty_cart.png', width: 180),

            const SizedBox(height: 20),

            Text(
              tr(lang, 'Ваша корзина пуста', 'Savat bo‘sh', 'Your cart is empty'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              tr(
                lang,
                'Добавьте товары, чтобы оформить заказ.',
                'Buyurtma uchun mahsulot qo‘shing.',
                'Add items to proceed with your order.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/mainpage'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                tr(lang, 'Вернуться на главную', 'Bosh sahifaga qaytish', 'Back to home'),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetails(String lang, Map<String, dynamic> item) {
    final type = item['type'];

    if (type == 'vinil') {
      return Text(
        '${tr(lang, 'Метры', 'Metr', 'Meters')}: ${item['meters']} м',
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      );
    }

    if (type == 'clothes' || type == 'oversize') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${tr(lang, 'Размер', 'O‘lcham', 'Size')}: ${item['size']}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '${tr(lang, 'Количество', 'Soni', 'Quantity')}: ${item['quantity']}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      );
    }

    return Text(
      '${tr(lang, 'Количество', 'Soni', 'Quantity')}: ${item['quantity']}',
      style: const TextStyle(color: Colors.grey, fontSize: 13),
    );
  }
}
