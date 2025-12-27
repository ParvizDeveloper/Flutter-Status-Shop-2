import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../base/local_storage.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/cart_provider.dart';

class OrderPage extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;

  const OrderPage({
    super.key,
    required this.totalAmount,
    required this.cartItems,
  });

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _deliveryAddressController = TextEditingController();

  String? _selectedBranch;
  String _paymentMethod = "cash";
  String _deliveryType = "pickup";
  String _userEmail = "";

  /// Города многоязычные
  final Map<String, Map<String, Map<String, String>>> branches = {
    "tashkent": {
      "name": {"ru": "Ташкент", "uz": "Toshkent", "en": "Tashkent"},
      "address": {
        "ru": "Чиланзар, 1-й квартал 59",
        "uz": "Chilonzor, 1-kvartal 59",
        "en": "Chilanzar, Block 1, 59"
      }
    },
    "samarkand": {
      "name": {"ru": "Самарканд", "uz": "Samarqand", "en": "Samarkand"},
      "address": {
        "ru": "ул. Ибн Сино, 24",
        "uz": "Ibn Sino ko‘chasi, 24",
        "en": "Ibn Sino street, 24"
      }
    },
    "bukhara": {
      "name": {"ru": "Бухара", "uz": "Buxoro", "en": "Bukhara"},
      "address": {
        "ru": "ул. Б.Накшбандиддин, 12",
        "uz": "B. Naqshbandi ko‘chasi, 12",
        "en": "B. Naqshbandi street, 12"
      }
    },
  };

  bool loading = true;

  /// Перевод
  String tr(String ru, String uz, String en) {
    final lang =
        Provider.of<LanguageProvider>(context, listen: false).localeCode;
    if (lang == "ru") return ru;
    if (lang == "uz") return uz;
    return en;
  }

  /// Перевод названий городов
  String trCity(String key) {
    final lang =
        Provider.of<LanguageProvider>(context, listen: false).localeCode;
    return branches[key]!["name"]![lang] ?? branches[key]!["name"]!["ru"]!;
  }

  /// Перевод адресов
  String trAddress(String key) {
    final lang =
        Provider.of<LanguageProvider>(context, listen: false).localeCode;
    return branches[key]!["address"]![lang] ?? branches[key]!["address"]!["ru"]!;
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  /// Генерация короткого красивого ID как Uzum
  String generateShortOrderId() {
    const chars = "ABCDEF0123456789";
    String id = "";
    for (int i = 0; i < 6; i++) {
      id += chars[(DateTime.now().microsecondsSinceEpoch + i) % chars.length];
    }
    return "UZ-$id";
  }

  Future<void> loadUser() async {
    final user = await LocalStorage.readUserFromTxt();

    _nameController.text =
        "${user['name'] ?? ''} ${user['surname'] ?? ''}".trim();
    _phoneController.text = user['phone'] ?? '';
    _userEmail = user['email'] ?? '';

    final ruCity = user['city'] ?? "Ташкент";
    if (ruCity == "Ташкент") _selectedBranch = "tashkent";
    else if (ruCity == "Самарканд") _selectedBranch = "samarkand";
    else if (ruCity == "Бухара") _selectedBranch = "bukhara";
    else _selectedBranch = "tashkent";

    setState(() => loading = false);
  }

  Future<void> submitOrder() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      _show(tr("Введите имя и телефон", "Ism va telefon kiriting", "Enter name and phone"));
      return;
    }

    if (_deliveryType == "delivery" &&
        _deliveryAddressController.text.trim().isEmpty) {
      _show(tr("Укажите адрес доставки", "Manzilni kiriting", "Enter delivery address"));
      return;
    }

    final uid = await ApiService.uid();
    if (uid == null) return;

    final shortId = generateShortOrderId();
    final orderId = "${uid}_${DateTime.now().millisecondsSinceEpoch}";

    final List<Map<String, dynamic>> items =
        widget.cartItems.map((item) => Map<String, dynamic>.from(item)).toList();

    final payload = {
      "uid": uid,
      "email": _userEmail,
      "name": _nameController.text.trim(),
      "phone": _phoneController.text.trim(),
      "branch": trCity(_selectedBranch!),
      "branch_key": _selectedBranch,
      "branch_address": trAddress(_selectedBranch!),
      "delivery_type": _deliveryType,
      "delivery_address": _deliveryType == "delivery"
          ? _deliveryAddressController.text.trim()
          : null,
      "payment_method": _paymentMethod,
      "total": widget.totalAmount,
      "items": items
    };
    try {
      await ApiService.createOrder(payload);
      context.read<CartProvider>().clear();
      _show(tr("Заказ оформлен!", "Buyurtma bajarildi!", "Order placed!"));
      Navigator.pushReplacementNamed(context, "/my_orders");
    } catch (e) {
      _show(tr("Ошибка оформления", "Xatolik", "Order failed"));
    }
  }

  void _show(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFFE53935);

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr("Оформление заказа", "Buyurtma berish", "Checkout"),
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: tr("Имя и фамилия", "Ism va familiya", "Full name"),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: tr("Номер телефона", "Telefon raqami", "Phone number"),
              ),
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tr("Тип получения", "Olish turi", "Receive method"),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),

            Row(
              children: [
                Radio<String>(
                  value: "pickup",
                  groupValue: _deliveryType,
                  onChanged: (v) => setState(() => _deliveryType = v!),
                ),
                Text(tr("Самовывоз", "Olib ketish", "Pickup")),
                const SizedBox(width: 16),
                Radio<String>(
                  value: "delivery",
                  groupValue: _deliveryType,
                  onChanged: (v) => setState(() => _deliveryType = v!),
                ),
                Text(tr("Доставка до дома", "Uyga yetkazish", "Delivery")),
              ],
            ),

            DropdownButtonFormField<String>(
              value: _selectedBranch,
              decoration: InputDecoration(
                labelText: tr("Выберите филиал", "Filial tanlang", "Choose branch"),
              ),
              items: branches.keys
                  .map((key) =>
                      DropdownMenuItem(value: key, child: Text(trCity(key))))
                  .toList(),
              onChanged: (v) => setState(() => _selectedBranch = v),
            ),

            if (_selectedBranch != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  trAddress(_selectedBranch!),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

            if (_deliveryType == "delivery") ...[
              const SizedBox(height: 16),
              TextField(
                controller: _deliveryAddressController,
                decoration: InputDecoration(
                  labelText: tr(
                      "Адрес доставки (город, улица, дом)",
                      "Manzil (shahar, ko‘cha, uy)",
                      "Delivery address"),
                ),
              ),
            ],

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tr("Способ оплаты", "To'lov turi", "Payment method"),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),

            Row(
              children: [
                Radio<String>(
                  value: "cash",
                  groupValue: _paymentMethod,
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                ),
                Text(tr("Наличные", "Naqd", "Cash")),
              ],
            ),

            Row(
              children: [
                Radio<String>(
                  value: "card",
                  groupValue: _paymentMethod,
                  onChanged: (v) {
                    setState(() => _paymentMethod = v!);
                    _show(
                      tr(
                        "Оплата картой — в разработке",
                        "Karta orqali to'lov ishlab chiqilmoqda",
                        "Card payment coming soon",
                      ),
                    );
                  },
                ),
                Text(tr("Карта", "Karta", "Card")),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: redColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  "${tr("Оформить заказ", "Buyurtma berish", "Place order")} (${widget.totalAmount.toStringAsFixed(0)} UZS)",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
