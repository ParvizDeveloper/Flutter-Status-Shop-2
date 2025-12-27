import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager extends ChangeNotifier {
  Locale _currentLocale = const Locale('ru');

  Locale get locale => _currentLocale;

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_lang') ?? 'ru';
    _currentLocale = Locale(lang);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lang', code);
    _currentLocale = Locale(code);
    notifyListeners();
  }
}
