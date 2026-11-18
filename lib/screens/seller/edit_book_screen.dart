import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../services/firebase_storage_service.dart';
import '../../utils/app_theme.dart';
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
  bool _isUploadingImage = false;
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

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
            content: Text('Cover photo updated in Firebase Storage!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
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
                'Change Book Cover',
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

  Future<void> _updateBook() async {
    setState(() => _isLoading = true);
    final provider = context.read<BookProvider>();
    
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    final updated = widget.book.copyWith(
      title: _title.text.trim(),
      author: _author.text.trim(),
      price: double.tryParse(_price.text.trim()) ?? widget.book.price,
      quantity: int.tryParse(_quantity.text.trim()) ?? widget.book.quantity,
      description: _description.text.trim(),
      imageUrl: _imageUrl.text.trim(),
      category: _category,
    );
    final token = context.read<AuthProvider>().user?.token;
    await provider.updateBook(updated, token);
    if (!mounted) return;
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
          _buildCoverPickerCard(),
          const SizedBox(height: 20),
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

  Widget _buildCoverPickerCard() {
    final hasImage = _selectedImageFile != null || _imageUrl.text.isNotEmpty;
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
                : hasImage
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: _selectedImageFile != null
                                ? Image.file(
                                    _selectedImageFile!,
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    _imageUrl.text,
                                    width: double.infinity,
                                    height: 160,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.broken_image_outlined, size: 40),
                                    ),
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

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {bool isNumber = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyMedium?.color)),
      const SizedBox(height: 8),
      TextField(controller: ctrl, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(prefixIcon: Icon(icon, color: Theme.of(context).textTheme.bodySmall?.color), filled: true, fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    ]);
  }
}
