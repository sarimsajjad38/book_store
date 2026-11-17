import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../utils/app_theme.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.delivered: return AppColors.success;
      case OrderStatus.cancelled: return AppColors.error;
      case OrderStatus.shipped: case OrderStatus.outForDelivery: return AppColors.info;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = context.watch<AuthProvider>().user?.token;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text('Orders', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800)),
            ),
            Expanded(
              child: Consumer<OrderProvider>(
                builder: (context, orderProv, _) {
                  if (orderProv.isLoading) return const Center(child: CircularProgressIndicator());
                  if (orderProv.orders.isEmpty) {
                    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.receipt_long_outlined, size: 60, color: (Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey).withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('No orders yet', style: GoogleFonts.poppins(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color)),
                    ]));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: orderProv.orders.length,
                    itemBuilder: (ctx, i) {
                      final order = orderProv.orders[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerColor)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(order.id, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: _statusColor(order.status).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                              child: Text(order.statusLabel, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(order.status))),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Text('Customer: ${order.userName}', style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color)),
                          Text('${order.items.length} item(s)  •  ₹${order.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(DateFormat('MMM dd, yyyy').format(order.createdAt), style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                          const SizedBox(height: 10),
                          // Status update buttons
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: OrderStatus.values.where((s) => s != OrderStatus.cancelled).map((s) {
                              final isActive = order.status == s;
                              final isDark = Theme.of(context).brightness == Brightness.dark;
                              final activeColor = isDark ? AppColors.accentLight : AppColors.primary;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: GestureDetector(
                                  onTap: isActive ? null : () => orderProv.updateOrderStatus(order.id, s, token),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? activeColor
                                          : (isDark ? AppColors.surfaceDark : const Color(0xFFF0EAE1)),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isActive ? activeColor : Theme.of(context).dividerColor,
                                      ),
                                    ),
                                    child: Text(
                                      s.name[0].toUpperCase() + s.name.substring(1),
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isActive
                                            ? (isDark ? const Color(0xFF1E1B18) : Colors.white)
                                            : Theme.of(context).textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList()),
                          ),
                        ]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
