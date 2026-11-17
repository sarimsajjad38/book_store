import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/app_theme.dart';
import 'add_book_screen.dart';
import 'inventory_screen.dart';
import 'order_list_screen.dart';

class SellerDashboardScreen extends StatelessWidget {
  final VoidCallback? onInventoryTap;
  final VoidCallback? onOrdersTap;

  const SellerDashboardScreen({
    super.key,
    this.onInventoryTap,
    this.onOrdersTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final books = context.watch<BookProvider>();
    final orders = context.watch<OrderProvider>();
    final sellerBooks = books.getSellerBooks(auth.user?.id ?? '');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                          'Hello, ${auth.user?.name.split(' ').first ?? 'Seller'} 👋',
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color)),
                      const SizedBox(height: 2),
                      Text('Seller Dashboard',
                          style: GoogleFonts.poppins(
                              fontSize: 24, fontWeight: FontWeight.w800)),
                    ])),
                IconButton(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (_) => false);
                    }
                  },
                  icon: Icon(Icons.logout_rounded,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ]),
              const SizedBox(height: 24),

              // Stats
              Row(children: [
                _buildStatCard(context, 'Books', '${sellerBooks.length}',
                    Icons.library_books_rounded, AppColors.primary),
                const SizedBox(width: 12),
                _buildStatCard(context, 'Orders', '${orders.orders.length}',
                    Icons.receipt_long_rounded, AppColors.accent),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _buildStatCard(context, 
                    'Revenue',
                    '₹${orders.orders.fold<double>(0, (s, o) => s + o.totalAmount).toStringAsFixed(0)}',
                    Icons.currency_rupee_rounded,
                    AppColors.success),
                const SizedBox(width: 12),
                _buildStatCard(context, 
                    'Pending',
                    '${orders.orders.where((o) => o.status.name == 'pending').length}',
                    Icons.pending_actions_rounded,
                    AppColors.warning),
              ]),
              const SizedBox(height: 28),

              // Quick Actions
              Text('Quick Actions',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              _buildActionCard(
                  context,
                  'Add New Book',
                  'List a new book for sale',
                  Icons.add_box_rounded,
                  AppColors.primary, () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddBookScreen()));
              }),
              _buildActionCard(
                  context,
                  'Manage Inventory',
                  'Update stock and prices',
                  Icons.inventory_rounded,
                  AppColors.info, () {
                if (onInventoryTap != null) {
                  onInventoryTap!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InventoryScreen()),
                  );
                }
              }),
              _buildActionCard(
                  context,
                  'View Orders',
                  'Process and track orders',
                  Icons.local_shipping_rounded,
                  AppColors.accent, () {
                if (onOrdersTap != null) {
                  onOrdersTap!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderListScreen()),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, 
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
        ]),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor)),
        child: Row(children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
              ])),
          Icon(Icons.chevron_right_rounded, color: Theme.of(context).textTheme.bodySmall?.color),
        ]),
      ),
    );
  }
}
