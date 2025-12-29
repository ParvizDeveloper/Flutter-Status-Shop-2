import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/language_provider.dart';
import '../base/translation.dart';

class LocationsPage extends StatelessWidget {
  const LocationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFFE53935);

    /// 🔒 ВРЕМЕННО: фиксированный филиал
    final locations = [
      {
        'name': 'Status Shop – Центральный офис',
        'address': 'ул. Амира Темура, 45',
        'city': 'Ташкент',
        'phone': '+998901234567',
        'card_number': '8600 1234 5678 9012',
      },
    ];

    return Consumer<LanguageProvider>(
      builder: (context, lp, _) {
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
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final item = locations[index];
              return _locationCard(context, item);
            },
          ),
        );
      },
    );
  }

  // ================= CARD =================

  Widget _locationCard(BuildContext context, Map<String, dynamic> data) {
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
            data['name'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _infoRow(Icons.location_on_outlined, data['address']),
          _infoRow(Icons.location_city_outlined, data['city']),
          _infoRow(Icons.phone_outlined, data['phone']),
          _infoRow(Icons.credit_card_outlined, data['card_number']),

          const SizedBox(height: 14),

          // CALL BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _callPhone(data['phone']),
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
