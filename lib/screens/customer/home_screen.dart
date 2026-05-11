import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../../models/book.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/book_card.dart';
import 'book_detail_screen.dart';
import 'cart_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<BookProvider, AuthProvider>(
          builder: (context, bookProvider, authProvider, _) {
            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${authProvider.user?.name.split(' ').first ?? 'Reader'} 👋',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Find your next\ngreat read',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Consumer<CartProvider>(
                          builder: (_, cart, __) {
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const CartScreen()),
                              ),
                              child: badges.Badge(
                                showBadge: cart.itemCount > 0,
                                badgeContent: Text(
                                  cart.itemCount.toString(),
                                  style: TextStyle(
                                    color: Theme.of(context).cardColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                badgeStyle: const badges.BadgeStyle(
                                  badgeColor: AppColors.accent,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Theme.of(context).dividerColor),
                                  ),
                                  child: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: GestureDetector(
                      onTap: () {
                        // Switch to search tab
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Theme.of(context).dividerColor),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: Theme.of(context).textTheme.bodySmall?.color),
                            const SizedBox(width: 10),
                            Text(
                              'Search books, authors...',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Categories
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: BookCategories.all.length,
                      itemBuilder: (context, index) {
                        final category = BookCategories.all[index];
                        final isSelected =
                            bookProvider.selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                bookProvider.selectCategory(category),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${BookCategories.icons[category] ?? ''} $category',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Featured Section
                if (bookProvider.featuredBooks.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                      child: Row(
                        children: [
                          Text(
                            '🔥 Featured',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'See all',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 290,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 20),
                        itemCount: bookProvider.featuredBooks.length,
                        itemBuilder: (context, index) {
                          final book = bookProvider.featuredBooks[index];
                          return BookCard(
                            book: book,
                            onTap: () => _navigateToDetail(context, book),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Recommendations
                if (bookProvider.recommendations.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                      child: Row(
                        children: [
                          Text(
                            '✨ Recommended for You',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 290,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 20),
                        itemCount: bookProvider.recommendations.length,
                        itemBuilder: (context, index) {
                          final book = bookProvider.recommendations[index];
                          return BookCard(
                            book: book,
                            onTap: () => _navigateToDetail(context, book),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // All Books
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                    child: Text(
                      '📚 ${bookProvider.selectedCategory == 'All' ? 'All Books' : bookProvider.selectedCategory}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                if (bookProvider.isLoading)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                else if (bookProvider.books.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 60, color: Theme.of(context).textTheme.bodySmall?.color),
                            const SizedBox(height: 12),
                            Text(
                              'No books found in this category',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final book = bookProvider.books[index];
                          return BookListCard(
                            book: book,
                            onTap: () => _navigateToDetail(context, book),
                            onAddToCart: () {
                              context
                                  .read<CartProvider>()
                                  .addToCart(book);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${book.title} added to cart'),
                                  duration:
                                      const Duration(milliseconds: 1200),
                                  action: SnackBarAction(
                                    label: 'VIEW CART',
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const CartScreen()),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: bookProvider.books.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Book book) {
    context.read<BookProvider>().trackBookView(book.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailScreen(book: book),
      ),
    );
  }
}
