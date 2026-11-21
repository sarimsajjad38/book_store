import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/gradient_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  String _paymentMethod = 'COD';
  bool _orderPlaced = false;
  bool _isProcessingPayment = false;
  Razorpay? _razorpay;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _addressController.text = user?.address ?? '';

    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _razorpay?.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();

    setState(() => _isProcessingPayment = true);

    try {
      final order = await orderProvider.placeOrder(
        userId: auth.user!.id,
        userName: auth.user!.name,
        cartItems: cart.items,
        shippingAddress: _addressController.text.trim(),
        paymentMethod: _paymentMethod,
        token: auth.user?.token,
        razorpayPaymentId: response.paymentId,
        razorpayOrderId: response.orderId,
        razorpaySignature: response.signature,
      );

      if (order != null && mounted) {
        cart.clearCart();
        setState(() {
          _orderPlaced = true;
          _isProcessingPayment = false;
        });
      } else if (mounted) {
        setState(() => _isProcessingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.error ?? 'Failed to finalize order on server.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment verification error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _isProcessingPayment = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment cancelled or failed: ${response.message ?? "Transaction declined."}'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirected to external wallet: ${response.walletName}'),
      ),
    );
  }

  Future<void> _handlePlaceOrder(
    CartProvider cart,
    AuthProvider auth,
    OrderProvider orderProvider,
  ) async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter shipping address'),
        ),
      );
      return;
    }

    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to place an order'),
        ),
      );
      return;
    }

    // Cash on Delivery flow
    if (_paymentMethod == 'COD') {
      final order = await orderProvider.placeOrder(
        userId: auth.user!.id,
        userName: auth.user!.name,
        cartItems: cart.items,
        shippingAddress: _addressController.text.trim(),
        paymentMethod: 'COD',
        token: auth.user?.token,
      );

      if (order != null && mounted) {
        cart.clearCart();
        setState(() => _orderPlaced = true);
      }
      return;
    }

    // Online Payment Flow (Razorpay)
    setState(() => _isProcessingPayment = true);

    try {
      final rzOrder = await ApiService.createRazorpayOrder(
        amount: cart.finalAmount,
        token: auth.user?.token,
      );

      final keyId = rzOrder['keyId'] as String? ?? 'rzp_test_1DP5mmOlF5G5ag';
      final orderId = rzOrder['orderId'] as String?;

      if (kIsWeb || _razorpay == null) {
        // Fallback for Web preview / test environment
        final order = await orderProvider.placeOrder(
          userId: auth.user!.id,
          userName: auth.user!.name,
          cartItems: cart.items,
          shippingAddress: _addressController.text.trim(),
          paymentMethod: _paymentMethod,
          token: auth.user?.token,
          razorpayPaymentId: 'pay_web_${DateTime.now().millisecondsSinceEpoch}',
          razorpayOrderId: orderId,
        );

        if (order != null && mounted) {
          cart.clearCart();
          setState(() {
            _orderPlaced = true;
            _isProcessingPayment = false;
          });
        }
        return;
      }

      final options = <String, dynamic>{
        'key': keyId,
        'amount': (cart.finalAmount * 100).toInt(),
        'name': 'BookNest',
        'description': 'Purchase of ${cart.itemCount} book(s)',
        'timeout': 300,
        'prefill': {
          'contact': (auth.user?.phone != null && auth.user!.phone!.isNotEmpty)
              ? auth.user!.phone!
              : '9876543210',
          'email': (auth.user != null && auth.user!.email.isNotEmpty)
              ? auth.user!.email
              : 'customer@booknest.com',
          'name': auth.user?.name ?? 'Valued Customer',
        },
        'theme': {
          'color': '#1F2E3D',
        },
      };

      if (orderId != null && orderId.isNotEmpty && !orderId.startsWith('order_test_')) {
        options['order_id'] = orderId;
      }

      setState(() => _isProcessingPayment = false);
      _razorpay!.open(options);
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment gateway error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    if (_orderPlaced) {
      return _buildOrderSuccessScreen(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            _buildSectionTitle('Order Summary'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  ...cart.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.book.title} × ${item.quantity}',
                                style: GoogleFonts.poppins(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '₹${item.totalPrice.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Delivery',
                          style: GoogleFonts.poppins(fontSize: 13)),
                      Text(
                        cart.deliveryCharge == 0
                            ? 'FREE'
                            : '₹${cart.deliveryCharge.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: cart.deliveryCharge == 0
                              ? AppColors.success
                              : null,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          )),
                      Text(
                        '₹${cart.finalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.accentLight
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Shipping Address
            _buildSectionTitle('Shipping Address'),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your full shipping address',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.location_on_outlined),
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Method
            _buildSectionTitle('Payment Method'),
            const SizedBox(height: 12),
            _buildPaymentOption(
              'Cash on Delivery',
              'COD',
              Icons.money_rounded,
            ),
            const SizedBox(height: 10),
            _buildPaymentOption(
              'UPI Payment',
              'UPI',
              Icons.account_balance_rounded,
            ),
            const SizedBox(height: 10),
            _buildPaymentOption(
              'Credit / Debit Card',
              'CARD',
              Icons.credit_card_rounded,
            ),
            const SizedBox(height: 32),

            // Place Order Button
            Consumer<OrderProvider>(
              builder: (_, orderProv, __) {
                return GradientButton(
                  text: 'Place Order  •  ₹${cart.finalAmount.toStringAsFixed(0)}',
                  isLoading: orderProv.isLoading || _isProcessingPayment,
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () => _handlePlaceOrder(cart, auth, orderProv),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildPaymentOption(String label, String value, IconData icon) {
    final isSelected = _paymentMethod == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.accentLight : AppColors.primary;

    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.08)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : Theme.of(context).dividerColor,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? primaryColor : Theme.of(context).textTheme.bodySmall?.color),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? primaryColor : Theme.of(context).dividerColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSuccessScreen(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 72,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Order Placed! 🎉',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your order has been placed successfully.\nYou can track it in the Orders tab.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                GradientButton(
                  text: 'Continue Shopping',
                  icon: Icons.shopping_bag_outlined,
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
