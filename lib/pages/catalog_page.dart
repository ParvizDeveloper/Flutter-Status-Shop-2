import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/language_provider.dart';
import '../pages/product_page.dart';
import '../services/api_service.dart';

class CatalogPage extends StatefulWidget {
  final String? preselectedCategory;

  const CatalogPage({super.key, this.preselectedCategory});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  String _selectedCategory = 'Все';
  String _searchQuery = '';
  bool _loading = true;
  List<Map<String, dynamic>> _products = [];
  List<String> _categories = ['Все'];
  num? _minPrice;
  num? _maxPrice;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.preselectedCategory ?? 'Все';
    _loadProducts();
  }

  String tr(BuildContext context, String ru, String uz, String en) {
    final lang = context.watch<LanguageProvider>().localeCode;
    if (lang == 'ru') return ru;
    if (lang == 'uz') return uz;
    return en;
  }

  String _typeText(dynamic type) {
    final lang = Provider.of<LanguageProvider>(context, listen: false).localeCode;
    if (type is Map) {
      final m = type.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
      return m[lang] ?? m['en'] ?? m['ru'] ?? '';
    }
    final s = type?.toString() ?? '';
    if (s.trim().startsWith('{')) {
      // Try strict JSON parse first
      final obj = ApiService.parseJsonMap(s);
      if (obj != null && obj.isNotEmpty) {
        final m = obj.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
        return m[lang] ?? m['en'] ?? m['ru'] ?? '';
      }
      // Fallback: regex extract "ru"/"uz"/"en" from json-like string
      String? rx(String key) {
        final re = RegExp('"$key"\\s*:\\s*"([^"]*)"');
        final match = re.firstMatch(s);
        return match != null ? match.group(1) : null;
      }
      return rx(lang) ?? rx('en') ?? rx('ru') ?? s;
    }
    return s;
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

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    final list = await ApiService.getProducts(page: 1, limit: 200);
    setState(() {
      _products = list;
      final types = {
        for (final p in list) _typeText(p['type'])
      }..removeWhere((t) => t.trim().isEmpty);
      _categories = ['Все', ...types.toList()];
      if (list.isNotEmpty) {
        final prices = list
            .map((p) => num.tryParse((p['price'] ?? 0).toString()) ?? 0)
            .toList();
        if (prices.isNotEmpty) {
          prices.sort();
          _minPrice = prices.first;
          _maxPrice = prices.last;
        }
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFFE53935);
    final appBarTitle = tr(context, 'Каталог', 'Katalog', 'Catalog');

    final filtered = _products.where((p) {
      final matchCategory = _selectedCategory == 'Все'
          ? true
          : _typeText(p['type']).toLowerCase() ==
              _selectedCategory.toLowerCase();
      final searchMatch = _matchesSearch(context, p);
      final price = num.tryParse((p['price'] ?? 0).toString()) ?? 0;
      final matchPrice = (_minPrice == null || price >= _minPrice!) &&
          (_maxPrice == null || price <= _maxPrice!);
      return matchCategory && searchMatch && matchPrice;
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
          _buildFilters(context),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
  // ⚙️ FILTERS
  // ------------------------------------------------
  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: tr(context, 'Мин. цена', 'Min narx', 'Min price'),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() {
                _minPrice = num.tryParse(v.replaceAll(' ', ''));
              }),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: tr(context, 'Макс. цена', 'Maks narx', 'Max price'),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() {
                _maxPrice = num.tryParse(v.replaceAll(' ', ''));
              }),
            ),
          ),
        ],
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
              children: _categories.map((catRu) {
                final selected = catRu == _selectedCategory;

                return ListTile(
                  leading: Icon(
                    Icons.label_outline,
                    color: selected ? redColor : Colors.grey,
                  ),
                  title: Text(
                    catRu == 'Все' ? tr(context, "Все", "Barchasi", "All") : catRu,
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
              child: Image.network(
                (product['image'] ?? '').toString(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
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
                      '${NumberFormat('#,###', 'ru').format(num.tryParse((product['price'] ?? 0).toString()) ?? 0)} UZS',
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
