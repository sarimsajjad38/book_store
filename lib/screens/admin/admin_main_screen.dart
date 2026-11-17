import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../../services/api_service.dart';
import '../../services/mock_data_service.dart';
import '../../utils/app_theme.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});
  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  Map<String, dynamic> _stats = MockDataService.getAdminStats();
  List<AppUser> _users = MockDataService.getAllUsers();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAdminData();
    });
  }

  Future<void> _loadAdminData() async {
    final auth = context.read<AuthProvider>();
    final token = auth.user?.token;
    context.read<OrderProvider>().loadAllOrders(token);

    if (token != null && !token.startsWith('mock_')) {
      setState(() => _isLoading = true);
      try {
        final stats = await ApiService.getAdminStats(token);
        final users = await ApiService.getAdminUsers(token);
        if (mounted) {
          setState(() {
            _stats = stats;
            _users = users;
            _isLoading = false;
          });
          return;
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _stats = MockDataService.getAdminStats();
        _users = MockDataService.getAllUsers();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAdminData,
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
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  },
                  icon: Icon(Icons.logout_rounded, color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ]),
              const SizedBox(height: 24),

              if (_isLoading)
                const LinearProgressIndicator(),

              // Stats Grid
              Row(children: [
                _statCard('Total Books', '${_stats['totalBooks'] ?? 0}', Icons.library_books_rounded, AppColors.primary),
                const SizedBox(width: 12),
                _statCard('Total Users', '${_stats['totalUsers'] ?? 0}', Icons.people_rounded, AppColors.info),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _statCard('Orders', '${_stats['totalOrders'] ?? 0}', Icons.receipt_long_rounded, AppColors.accent),
                const SizedBox(width: 12),
                _statCard('Revenue', '₹${((_stats['totalRevenue'] ?? 0) as num).toDouble().toStringAsFixed(0)}', Icons.trending_up_rounded, AppColors.success),
              ]),
              const SizedBox(height: 28),

              // Users section
              Text('All Users', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ..._users.map((u) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final primaryColor = isDark ? AppColors.accentLight : AppColors.primary;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).dividerColor)),
                  child: Row(children: [
                    CircleAvatar(backgroundColor: primaryColor.withOpacity(0.12), child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: primaryColor))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(u.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(u.email, style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: _roleColor(u.role.name).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                      child: Text(u.role.name.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: _roleColor(u.role.name))),
                    ),
                  ]),
                );
              }),
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
                    decoration: BoxDecoration(color: _orderStatusColor(o.status).withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Text(o.statusLabel, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: _orderStatusColor(o.status))),
                  ),
                ]),
              )),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
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
