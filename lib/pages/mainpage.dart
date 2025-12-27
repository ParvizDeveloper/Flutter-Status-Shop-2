import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';
import 'catalog_page.dart';
import 'cart_page.dart';
import '../components/profile_page.dart';
import '../providers/language_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    CatalogPage(),
    CartPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Функция перевода
  String tr(BuildContext ctx, String ru, String uz, String en) {
    final lang = Provider.of<LanguageProvider>(ctx).localeCode;
    if (lang == 'ru') return ru;
    if (lang == 'uz') return uz;
    return en;
  }

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFFE53935);

    // Локализованные подписи вкладок
    final tHome = tr(context, 'Главная', 'Bosh sahifa', 'Home');
    final tCatalog = tr(context, 'Каталог', 'Katalog', 'Catalog');
    final tCart = tr(context, 'Корзина', 'Savatcha', 'Cart');
    final tProfile = tr(context, 'Профиль', 'Profil', 'Profile');

    return Scaffold(
      backgroundColor: Colors.white,

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          selectedItemColor: redColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 5,
          onTap: _onItemTapped,

          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: tHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.category_outlined),
              activeIcon: const Icon(Icons.category),
              label: tCatalog,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart_outlined),
              activeIcon: const Icon(Icons.shopping_cart),
              label: tCart,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: tProfile,
            ),
          ],
        ),
      ),
    );
  }
}
