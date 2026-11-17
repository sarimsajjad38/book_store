import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/gradient_button.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;
  const EditBookScreen({super.key, required this.book});
  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  late TextEditingController _title, _author, _price, _quantity, _description, _imageUrl;
  late String _category;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.book.title);
    _author = TextEditingController(text: widget.book.author);
    _price = TextEditingController(text: widget.book.price.toString());
    _quantity = TextEditingController(text: widget.book.quantity.toString());
    _description = TextEditingController(text: widget.book.description);
    _imageUrl = TextEditingController(text: widget.book.imageUrl);
    _category = widget.book.category;
  }

  @override
  void dispose() { _title.dispose(); _author.dispose(); _price.dispose(); _quantity.dispose(); _description.dispose(); _imageUrl.dispose(); super.dispose(); }

  Future<void> _updateBook() async {
    setState(() => _isLoading = true);
    final provider = context.read<BookProvider>();
    
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    final updated = widget.book.copyWith(
      title: _title.text.trim(), author: _author.text.trim(),
      price: double.tryParse(_price.text.trim()) ?? widget.book.price,
      quantity: int.tryParse(_quantity.text.trim()) ?? widget.book.quantity,
      description: _description.text.trim(), imageUrl: _imageUrl.text.trim(), category: _category,
    );
    final token = context.read<AuthProvider>().user?.token;
    await provider.updateBook(updated, token);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book updated!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Book', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildField('Title', _title, Icons.book_outlined),
          const SizedBox(height: 16),
          _buildField('Author', _author, Icons.person_outline),
          const SizedBox(height: 16),
          Text('Category', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: BookCategories.all.contains(_category) ? _category : 'Fiction',
            decoration: InputDecoration(filled: true, fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            items: BookCategories.all.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _buildField('Price (₹)', _price, Icons.currency_rupee, isNumber: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildField('Quantity', _quantity, Icons.inventory_2_outlined, isNumber: true)),
          ]),
          const SizedBox(height: 16),
          _buildField('Image URL', _imageUrl, Icons.image_outlined),
          const SizedBox(height: 16),
          Text('Description', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
          const SizedBox(height: 8),
          TextField(controller: _description, maxLines: 4, decoration: InputDecoration(filled: true, fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 28),
          GradientButton(text: 'Update Book', isLoading: _isLoading, onPressed: _updateBook, icon: Icons.save_rounded),
        ]),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {bool isNumber = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
      const SizedBox(height: 8),
      TextField(controller: ctrl, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(prefixIcon: Icon(icon, color: Theme.of(context).textTheme.bodySmall?.color), filled: true, fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    ]);
  }
}
