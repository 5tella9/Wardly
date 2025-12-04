import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'add_clothing_page.dart';
import 'pages/opening_page.dart';
import 'pages/profile_page.dart';
import 'pages/trending_ideas_page.dart';
import 'pages/clothing_detail_page.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const WardlyApp());
}

class WardlyApp extends StatelessWidget {
  const WardlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WARDLY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const IntroScreen(),
      routes: {'/home': (context) => const WardlyHome()},
    );
  }
}

class WardlyHome extends StatefulWidget {
  const WardlyHome({super.key});

  @override
  State<WardlyHome> createState() => _WardlyHomeState();
}

class _WardlyHomeState extends State<WardlyHome> {
  int _index = 0;
  final List<Map<String, dynamic>> items = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ========== TAMBAHAN: Variable untuk filter kategori ==========
  String _selectedCategory = 'All';

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WARDLY'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F3FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: IndexedStack(
            index: _index,
            children: [
              buildHome(),
              buildAdd(),
              const TrendingIdeasPage(),
              ProfilePage(wardrobeItems: items),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Trending',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // ========== TAMBAHAN: Function untuk filter items ==========
  List<Map<String, dynamic>> get filteredItems {
    if (_selectedCategory == 'All') {
      return items;
    }
    return items.where((item) {
      final itemCategory = item['type'] ?? item['category'] ?? '';
      return itemCategory.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();
  }

  // ---------- HOME TAB ----------
  Widget buildHome() {
    return Column(
      children: [
        const SizedBox(height: 8),
        // ========== UBAH: Tambahkan onTap untuk setiap chip ==========
        SizedBox(
          height: 50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children:
                  [
                    'All',
                    'Pants',
                    'Skirts',
                    'Dress',
                    'Shirt',
                    'Jacket',
                    'T-Shirt',
                    'Hoodie',
                    'Shoes',
                    'Accessories',
                  ].map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.teal,
                        checkmarkColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // ========== UBAH: Gunakan filteredItems instead of items ==========
        Expanded(
          child: filteredItems.isEmpty
              ? Center(
                  child: Text(
                    _selectedCategory == 'All'
                        ? 'No items yet. Add some clothes!'
                        : 'No items in $_selectedCategory category',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (_, i) {
                    final it = filteredItems[i];
                    final hasBytes = it.containsKey('bytes');
                    // ========== UBAH: Cari index asli di items list ==========
                    final originalIndex = items.indexOf(it);

                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClothingDetailPage(
                              item: it,
                              onDelete: () {
                                setState(() {
                                  items.removeAt(originalIndex);
                                });
                              },
                            ),
                          ),
                        );

                        if (result != null && result is Map<String, dynamic>) {
                          if (result['action'] == 'toggleFavorite') {
                            setState(() {
                              items[originalIndex]['fav'] =
                                  !(items[originalIndex]['fav'] ?? false);
                            });
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              // Image
                              Positioned.fill(
                                child: hasBytes
                                    ? Image.memory(
                                        it['bytes'] as Uint8List,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                              // Favorite button overlay
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      it['fav']
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: it['fav']
                                          ? Colors.red
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        items[originalIndex]['fav'] =
                                            !(items[originalIndex]['fav'] ??
                                                false);
                                      });
                                    },
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ),
                              ),
                              // Info label di bawah
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.7),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (it['name'] != null &&
                                          it['name'].toString().isNotEmpty)
                                        Text(
                                          it['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      if (it['type'] != null ||
                                          it['category'] != null)
                                        Text(
                                          it['type'] ?? it['category'] ?? '',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---------- ADD TAB ----------
  Widget buildAdd() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: pickImageGallery,
            icon: const Icon(Icons.photo),
            label: const Text('Pick from gallery'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: pickImageCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take a photo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- STORAGE + DB HELPERS ----------
  Future<String?> uploadImageToSupabase(Uint8List bytes) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in first to save items')),
      );
      return null;
    }
    final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      await _client.storage.from('wardrobe').uploadBinary(fileName, bytes);
      final imageUrl = _client.storage.from('wardrobe').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
      return null;
    }
  }

  Future<void> insertWardrobeItem({
    required String imageUrl,
    String category = 'Top',
    String? title,
    String? brand,
    String? size,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in first')));
      return;
    }
    try {
      await _client.from('wardrobe_items').insert({
        'user_id': user.id,
        'image_url': imageUrl,
        'category': category,
        'title': title ?? 'Untitled item',
        'brand': brand,
        'size': size,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Insert error: $e')));
    }
  }

  // ---------- IMAGE PICKERS ----------
  Future<void> pickImageGallery() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo == null) return;

    if (!mounted) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddClothingPage(initialImage: File(photo.path)),
      ),
    );

    if (result != null) {
      final bytes = await photo.readAsBytes();
      if (_client.auth.currentUser != null) {
        final imageUrl = await uploadImageToSupabase(bytes);
        if (imageUrl != null) {
          await insertWardrobeItem(
            imageUrl: imageUrl,
            category: result['category'] ?? 'Top',
            title: result['name'] ?? 'New item',
            brand: result['brand'],
            size: result['size'],
          );
        }
      }
      setState(() {
        items.insert(0, {
          'bytes': bytes,
          'fav': false,
          'type': result['category'] ?? 'Top',
          'name': result['name'],
          'brand': result['brand'],
          'size': result['size'],
        });
        _index = 0;
      });
    }
  }

  Future<void> pickImageCamera() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo == null) return;

    if (!mounted) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddClothingPage(initialImage: File(photo.path)),
      ),
    );

    if (result != null) {
      final bytes = await photo.readAsBytes();
      if (_client.auth.currentUser != null) {
        final imageUrl = await uploadImageToSupabase(bytes);
        if (imageUrl != null) {
          await insertWardrobeItem(
            imageUrl: imageUrl,
            category: result['category'] ?? 'Top',
            title: result['name'] ?? 'New item',
            brand: result['brand'],
            size: result['size'],
          );
        }
      }
      setState(() {
        items.insert(0, {
          'bytes': bytes,
          'fav': false,
          'type': result['category'] ?? 'Top',
          'name': result['name'],
          'brand': result['brand'],
          'size': result['size'],
        });
        _index = 0;
      });
    }
  }
}
