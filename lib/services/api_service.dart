import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://status-shop-backend-production.up.railway.app/api/v1',
  );

  // ================= STORAGE =================

  static Future<SharedPreferences> _prefs() =>
      SharedPreferences.getInstance();

  static Future<String?> token() async =>
      (await _prefs()).getString('token');

  static Future<String?> uid() async =>
      (await _prefs()).getString('uid');

  static Future<void> logout() async {
    final p = await _prefs();
    await p.remove('token');
    await p.remove('uid');
    await p.remove('refresh_token');
  }

  // ================= HELPERS =================

  static bool _isSuccess(int code) => code >= 200 && code < 300;

  static Future<String?> _refreshToken() async =>
      (await _prefs()).getString('refresh_token');

  static Future<void> refreshAccessToken() async {
    final rt = await _refreshToken();
    if (rt == null || rt.isEmpty) return;
    final res = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': rt}),
    );
    if (_isSuccess(res.statusCode)) {
      final data = _safeJsonMap(res.body);
      if (data != null) {
        final p = await _prefs();
        final nt = data['token'];
        if (nt is String && nt.isNotEmpty) await p.setString('token', nt);
        final nrt = data['refresh_token'];
        if (nrt is String && nrt.isNotEmpty) await p.setString('refresh_token', nrt);
        final nuid = data['uid'];
        if (nuid is String && nuid.isNotEmpty) await p.setString('uid', nuid);
      }
    }
  }

  static Future<http.Response> _retryAuthRequest(
      Future<http.Response> Function(String token) exec) async {
    final t = await token();
    final res = await exec(t ?? '');
    if (res.statusCode == 401 || res.statusCode == 403) {
      await refreshAccessToken();
      final t2 = await token();
      return exec(t2 ?? '');
    }
    return res;
  }

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
      if (at is String && at.isNotEmpty) await p.setString('token', at);
      final uidVal = data['uid'];
      if (uidVal is String && uidVal.isNotEmpty) await p.setString('uid', uidVal);
      final rt = data['refresh_token'];
      if (rt is String && rt.isNotEmpty) await p.setString('refresh_token', rt);

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
