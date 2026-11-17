import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/book_card.dart';
import 'book_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Search', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _query = value);
                      context.read<BookProvider>().searchBooks(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search books, authors, genres...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                                context.read<BookProvider>().searchBooks('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<BookProvider>(
                builder: (context, bookProvider, _) {
                  if (_query.isEmpty) {
                    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.search_rounded, size: 70, color: (Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey).withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('Search for books', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodySmall?.color)),
                      const SizedBox(height: 6),
                      Text('Find by title, author, or genre', style: GoogleFonts.poppins(fontSize: 13, color: (Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey).withOpacity(0.7))),
                    ]));
                  }
                  final results = bookProvider.searchResults;
                  if (results.isEmpty) {
                    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.search_off_rounded, size: 60, color: (Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey).withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('No results found', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodySmall?.color)),
                    ]));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final book = results[index];
                      return BookListCard(
                        book: book,
                        onTap: () {
                          bookProvider.trackBookView(book.id);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)));
                        },
                        onAddToCart: () {
                          context.read<CartProvider>().addToCart(book);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${book.title} added to cart')));
                        },
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
