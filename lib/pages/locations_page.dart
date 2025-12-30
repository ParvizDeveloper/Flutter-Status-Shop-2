import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../providers/language_provider.dart';
import '../base/translation.dart';

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFFE53935);
    return Consumer<LanguageProvider>(
      builder: (context, lp, _) {
        String lang = Provider.of<LanguageProvider>(context, listen: false).localeCode;
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            centerTitle: true,
            title: Text(
              tr(context, 'locations'),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: ApiService.getBranches(),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final locations = snap.data ?? [];
              if (locations.isEmpty) {
                return Center(
                  child: Text(
                    tr(context, 'no_branches'),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final item = locations[index];
                  return _locationCard(context, item, lang);
                },
              );
            },
          ),
        );
      },
    );
  }

  // ================= CARD =================

  Map<String, String> _asObj(dynamic v) {
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), val?.toString() ?? ''));
    }
    final s = v?.toString() ?? '';
    if (s.trim().startsWith('{')) {
      final obj = ApiService.parseJsonMap(s);
      if (obj != null && obj.isNotEmpty) {
        return obj.map((k, val) => MapEntry(k.toString(), val?.toString() ?? ''));
      }
      String? rx(String key) {
        final re = RegExp('"$key"\\s*:\\s*"([^"]*)"');
        final m = re.firstMatch(s);
        return m != null ? m.group(1) : null;
      }
      final ru = rx('ru'), uz = rx('uz'), en = rx('en');
      return {
        if (ru != null) 'ru': ru,
        if (uz != null) 'uz': uz,
        if (en != null) 'en': en,
      };
    }
    return {'en': s};
  }

  String _textOf(dynamic v, String lang) {
    final o = _asObj(v);
    return o[lang] ?? o['en'] ?? o['ru'] ?? v?.toString() ?? '';
  }

  Widget _locationCard(BuildContext context, Map<String, dynamic> data, String lang) {
    const redColor = Color(0xFFE53935);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NAME
          Text(
            _textOf(data['name'], lang),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _infoRow(Icons.location_on_outlined, (data['address'] ?? '').toString()),
          _infoRow(Icons.location_city_outlined, _textOf(data['city'], lang)),
          _infoRow(Icons.phone_outlined, (data['phone'] ?? '').toString()),
          if ((data['card_number'] ?? '').toString().isNotEmpty)
            _infoRow(Icons.credit_card_outlined, (data['card_number'] ?? '').toString()),

          const SizedBox(height: 14),

          // CALL BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _callPhone((data['phone'] ?? '').toString()),
              icon: const Icon(Icons.call, color: Colors.white),
              label: Text(tr(context, 'call'), style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: redColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CALL =================

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
  
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // ← КРИТИЧЕСКИ ВАЖНО
    );
  }

  // ================= INFO ROW =================

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
