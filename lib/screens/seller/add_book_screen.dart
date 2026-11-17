import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/book.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/gradient_button.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});
  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _price = TextEditingController();
  final _quantity = TextEditingController();
  final _description = TextEditingController();
  final _imageUrl = TextEditingController();
  String _category = 'Fiction';
  bool _isLoading = false;

  @override
  void dispose() { _title.dispose(); _author.dispose(); _price.dispose(); _quantity.dispose(); _description.dispose(); _imageUrl.dispose(); super.dispose(); }

  Future<void> _addBook() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final provider = context.read<BookProvider>();
    final auth = context.read<AuthProvider>();
    final sellerId = auth.user?.id ?? '';
    final token = auth.user?.token;
    
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    final book = Book(
      id: const Uuid().v4().substring(0, 8),
      title: _title.text.trim(),
      author: _author.text.trim(),
      description: _description.text.trim(),
      price: double.parse(_price.text.trim()),
      quantity: int.parse(_quantity.text.trim()),
      category: _category,
      imageUrl: _imageUrl.text.trim().isNotEmpty ? _imageUrl.text.trim() : 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=400',
      sellerId: sellerId,
      rating: 4.0,
    );
    await provider.addBook(book, token);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book added successfully!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Book', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildField('Book Title', _title, 'Enter book title', Icons.book_outlined),
            const SizedBox(height: 16),
            _buildField('Author', _author, 'Enter author name', Icons.person_outline),
            const SizedBox(height: 16),
            // Category
            Text('Category', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(filled: true, fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor))),
              items: BookCategories.all.where((c) => c != 'All').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildField('Price (₹)', _price, '0.00', Icons.currency_rupee, isNumber: true)),
              const SizedBox(width: 12),
              Expanded(child: _buildField('Quantity', _quantity, '0', Icons.inventory_2_outlined, isNumber: true)),
            ]),
            const SizedBox(height: 16),
            _buildField('Image URL', _imageUrl, 'https://...', Icons.image_outlined, required: false),
            const SizedBox(height: 16),
            Text('Description', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
            const SizedBox(height: 8),
            TextFormField(controller: _description, maxLines: 4, decoration: InputDecoration(hintText: 'Enter book description', filled: true, fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)))),
            const SizedBox(height: 28),
            GradientButton(text: 'Add Book', isLoading: _isLoading, onPressed: _addBook, icon: Icons.add_rounded),
          ]),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, IconData icon, {bool isNumber = false, bool required = true}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: required ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: Theme.of(context).textTheme.bodySmall?.color), filled: true, fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor))),
      ),
    ]);
  }
}
