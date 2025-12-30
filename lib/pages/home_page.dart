import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/language_provider.dart';
import '../pages/product_page.dart';
import '../pages/catalog_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  List<Map<String, dynamic>> _products = [];
  List<String> _types = [];
  Map<String, String> _asObj(dynamic v) {
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), val?.toString() ?? ''));
    }
    final s = v?.toString() ?? '';
    if (s.trim().startsWith('{')) {
      try {
        final obj = Map<String, dynamic>.from(ApiService.parseJsonMap(s) ?? {});
        if (obj.isNotEmpty) {
          return obj.map((k, val) => MapEntry(k.toString(), val?.toString() ?? ''));
        }
      } catch (_) {
        // regex fallback
        String? rx(String key) {
          final re = RegExp('"$key"\\s*:\\s*"([^"]*)"');
          final match = re.firstMatch(s);
          return match != null ? match.group(1) : null;
        }
        final ru = rx('ru'), uz = rx('uz'), en = rx('en');
        return {
          if (ru != null) 'ru': ru,
          if (uz != null) 'uz': uz,
          if (en != null) 'en': en,
        };
      }
    }
    return {'en': s};
  }

  String formatPrice(num price) {
    final formatter = NumberFormat('#,###', 'ru');
    return '${formatter.format(price)} UZS';
  }

  String tr(BuildContext context, String ru, String uz, String en) {
    final lang = context.watch<LanguageProvider>().localeCode;
    if (lang == 'ru') return ru;
    if (lang == 'uz') return uz;
    return en;
  }

  String trName(BuildContext context, Map product) {
    final lang = context.watch<LanguageProvider>().localeCode;
    final name = product['name'];
    if (name is Map) return name[lang] ?? name['en'] ?? name['ru'];
    return name.toString();
  }

  @override
  Widget build(BuildContext context) {
    final tCategories = tr(context, "Категории", "Kategoriyalar", "Categories");
    final tPopular = tr(context, "Популярное", "Ommabop", "Popular");
    final tRecommended =
        tr(context, "Рекомендуем", "Tavsiya qilamiz", "Recommended");
    final tAbout = tr(context, "О нас", "Biz haqimizda", "About us");
    final tMore = tr(context, "Подробнее", "Batafsil", "More");

    const redColor = Color(0xFFE53935);

    final featured = _products.take(6).toList();
    final recommended = _products.skip(6).take(6).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 90,
                      ),
                    ),
                  ),

                  _sectionTitle(tCategories),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16),
                      children: [
                        for (final t in _types)
                          _category(context, Icons.label, t),
                      ],
                    ),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 16 / 6.5,
                        child: Image.asset(
                          'assets/images/sale_banner.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  _sectionTitle(tPopular),
                  SizedBox(
                    height: 285,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: featured.length,
                            itemBuilder: (c, i) =>
                                _productCard(context, featured[i], tMore),
                          ),
                  ),

                  _sectionTitle(tRecommended),
                  SizedBox(
                    height: 285,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: recommended.length,
                            itemBuilder: (c, i) =>
                                _productCard(context, recommended[i], tMore),
                          ),
                  ),

                  const SizedBox(height: 40),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            tAbout,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Status Shop\n"
                            "г. Ташкент, Чиланзар 1-й квартал, 59\n"
                            "+998 90 176 01 04\n"
                            "Пн-Сб: 10:00–19:00",
                            style: TextStyle(fontSize: 14, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _category(BuildContext context, IconData icon, String typeText) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CatalogPage(preselectedCategory: typeText),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(icon, color: const Color(0xFFE53935), size: 30),
            ),
            const SizedBox(height: 6),
            Text(
              typeText,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(
      BuildContext context, Map<String, dynamic> product, String tMore) {
    const redColor = Color(0xFFE53935);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductPage(product: product)),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
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
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trName(context, product),
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${NumberFormat('#,###', 'ru').format(num.tryParse((product['price'] ?? 0).toString()) ?? 0)} UZS",
                      style: const TextStyle(
                        color: redColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        height: 34,
                        decoration: BoxDecoration(
                          color: redColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tMore,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _typeText(dynamic type) {
    final lang = context.read<LanguageProvider>().localeCode;
    final obj = _asObj(type);
    return obj[lang] ?? obj['en'] ?? obj['ru'] ?? '';
  }

  Future<void> _load() async {
    final list = await ApiService.getProducts(page: 1, limit: 100);
    setState(() {
      _products = list;
      _types = {
        for (final p in list) _typeText(p['type'])
      }.where((s) => s.trim().isNotEmpty).toList();
      _loading = false;
    });
  }
}
