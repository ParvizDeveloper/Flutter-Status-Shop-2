import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'providers/language_provider.dart';
import 'providers/cart_provider.dart';

import 'components/login.dart';
import 'components/registration.dart';
import 'pages/mainpage.dart';
import 'components/profile_page.dart';
import 'pages/product_page.dart';
import 'pages/my_orders.dart';
import 'base/translation.dart';
import 'pages/locations_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final langProvider = LanguageProvider();
  await langProvider.loadLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: langProvider),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const StatusShopApp(),
    ),
  );
}

class StatusShopApp extends StatelessWidget {
  const StatusShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Status Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: const ConnectionChecker(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/registration': (_) => const RegistrationScreen(),
        '/mainpage': (_) => const MainPage(),
        '/profile': (_) => const ProfilePage(),
        '/product': (_) => const ProductPage(product: {}),
        '/my_orders': (_) => const MyOrdersPage(),
        '/locations': (_) => const LocationsPage(),
      },
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                         CONNECTION + AUTH CHECKER                           */
/* -------------------------------------------------------------------------- */

class ConnectionChecker extends StatefulWidget {
  const ConnectionChecker({super.key});

  @override
  State<ConnectionChecker> createState() => _ConnectionCheckerState();
}

class _ConnectionCheckerState extends State<ConnectionChecker> {
  bool _hasInternet = true;
  bool _checkedAuth = false;
  bool _loggedIn = false;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _checkAuth();

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final connected =
          results.isNotEmpty && results.first != ConnectivityResult.none;
      setState(() => _hasInternet = connected);
    });
  }

  Future<void> _initConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final connected =
        results.isNotEmpty && results.first != ConnectivityResult.none;
    setState(() => _hasInternet = connected);
  }

  /// 🔐 ГЛОБАЛЬНЫЙ AUTH CHECK
  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('token');
    final uid = prefs.getString('uid');

    setState(() {
      _loggedIn = token != null && uid != null;
      _checkedAuth = true;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInternet) {
      return const NoInternetScreen();
    }

    if (!_checkedAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _loggedIn ? const MainPage() : const LoginScreen();
  }
}

/* -------------------------------------------------------------------------- */
/*                              NO INTERNET                                   */
/* -------------------------------------------------------------------------- */

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.redAccent, size: 80),
            const SizedBox(height: 20),
            Text(
              tr(context, 'cart_empty'),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('Проверьте соединение и перезапустите приложение.'),
          ],
        ),
      ),
    );
  }
}
