import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  String tr(BuildContext context, String ru, String uz, String en) {
    final lang = Provider.of<LanguageProvider>(context).localeCode;
    if (lang == "ru") return ru;
    if (lang == "uz") return uz;
    return en;
  }

  String formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final date = DateTime.tryParse(iso)?.toLocal() ?? DateTime.now();
    return DateFormat('dd.MM.y HH:mm').format(date);
  }

  String formatPrice(num value) {
    final formatter = NumberFormat('#,###', 'ru');
    return "${formatter.format(value)} UZS";
  }

  /// --- Цвета статусов как в Uzum ---
  Color statusColor(String status) {
    switch (status) {
      case "pending": return Colors.orange;
      case "processing": return Colors.blue;
      case "delivering": return Colors.purple;
      case "completed": return Colors.green;
      default: return Colors.grey;
    }
  }

  /// --- Текст статуса ---
  String statusText(BuildContext context, String status) {
    switch (status) {
      case "pending":
        return tr(context, "Принят", "Qabul qilindi", "Accepted");
      case "processing":
        return tr(context, "Собирается", "Yig‘ilmoqda", "Processing");
      case "delivering":
        return tr(context, "Доставляется", "Yetkazilmoqda", "Delivering");
      case "completed":
        return tr(context, "Завершён", "Tugallangan", "Completed");
      default:
        return tr(context, "Неизвестно", "Noma'lum", "Unknown");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ApiService.uid(),
      builder: (context, uidSnap) {
        if (uidSnap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final userUid = uidSnap.data;
        if (userUid == null) {
      return Scaffold(
        body: Center(
          child: Text(
            tr(
              context,
              "Войдите, чтобы посмотреть заказы",
              "Buyurtmalarni ko‘rish uchun tizimga kiring",
              "Login to view orders",
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
        }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(context, "Мои заказы", "Buyurtmalarim", "My Orders"),
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.getOrders(userUid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data!;

          if (orders.isEmpty) {
            return Center(
              child: Text(
                tr(
                  context,
                  "У вас пока нет заказов",
                  "Sizda hali buyurtmalar yo‘q",
                  "You have no orders yet",
                ),
                style: const TextStyle(fontSize: 17, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final order = orders[i];
              return _orderCard(context, order);
            },
          );
        },
      ),
    );
  });
  }

  Widget _orderCard(BuildContext context, Map<String, dynamic> order) {
    const redColor = Color(0xFFE53935);

    final created = order["created_at"] as String?;
    final items = List<Map<String, dynamic>>.from(order["items"] ?? []);

    final status = order["status"] ?? "pending"; // default

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Date + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDate(created),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor(status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText(context, status),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: statusColor(status),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Items preview
          ...items.take(2).map((item) => _itemRow(context, item)),

          if (items.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "+${items.length - 2} ещё",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),

          const SizedBox(height: 10),

          // TOTAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr(context, "Итого:", "Jami:", "Total:"),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                formatPrice(order["total"]),
                style: const TextStyle(
                  fontSize: 16,
                  color: redColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // DELIVERY TYPE
          Text(
            "${tr(context, "Тип получения", "Olish turi", "Receive method")}: "
            "${order["delivery_type"] == "pickup"
                ? tr(context, "Самовывоз", "Olib ketish", "Pickup")
                : tr(context, "Доставка", "Yetkazib berish", "Delivery")}",
            style: const TextStyle(fontSize: 14),
          ),

          // Branch
          if (order["delivery_type"] == "pickup")
            Text(
              "${tr(context, "Филиал", "Filial", "Branch")}: ${order["branch"]}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

          // Delivery address
          if (order["delivery_type"] == "delivery")
            Text(
              "${tr(context, "Адрес доставки", "Yetkazish manzili", "Delivery address")}: "
              "${order["delivery_address"]}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _itemRow(BuildContext context, Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              (item["image"] ?? '').toString(),
              width: 55,
              height: 55,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported, size: 40),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item["name"] is Map
                  ? item["name"][Provider.of<LanguageProvider>(context).localeCode]
                    ?? item["name"]["ru"]
                  : item["name"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
