import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/book.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/gradient_button.dart';
import 'cart_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.accentLight : AppColors.primary;
    final cart = context.watch<CartProvider>();
    final isInCart = cart.isInCart(book.id);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Hero App Bar
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF141F2A), Color(0xFF233242), Color(0xFF18232E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Hero(
                    tag: 'book_${book.id}',
                    child: Container(
                      margin: const EdgeInsets.only(top: 55),
                      height: 220,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: book.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: Theme.of(context).dividerColor,
                            child: const Icon(Icons.book_rounded, size: 60),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      book.title,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'by ${book.author}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats Row
                    Row(
                      children: [
                        _buildStatChip(context, 
                          Icons.star_rounded,
                          '${book.rating}',
                          '(${book.reviewCount} reviews)',
                          AppColors.gold,
                        ),
                        const SizedBox(width: 10),
                        _buildStatChip(context, 
                          Icons.category_outlined,
                          book.category,
                          '',
                          primaryColor,
                        ),
                        const SizedBox(width: 10),
                        _buildStatChip(context, 
                          Icons.inventory_2_outlined,
                          book.quantity > 0 ? 'In Stock' : 'Out of Stock',
                          '',
                          book.quantity > 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Price Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.15)
                                : const Color(0xFF382F24).withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                              Text(
                                '₹${book.price.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (book.price > 500)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.local_shipping_outlined,
                                    size: 15,
                                    color: AppColors.success,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Free Delivery',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'About this book',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.description.isNotEmpty
                          ? book.description
                          : 'No description available for this book.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Add to Cart / Go to Cart
                    Row(
                      children: [
                        // Wishlist button
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border.all(color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to reading wishlist! 📚'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.bookmark_border_rounded,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: GradientButton(
                            text: isInCart ? 'Go to Cart' : 'Add to Cart',
                            icon: isInCart
                                ? Icons.shopping_cart_rounded
                                : Icons.add_shopping_cart_rounded,
                            onPressed: () {
                              if (isInCart) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const CartScreen()),
                                );
                              } else {
                                context
                                    .read<CartProvider>()
                                    .addToCart(book);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${book.title} added to cart'),
                                    action: SnackBarAction(
                                      label: 'VIEW CART',
                                      textColor: isDark ? AppColors.accentLight : AppColors.gold,
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const CartScreen()),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            gradient: isInCart
                                ? AppColors.accentGradient
                                : AppColors.primaryGradient,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, 
      IconData icon, String label, String sublabel, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (sublabel.isNotEmpty)
              Text(
                sublabel,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
