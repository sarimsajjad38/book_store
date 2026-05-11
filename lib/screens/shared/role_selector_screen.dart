import 'package:flutter/material.dart';
import '../customer/customer_main_screen.dart';
import '../seller/seller_main_screen.dart';
import '../admin/admin_main_screen.dart';

/// Legacy role selector - kept for backward compatibility.
/// The app now routes directly based on auth role.
class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Select Role', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerMainScreen())),
              icon: const Icon(Icons.person), label: const Text('Customer'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SellerMainScreen())),
              icon: const Icon(Icons.store), label: const Text('Seller'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminMainScreen())),
              icon: const Icon(Icons.admin_panel_settings), label: const Text('Admin'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
