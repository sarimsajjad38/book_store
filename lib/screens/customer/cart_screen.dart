import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/gradient_button.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) {
              if (cart.itemCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Clear Cart'),
                      content: const Text(
                          'Remove all items from your cart?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            cart.clearCart();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear',
                              style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  'Clear All',
                  style: GoogleFonts.poppins(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.itemCount == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Browse books and add them to your cart',
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Browse Books'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        children: [
                          // Book image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: item.book.imageUrl,
                              width: 65,
                              height: 90,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                width: 65,
                                height: 90,
                                color: Theme.of(context).dividerColor,
                                child: const Icon(Icons.book),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.book.title,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.book.author,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '₹${item.totalPrice.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Quantity controls
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.bgLight,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          _buildQtyButton(context,
                                            icon: Icons.remove,
                                            onTap: () => context
                                                .read<CartProvider>()
                                                .decrementQuantity(
                                                    item.book.id),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12),
                                            child: Text(
                                              '${item.quantity}',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          _buildQtyButton(context,
                                            icon: Icons.add,
                                            onTap: () => context
                                                .read<CartProvider>()
                                                .incrementQuantity(
                                                    item.book.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Delete
                          IconButton(
                            onPressed: () => context
                                .read<CartProvider>()
                                .removeFromCart(item.book.id),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Summary + Checkout
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildSummaryRow(context, 'Subtotal',
                          '₹${cart.totalAmount.toStringAsFixed(0)}'),
                      const SizedBox(height: 6),
                      _buildSummaryRow(context, 
                        'Delivery',
                        cart.deliveryCharge == 0
                            ? 'FREE'
                            : '₹${cart.deliveryCharge.toStringAsFixed(0)}',
                        valueColor: cart.deliveryCharge == 0
                            ? AppColors.success
                            : null,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(),
                      ),
                      _buildSummaryRow(context, 
                        'Total',
                        '₹${cart.finalAmount.toStringAsFixed(0)}',
                        isBold: true,
                      ),
                      const SizedBox(height: 16),
                      GradientButton(
                        text: 'Proceed to Checkout',
                        icon: Icons.payment_rounded,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CheckoutScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQtyButton(BuildContext context, 
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value,
      {bool isBold = false, Color? valueColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.accentLight : AppColors.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor ??
                (isBold ? primaryColor : Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
      ],
    );
  }
}
