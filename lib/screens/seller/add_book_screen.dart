import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/book.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../services/firebase_storage_service.dart';
import '../../utils/app_theme.dart';
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
  bool _isUploadingImage = false;
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _price.dispose();
    _quantity.dispose();
    _description.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;
      if (!mounted) return;

      final file = File(picked.path);
      setState(() {
        _selectedImageFile = file;
        _isUploadingImage = true;
      });

      final auth = context.read<AuthProvider>();
      final sellerId = auth.user?.id;
      final token = auth.user?.token;
      final downloadUrl = await FirebaseStorageService.uploadBookCover(
        file,
        sellerId: sellerId,
        token: token,
      );

      if (mounted) {
        setState(() {
          _imageUrl.text = downloadUrl;
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book cover uploaded to Firebase Storage!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload Book Cover',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickAndUploadImage(ImageSource.gallery);
                    },
                  ),
                  _buildSourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickAndUploadImage(ImageSource.camera);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.accentLight.withOpacity(0.15),
            child: Icon(icon, color: AppColors.accent, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

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
      imageUrl: _imageUrl.text.trim().isNotEmpty
          ? _imageUrl.text.trim()
          : 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=400',
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
            // Cover Image Upload Card
            _buildCoverPickerCard(),
            const SizedBox(height: 20),

            _buildField('Book Title', _title, 'Enter book title', Icons.book_outlined),
            const SizedBox(height: 16),
            _buildField('Author', _author, 'Enter author name', Icons.person_outline),
            const SizedBox(height: 16),
            // Category
            Text('Category', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _category,
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
            _buildField('Image URL (or use upload above)', _imageUrl, 'https://...', Icons.image_outlined, required: false),
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

  Widget _buildCoverPickerCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book Cover Image',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isUploadingImage ? null : _showImageSourceSheet,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1.5,
              ),
            ),
            child: _isUploadingImage
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.accent),
                      const SizedBox(height: 12),
                      Text(
                        'Uploading cover to Firebase Storage...',
                        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.accent),
                      ),
                    ],
                  )
                : _selectedImageFile != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              _selectedImageFile!,
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.edit, size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Change',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 44,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload Cover Photo',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to select from Gallery or Camera',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
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
