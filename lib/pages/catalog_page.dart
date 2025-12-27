import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/language_provider.dart';
import '../pages/product_page.dart';
import '../pages/home_page.dart';

class CatalogPage extends StatefulWidget {
  final String? preselectedCategory;

  const CatalogPage({super.key, this.preselectedCategory});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late String _selectedCategory;
  String _searchQuery = '';

  final List<String> categoriesRu = [
    'Все',
    'Текстиль',
    'Термо винил',
    'DTF материалы',
    'Сублимационные кружки',
    'Оборудование',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.preselectedCategory ?? 'Все';
  }

  String tr(BuildContext context, String ru, String uz, String en) {
    final lang = context.watch<LanguageProvider>().localeCode;
    if (lang == 'ru') return ru;
    if (lang == 'uz') return uz;
    return en;
  }

  String trCategory(BuildContext context, String ru) {
    return {
      "Все": tr(context, "Все", "Barchasi", "All"),
      "Текстиль": tr(context, "Текстиль", "Tekstil", "Textile"),
      "Термо винил": tr(context, "Термо винил", "Termo vinil", "Heat vinyl"),
      "DTF материалы": tr(context, "DTF материалы", "DTF materiallari", "DTF materials"),
      "Сублимационные кружки":
          tr(context, "Сублимационные кружки", "Sublimatsiya krujkalar", "Sublimation mugs"),
      "Оборудование": tr(context, "Оборудование", "Uskunalar", "Equipment"),
    }[ru] ?? ru;
  }

  String trName(BuildContext context, Map product) {
    final lang = context.watch<LanguageProvider>().localeCode;
    final obj = product['name'];
    if (obj is Map) return obj[lang] ?? obj['ru'];
    return obj.toString();
  }

  bool _matchesSearch(BuildContext context, Map product) {
    if (_searchQuery.isEmpty) return true;
    return trName(context, product)
        .toLowerCase()
        .contains(_searchQuery.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFFE53935);
    final appBarTitle = tr(context, 'Каталог', 'Katalog', 'Catalog');

    final filtered = allProducts.where((p) {
      final categoryMatch = switch (_selectedCategory) {
        'Все' => true,
        'Текстиль' => p['type'] == 'clothes' || p['type'] == 'oversize',
        'Термо винил' => p['type'] == 'vinil',
        'DTF материалы' => p['type'] == 'dtf',
        'Сублимационные кружки' => p['type'] == 'cups',
        'Оборудование' => p['type'] == 'equipment',
        _ => true,
      };

      final searchMatch = _matchesSearch(context, p);

      return categoryMatch && searchMatch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      drawer: _buildCategoryDrawer(context),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          appBarTitle,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Column(
        children: [
          _buildSearchField(context),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final product = filtered[index];
                return _productCard(context, product);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------
  // 🔍 SEARCH
  // ------------------------------------------------
  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: tr(context, 'Поиск товара', 'Mahsulot qidirish', 'Search product'),
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------
  // ☰ DRAWER
  // ------------------------------------------------
  Widget _buildCategoryDrawer(BuildContext context) {
    const redColor = Color(0xFFE53935);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: redColor),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                tr(context, 'Категории', 'Kategoriyalar', 'Categories'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              children: categoriesRu.map((catRu) {
                final selected = catRu == _selectedCategory;

                return ListTile(
                  leading: Icon(
                    Icons.label_outline,
                    color: selected ? redColor : Colors.grey,
                  ),
                  title: Text(
                    trCategory(context, catRu),
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      color: selected ? redColor : Colors.black,
                    ),
                  ),
                  onTap: () {
                    setState(() => _selectedCategory = catRu);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------
  // 🛒 PRODUCT CARD
  // ------------------------------------------------
  Widget _productCard(BuildContext context, Map<String, dynamic> product) {
    const redColor = Color(0xFFE53935);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductPage(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 140,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                product['images'][0],
                fit: BoxFit.contain,
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trName(context, product),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${NumberFormat('#,###', 'ru').format(product['price'])} UZS',
                      style: const TextStyle(
                        color: redColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      height: 34,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: redColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tr(context, 'Подробнее', 'Batafsil', 'More'),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
