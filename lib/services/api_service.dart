import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://status-shop-backend-production.up.railway.app/api/v1',
  );

  // ================= STORAGE =================

  static Future<SharedPreferences> _prefs() =>
      SharedPreferences.getInstance();

  static Future<String?> token() async =>
      (await _prefs()).getString('token');

  static Future<String?> uid() async =>
      (await _prefs()).getString('uid');

  static Future<String?> _refreshToken() async =>
      (await _prefs()).getString('refresh_token');

  static Future<void> logout() async {
    final p = await _prefs();
    await p.remove('token');
    await p.remove('uid');
    await p.remove('refresh_token');
  }

  // ================= HELPERS =================

  static bool _isSuccess(int code) => code >= 200 && code < 300;

  static Map<String, dynamic>? _safeJsonMap(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static List<Map<String, dynamic>> _safeJsonList(String body) {
    try {
      final list = jsonDecode(body) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  // ================= REFRESH =================

  static Future<bool> refreshAccessToken() async {
    final rt = await _refreshToken();
    if (rt == null || rt.isEmpty) {
      await logout();
      return false;
    }

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': rt}),
      );

      if (!_isSuccess(res.statusCode)) {
        await logout();
        return false;
      }

      final data = _safeJsonMap(res.body);
      if (data == null) {
        await logout();
        return false;
      }

      final p = await _prefs();

      final at = data['token'];
      if (at is! String || at.isEmpty) {
        await logout();
        return false;
      }
      await p.setString('token', at);

      final newRt = data['refresh_token'];
      if (newRt is String && newRt.isNotEmpty) {
        await p.setString('refresh_token', newRt);
      }

      final newUid = data['uid'];
      if (newUid is String && newUid.isNotEmpty) {
        await p.setString('uid', newUid);
      }

      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  static Future<http.Response> _retryAuthRequest(
    Future<http.Response> Function(String token) exec,
  ) async {
    final t = await token();
    final res = await exec(t ?? '');

    if (res.statusCode != 401 && res.statusCode != 403) {
      return res;
    }

    final refreshed = await refreshAccessToken();
    if (!refreshed) {
      return res;
    }

    final newToken = await token();
    if (newToken == null || newToken.isEmpty) {
      await logout();
      return res;
    }

    return exec(newToken);
  }

  // ================= AUTH =================

  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (!_isSuccess(res.statusCode)) return null;

      final data = _safeJsonMap(res.body);
      if (data == null) return null;

      final p = await _prefs();

      final at = data['token'];
      if (at is String && at.isNotEmpty) {
        await p.setString('token', at);
      }

      final rt = data['refresh_token'];
      if (rt is String && rt.isNotEmpty) {
        await p.setString('refresh_token', rt);
      }

      final uidVal = data['uid'];
      if (uidVal is String && uidVal.isNotEmpty) {
        await p.setString('uid', uidVal);
      }

      return data;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    required String name,
    required String surname,
    String? company,
    String? position,
    String? city,
    String? phone,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'surname': surname,
          'company': company,
          'position': position,
          'city': city,
          'phone': phone,
        }),
      );

      if (!_isSuccess(res.statusCode)) return null;
      return _safeJsonMap(res.body);
    } catch (_) {
      return null;
    }
  }

  // ================= USER =================

  static Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final res = await _retryAuthRequest((t) {
        return http.get(
          Uri.parse('$baseUrl/users/$uid'),
          headers: {'Authorization': 'Bearer $t'},
        );
      });

      if (!_isSuccess(res.statusCode)) return null;
      return _safeJsonMap(res.body);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> updateUser(
      String uid, Map<String, dynamic> patch) async {
    try {
      final res = await _retryAuthRequest((t) {
        return http.patch(
          Uri.parse('$baseUrl/users/$uid'),
          headers: {
            'Authorization': 'Bearer $t',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(patch),
        );
      });

      return _isSuccess(res.statusCode);
    } catch (_) {
      return false;
    }
  }

  // ================= CART =================

  static Future<List<Map<String, dynamic>>> getCart(String uid) async {
    try {
      final res = await _retryAuthRequest((t) {
        return http.get(
          Uri.parse('$baseUrl/users/$uid/cart'),
          headers: {'Authorization': 'Bearer $t'},
        );
      });

      if (!_isSuccess(res.statusCode)) return [];
      return _safeJsonList(res.body);
    } catch (_) {
      return [];
    }
  }

  static Future<bool> addCartItem(
      String uid, Map<String, dynamic> item) async {
    try {
      final res = await _retryAuthRequest((t) {
        return http.post(
          Uri.parse('$baseUrl/users/$uid/cart'),
          headers: {
            'Authorization': 'Bearer $t',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(item),
        );
      });

      return _isSuccess(res.statusCode);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteCartItem(String uid, String tag) async {
    try {
      final res = await _retryAuthRequest((t) {
        return http.delete(
          Uri.parse('$baseUrl/users/$uid/cart/$tag'),
          headers: {'Authorization': 'Bearer $t'},
        );
      });

      return _isSuccess(res.statusCode);
    } catch (_) {
      return false;
    }
  }

  // ================= ORDERS =================

  static Future<List<Map<String, dynamic>>> getOrders(String uid) async {
    try {
      final res = await _retryAuthRequest((t) {
        return http.get(
          Uri.parse('$baseUrl/users/$uid/orders'),
          headers: {'Authorization': 'Bearer $t'},
        );
      });

      if (!_isSuccess(res.statusCode)) return [];
      return _safeJsonList(res.body);
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createOrder(
      Map<String, dynamic> payload) async {
    try {
      final res = await _retryAuthRequest((t) {
        return http.post(
          Uri.parse('$baseUrl/orders'),
          headers: {
            'Authorization': 'Bearer $t',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(payload),
        );
      });

      if (!_isSuccess(res.statusCode)) return null;
      return _safeJsonMap(res.body);
    } catch (_) {
      return null;
    }
  }
}
