import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  /// Текущий язык ('ru', 'uz', 'en')
  String _localeCode = 'ru';

  String get localeCode => _localeCode;

  /// Поддерживаемые языки
  static const supported = ['ru', 'uz', 'en'];

  /// Словарь переводов
  static const Map<String, Map<String, String>> _t = {
    'profile': {'ru': 'Профиль', 'uz': 'Profil', 'en': 'Profile'},
    'saved': {'ru': 'Данные обновлены', 'uz': 'Maʼlumotlar saqlandi', 'en': 'Saved successfully'},

    'personal_data': {'ru': 'Личные данные', 'uz': 'Shaxsiy maʼlumotlar', 'en': 'Personal data'},
    'name': {'ru': 'Имя', 'uz': 'Ism', 'en': 'Name'},
    'company': {'ru': 'Компания', 'uz': 'Kompaniya', 'en': 'Company'},
    'position': {'ru': 'Должность', 'uz': 'Lavozim', 'en': 'Position'},
    'city': {'ru': 'Город', 'uz': 'Shahar', 'en': 'City'},
    'phone': {'ru': 'Телефон', 'uz': 'Telefon', 'en': 'Phone'},

    'settings': {'ru': 'Настройки', 'uz': 'Sozlamalar', 'en': 'Settings'},
    'language': {'ru': 'Язык интерфейса', 'uz': 'Tilni tanlash', 'en': 'Language'},
    'save': {'ru': 'Сохранить изменения', 'uz': 'O‘zgarishlarni saqlash', 'en': 'Save changes'},
    'help': {'ru': 'Помощь', 'uz': 'Yordam', 'en': 'Help'},

    'user': {'ru': 'Пользователь', 'uz': 'Foydalanuvchi', 'en': 'User'},

    'my_orders': {'ru': 'Мои заказы', 'uz': 'Buyurtmalarim', 'en': 'My orders'},
    'my_reviews': {'ru': 'Мои отзывы', 'uz': 'Sharhlarim', 'en': 'My reviews'},
    'privacy': {'ru': 'Конфиденциальность', 'uz': 'Maxfiylik', 'en': 'Privacy'},
  };

  /// Получение перевода по ключу
  String t(String key) {
    final row = _t[key];
    if (row == null) return key; // если ключ не найден — вернуть его
    return row[_localeCode] ?? row.values.first;
  }

  /// Загрузка языка при старте приложения
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('locale_code');
    if (saved != null && supported.contains(saved)) {
      _localeCode = saved;
      notifyListeners();
    }
  }

  /// Изменение языка
  Future<void> setLocale(String code) async {
    if (!supported.contains(code)) return;

    _localeCode = code;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale_code', code);

    notifyListeners();
  }
}
