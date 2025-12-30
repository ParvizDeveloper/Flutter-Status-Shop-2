import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../providers/cart_provider.dart';

class ProductPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  double _meters = 1.0;
  int _quantity = 1;
  String? _selectedSize;
  final _controller = TextEditingController(text: '1');
  String get lang =>
      Provider.of<LanguageProvider>(context, listen: false).localeCode;
  Map<String, String> _asObj(dynamic v) {
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), val?.toString() ?? ''));
    }
    if (v is String && v.trim().startsWith('{')) {
      try {
        final obj = Map<String, dynamic>.from(ApiService.parseJsonMap(v) ?? {});
        if (obj.isNotEmpty) {
          return obj.map((k, val) => MapEntry(k.toString(), val?.toString() ?? ''));
        }
      } catch (_) {}
    }
    return {'en': v?.toString() ?? ''};
  }

  // -------------------------
  // Get selected language
  // -------------------------

  // Localized name and description
  String pName() {
    final obj = _asObj(widget.product['name']);
    return obj[lang] ?? obj['en'] ?? obj['ru'] ?? '';
  }
  String pDesc() {
    final obj = _asObj(widget.product['description']);
    return obj[lang] ?? obj['en'] ?? obj['ru'] ?? '';
  }
  String pType() {
    final obj = _asObj(widget.product['type']);
    return obj[lang] ?? obj['en'] ?? obj['ru'] ?? '';
  }
  String pColor() {
    final obj = _asObj(widget.product['color']);
    return obj[lang] ?? obj['en'] ?? obj['ru'] ?? '';
  }

  String tr(String ru, String uz, String en) {
    if (lang == 'ru') return ru;
    if (lang == 'uz') return uz;
    return en;
  }

  String formatPrice(num value) {
    final formatter = NumberFormat('#,###', 'ru');
    return '${formatter.format(value)} UZS';
  }

  double get totalPrice {
    final price = widget.product['price'];
    final basePrice = (price is num)
        ? price.toDouble()
        : double.tryParse(price.toString().replaceAll(' ', '')) ?? 0;

    if (pType().toLowerCase() == 'vinil') {
      return basePrice * _meters;
    } else {
      return basePrice * _quantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    const redColor = Color(0xFFE53935);

    final String imageUrl = (product['image'] ?? '').toString();
    final type = pType();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          pName(),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// IMAGE
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 85% ширины экрана
                  final double size = MediaQuery.of(context).size.width * 0.85;
            
                  return Container(
                    height: size,
                    width: size,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            /// COLORS (skip for DB single image; future: use color swatches)

            /// METERS / QUANTITY / SIZE
            if (type.toLowerCase() == 'vinil') 
              _buildMetersInput()
            else if (type.toLowerCase() == 'clothes' || type.toLowerCase() == 'oversize') 
              _buildClothesInput(type)
            else 
              _buildQuantityInput(),

            const SizedBox(height: 20),

            /// CHARACTERISTICS
            _buildCharacteristicsBlock(product['characteristics']),
            const SizedBox(height: 16),

            /// DESCRIPTION
            _buildDescription(pDesc()),
            const SizedBox(height: 20),

            /// DETAILS
            _buildDetails(type, pColor(), (widget.product['tag'] ?? '').toString()),
            const SizedBox(height: 16),

            /// TOTAL
            _buildTotal(redColor),

            const SizedBox(height: 30),

            /// ADD TO CART
            _buildAddToCartButton(redColor, product),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------
  // CHARACTERISTICS BLOCK
  // ---------------------------------------
  Widget _buildCharacteristicsBlock(Map? data) {
    if (data == null || data.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr("Характеристики", "Xususiyatlar", "Specifications"),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),

          ...data.entries.map((e) {
            final key = e.key;
            final v = e.value;

            String value;
            if (v is Map) {
              value = v[lang] ?? v['ru'] ?? v.values.first;
            } else {
              value = v.toString();
            }

            return Text(
              "• ${_translateCharacteristicKey(key)}: $value",
              style: const TextStyle(fontSize: 14),
            );
          }),
        ],
      ),
    );
  }

  String _translateCharacteristicKey(String key) {
    const map = {
      'material': {'ru':'Материал','uz':'Material','en':'Material'},
      'weight': {'ru':'Плотность / Вес','uz':'Zichlik / Og‘irlik','en':'Density / Weight'},
      'sizes': {'ru':'Размеры','uz':'O‘lchamlar','en':'Sizes'},
      'suitable': {'ru':'Подходит для','uz':'Mos keladi','en':'Suitable for'},
      'adjustment': {'ru':'Регулировка','uz':'Sozlash','en':'Adjustment'},
      'uses': {'ru':'Использование','uz':'Qo‘llanilishi','en':'Usage'},
      'width': {'ru':'Ширина','uz':'Eni','en':'Width'},
      'temp': {'ru':'Температура','uz':'Harorat','en':'Temperature'},
      'time': {'ru':'Время','uz':'Vaqt','en':'Time'},
      'plate': {'ru':'Размер пластины','uz':'Plita o‘lchami','en':'Plate size'},
      'power': {'ru':'Мощность','uz':'Quvvat','en':'Power'},
      'volume': {'ru':'Объём','uz':'Hajm','en':'Volume'},
      'cut_width': {'ru':'Ширина резки','uz':'Kesish eni','en':'Cut width'},
      'precision': {'ru':'Точность','uz':'Aniqlik','en':'Precision'},
      'type': {'ru':'Тип','uz':'Turi','en':'Type'},
    };

    return map[key]?[lang] ?? key;
  }

  // ---------------------------------------
  // DESCRIPTION
  // ---------------------------------------
  Widget _buildDescription(String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr("Описание", "Tavsif", "Description"),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),

          Text(desc, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  // ---------------------------------------
  // DETAILS BLOCK (Type, Color, Tag)
  // ---------------------------------------
  Widget _buildDetails(String type, String color, String tag) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr("Характеристики товара", "Mahsulot maʼlumotlari", "Product details"),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text("${tr('Тип', 'Turi', 'Type')}: $type"),
          Text("${tr('Цвет', 'Rang', 'Color')}: $color"),
          Text("Tag: $tag"),
          if ((widget.product['amount'] ?? 0).toString().isNotEmpty) 
            Text("${tr('В наличии', 'Mavjud', 'In stock')}: ${(widget.product['amount'] ?? 0)}"),
        ],
      ),
    );
  }

  // ---------------------------------------
  // METERS
  // ---------------------------------------
  Widget _buildMetersInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr("Метры:", "Metrlar:", "Meters:"),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) {
              setState(() => _meters = double.tryParse(val.replaceAll(",", ".")) ?? 1);
            },
            decoration: InputDecoration(
              hintText: tr("Введите количество метров", "Metr miqdorini kiriting",
                  "Enter meters"),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 8),
          Text(
            tr("Цена за 1 метр", "1 metr narxi", "Price per 1 meter") +
                ": 140 000 UZS",
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------
  // CLOTHES
  // ---------------------------------------
  Widget _buildClothesInput(String type) {
    final sizes = type == 'oversize'
        ? ['M', 'L', 'XL']
        : ['S', 'M', 'L', 'XL', 'XXL'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr("Выберите размер:", "O‘lchamni tanlang:", "Choose size:"),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            children: sizes.map((s) {
              final selected = s == _selectedSize;
              return ChoiceChip(
                label: Text(s),
                selected: selected,
                onSelected: (_) => setState(() => _selectedSize = s),
                selectedColor: Colors.redAccent,
                labelStyle:
                    TextStyle(color: selected ? Colors.white : Colors.black),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),
          _buildQuantityInput(),
        ],
      ),
    );
  }

  // ---------------------------------------
  // QUANTITY
  // ---------------------------------------
  Widget _buildQuantityInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          tr("Количество:", "Soni:", "Quantity:"),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),

        Row(
          children: [
            IconButton(
              onPressed: () {
                if (_quantity > 1) setState(() => _quantity--);
              },
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text('$_quantity', style: const TextStyle(fontSize: 18)),
            IconButton(
              onPressed: () => setState(() => _quantity++),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------
  // TOTAL
  // ---------------------------------------
  Widget _buildTotal(Color redColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tr("Итого:", "Jami:", "Total:"),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          Text(
            formatPrice(totalPrice),
            style: TextStyle(
                color: redColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------
// ADD TO CART BUTTON — with color support
// ---------------------------------------
  Widget _buildAddToCartButton(Color redColor, Map<String, dynamic> product) {
  return SizedBox(
    width: double.infinity,

    child: ElevatedButton.icon(
      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),

      label: Text(
        tr("Добавить в корзину", "Savatchaga qo‘shish", "Add to cart"),
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),

      style: ElevatedButton.styleFrom(
        backgroundColor: redColor,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      onPressed: () async {
        if (product['type'] == 'clothes' && _selectedSize == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(
                tr("Выберите размер", "O‘lcham tanlang", "Select size"))),
          );
          return;
        }

        final uid = await ApiService.uid();
        if (uid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(
                tr("Войдите в аккаунт", "Akkauntga kiring", "Sign in first"))),
          );
          return;
        }

        final itemId =
            '${pType()}_${DateTime.now().millisecondsSinceEpoch}';

        // Цвет: берем строку из product['color'] с учетом языка
        String colorName = "";
        final col = product['color'];
        if (col is Map) {
          colorName = col[lang] ?? col['en'] ?? col['ru'] ?? '';
        } else {
          colorName = col?.toString() ?? '';
        }

        // 🔥 Сохраняем полный набор данных
        final item = {
          'name': product['name'],          // Map: ru/uz/en
          'description': product['description'], 
          'type': product['type'],
          'image': product['image'],
          'color': colorName,
          'price': product['price'],
          'quantity': _quantity,
          'meters': pType().toLowerCase() == 'vinil' ? _meters : 0,
          'size': _selectedSize ?? '',
          'total': totalPrice,
          'tag': itemId,
        };

        context.read<CartProvider>().addItem(item);
        try {
          await ApiService.addCartItem(uid, item);
        } catch (e) {
          context.read<CartProvider>().removeByTag(itemId);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка добавления')));
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
              tr("🛒 Товар добавлен в корзину", "🛒 Tovar savatchaga qo‘shildi",
                  "🛒 Added to cart"))),
          );
        },
      ),
    );
  }
}
