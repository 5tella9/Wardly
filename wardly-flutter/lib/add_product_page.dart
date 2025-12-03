import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  String? _selectedCategory;
  String? _selectedSize;

  final List<String> _categories = [
    'T-Shirt',
    'Hoodie',
    'Jacket',
    'Shirt',
    'Pants',
  ];
  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  File? _image;

  // State untuk kontrol munculnya form
  bool _showForm = false;

  // PICK IMAGE
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _showForm = true; // setelah pilih foto, tampilkan form
      });
    }
  }

  // SAVE PRODUCT
  void _saveProduct() {
    String name = _nameController.text.trim();
    String brand = _brandController.text.trim();

    if (_image == null ||
        name.isEmpty ||
        brand.isEmpty ||
        _selectedCategory == null ||
        _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select an image'),
        ),
      );
      return;
    }

    // Simpan sementara di list
    final newProduct = {
      'name': name,
      'brand': brand,
      'category': _selectedCategory!,
      'size': _selectedSize!,
      'imagePath': _image!.path, // path lokal
    };

    print('Product saved: $newProduct');

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE PICKER
            const Text(
              'Product Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : const Center(child: Text('Tap to select image')),
              ),
            ),
            const SizedBox(height: 16),

            // FORM: tampil hanya kalau _showForm true
            if (_showForm) ...[
              // Product Name
              const Text(
                'Product Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'e.g. Y2K Motif Oversize Shirt',
                ),
              ),
              const SizedBox(height: 16),

              // Category
              const Text(
                'Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory =
                    _categories[0], // null di awal → hint muncul
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                hint: const Text('Select Category'),
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat, // pastikan ini sama persis dengan list
                        child: Text(cat),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value; // simpan value yang valid
                  });
                },
              ),
              const SizedBox(height: 16),

              // Brand
              const Text(
                'Brand',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _brandController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'e.g. Zara',
                ),
              ),
              const SizedBox(height: 16),

              // Size
              const Text(
                'Size',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSize = _sizes[0],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                hint: const Text('Select Size'),
                items: _sizes
                    .map(
                      (size) =>
                          DropdownMenuItem(value: size, child: Text(size)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedSize = value),
              ),
              const SizedBox(height: 24),

              // Cancel & Save buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _saveProduct,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
