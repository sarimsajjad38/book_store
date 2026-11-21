import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/order.dart';
import '../../utils/app_theme.dart';
import '../../widgets/order_status_timeline.dart';

class OrderTrackingScreen extends StatelessWidget {
  final Order order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentLight : AppColors.primary;

    return Scaffold(
      appBar: AppBar(title: Text('Track Order', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerColor)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(order.id, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                  const Spacer(),
                  Text('₹${order.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18, color: accentColor)),
                ]),
                const SizedBox(height: 8),
                Text('Placed on ${DateFormat('MMMM dd, yyyy').format(order.createdAt)}', style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
                if (order.trackingId != null) ...[
                  const SizedBox(height: 4),
                  Text('Tracking: ${order.trackingId}', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
                ],
                const SizedBox(height: 4),
                Text('Payment: ${order.paymentMethod}', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
              ]),
            ),
            const SizedBox(height: 24),

            // Timeline
            Text('Order Status', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            OrderStatusTimeline(currentStatus: order.status),
            const SizedBox(height: 24),

            // Items
            Text('Items', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...order.items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor)),
              child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: item.imageUrl, width: 50, height: 70, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(width: 50, height: 70, color: Theme.of(context).dividerColor, child: const Icon(Icons.book)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text('by ${item.author}', style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
                  const SizedBox(height: 4),
                  Text('₹${item.price.toStringAsFixed(0)} × ${item.quantity}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: accentColor)),
                ])),
              ]),
            )),
            const SizedBox(height: 16),

            // Shipping
            Text('Shipping Address', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Theme.of(context).dividerColor)),
              child: Row(children: [
                Icon(Icons.location_on_outlined, color: accentColor, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(order.shippingAddress.isNotEmpty ? order.shippingAddress : 'Not specified', style: GoogleFonts.poppins(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color))),
              ]),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
