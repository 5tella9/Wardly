import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'add_clothing_page.dart';
import 'pages/opening_page.dart';
import 'pages/profile_page.dart';
import 'pages/trending_ideas_page.dart'; // Import Trending Ideas
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
      home: const IntroScreen(), // Start dengan opening page
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
              const TrendingIdeasPage(), // Trending tab
              const ProfilePage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed, // Biar bisa lebih dari 3 tabs
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

  // ---------- HOME TAB ----------
  Widget buildHome() {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Ganti Wrap jadi SingleChildScrollView biar bisa slide horizontal
        SizedBox(
          height: 50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // ← INI YANG BIKIN HORIZONTAL
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children:
                  [
                        'All',
                        'Pants',
                        'Skirts',
                        'Dress',
                        'Shirts',
                        'Outer',
                        'T-Shirt',
                        'Hoodie',
                        'Shoes',
                        'Accessories',
                      ]
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(label: Text(e)),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    'No items yet. Add some clothes!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final it = items[i];
                    final hasBytes = it.containsKey('bytes');
                    final img = hasBytes
                        ? Image.memory(
                            it['bytes'] as Uint8List,
                            fit: BoxFit.cover,
                          )
                        : Container(color: Colors.grey);
                    return Stack(
                      children: [
                        Positioned.fill(child: img),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(
                              it['fav']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                items[i]['fav'] = !items[i]['fav'];
                              });
                            },
                          ),
                        ),
                      ],
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

  // ---------- PROFILE TAB + AUTH ----------
  // DIHAPUS - Sekarang pake ProfilePage terpisah dari profile_page.dart

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

    // Navigate ke AddClothingPage
    if (!mounted) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddClothingPage(initialImage: File(photo.path)),
      ),
    );

    // Kalau ada result (user save), tambahkan ke list
    if (result != null) {
      final bytes = await photo.readAsBytes();

      // Upload ke Supabase kalau user login
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
        _index = 0; // Balik ke Home tab
      });
    }
  }

  Future<void> pickImageCamera() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo == null) return;

    // Navigate ke AddClothingPage
    if (!mounted) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddClothingPage(initialImage: File(photo.path)),
      ),
    );

    // Kalau ada result (user save), tambahkan ke list
    if (result != null) {
      final bytes = await photo.readAsBytes();

      // Upload ke Supabase kalau user login
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
        _index = 0; // Balik ke Home tab
      });
    }
  }
}
