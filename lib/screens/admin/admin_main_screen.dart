import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../services/mock_data_service.dart';
import '../../utils/app_theme.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});
  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>();
    final stats = MockDataService.getAdminStats();
    final users = MockDataService.getAllUsers();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Admin Panel', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800)),
                Text('Welcome, ${auth.user?.name ?? 'Admin'}', style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color)),
              ])),
              IconButton(
                onPressed: () async { await auth.logout(); if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false); },
                icon: Icon(Icons.logout_rounded, color: Theme.of(context).textTheme.bodySmall?.color),
              ),
            ]),
            const SizedBox(height: 24),

            // Stats Grid
            Row(children: [
              _statCard('Total Books', '${stats['totalBooks']}', Icons.library_books_rounded, AppColors.primary),
              const SizedBox(width: 12),
              _statCard('Total Users', '${stats['totalUsers']}', Icons.people_rounded, AppColors.info),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _statCard('Orders', '${stats['totalOrders']}', Icons.receipt_long_rounded, AppColors.accent),
              const SizedBox(width: 12),
              _statCard('Revenue', '₹${(stats['totalRevenue'] as double).toStringAsFixed(0)}', Icons.trending_up_rounded, AppColors.success),
            ]),
            const SizedBox(height: 28),

            // Users section
            Text('All Users', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...users.map((u) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).dividerColor)),
              child: Row(children: [
                CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: Text(u.name[0].toUpperCase(), style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primary))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(u.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(u.email, style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _roleColor(u.role.name).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(u.role.name.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: _roleColor(u.role.name))),
                ),
              ]),
            )),
            const SizedBox(height: 24),

            // Recent Orders
            Text('All Orders', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...orders.orders.map((o) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).dividerColor)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(o.id, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text('${o.userName}  •  ${o.items.length} items  •  ₹${o.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _orderStatusColor(o.status).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Text(o.statusLabel, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: _orderStatusColor(o.status))),
                ),
              ]),
            )),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 10),
        Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
      ]),
    ));
  }

  Color _roleColor(String role) {
    switch (role) { case 'admin': return AppColors.error; case 'seller': return AppColors.accent; default: return AppColors.info; }
  }

  Color _orderStatusColor(OrderStatus s) {
    switch (s) { case OrderStatus.delivered: return AppColors.success; case OrderStatus.cancelled: return AppColors.error; default: return AppColors.warning; }
  }
}
