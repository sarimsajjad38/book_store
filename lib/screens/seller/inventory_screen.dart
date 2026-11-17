import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../utils/app_theme.dart';
import 'add_book_screen.dart';
import 'edit_book_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(children: [
                Text('Inventory', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddBookScreen())),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                ),
              ]),
            ),
            Expanded(
              child: Consumer<BookProvider>(
                builder: (context, bookProv, _) {
                  final books = bookProv.getSellerBooks(auth.user?.id ?? '');
                  if (books.isEmpty) {
                    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.inventory_2_outlined, size: 60, color: (Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey).withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('No books in inventory', style: GoogleFonts.poppins(fontSize: 16, color: Theme.of(context).textTheme.bodySmall?.color)),
                    ]));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: books.length,
                    itemBuilder: (ctx, i) {
                      final book = books[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerColor)),
                        child: Row(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(10), child: CachedNetworkImage(imageUrl: book.imageUrl, width: 60, height: 85, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(width: 60, height: 85, color: Theme.of(context).dividerColor, child: const Icon(Icons.book)))),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(book.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                            Text('by ${book.author}', style: GoogleFonts.poppins(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                            const SizedBox(height: 6),
                            Row(children: [
                              Text('₹${book.price.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Theme.of(context).brightness == Brightness.dark ? AppColors.accentLight : AppColors.primary)),
                              const SizedBox(width: 12),
                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: book.quantity > 0 ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                child: Text('Qty: ${book.quantity}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: book.quantity > 0 ? AppColors.success : AppColors.error))),
                            ]),
                          ])),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') Navigator.push(context, MaterialPageRoute(builder: (_) => EditBookScreen(book: book)));
                              if (v == 'delete') {
                                showDialog(context: context, builder: (_) => AlertDialog(
                                  title: const Text('Delete Book'),
                                  content: Text('Remove "${book.title}" from inventory?'),
                                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () { bookProv.deleteBook(book.id, auth.user?.token); Navigator.pop(context); }, child: const Text('Delete', style: TextStyle(color: AppColors.error)))],
                                ));
                              }
                            },
                            itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))],
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
