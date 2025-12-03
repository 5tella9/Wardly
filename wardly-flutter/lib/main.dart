import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

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
      home: const WardlyHome(),
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
            children: [buildHome(), buildAdd(), buildProfile()],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
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
        Wrap(
          spacing: 8,
          children: [
            'All',
            'Pants',
            'Skirts',
            'Dress',
            'Shirts',
            'Outer',
            'T-Shirt',
            'Hoodie',
          ].map((e) => Chip(label: Text(e))).toList(),
        ),
        Expanded(
          child: GridView.builder(
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
                  ? Image.memory(it['bytes'] as Uint8List, fit: BoxFit.cover)
                  : Container(color: Colors.grey);

              return Stack(
                children: [
                  Positioned.fill(child: img),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        it['fav'] ? Icons.favorite : Icons.favorite_border,
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
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: pickImageCamera,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take a photo'),
          ),
        ],
      ),
    );
  }

  // ---------- PROFILE TAB + AUTH ----------

  Widget buildProfile() {
    final user = _client.auth.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 10),
            Text(
              user?.email ?? 'Not signed in',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Auth form
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _signUp,
                  child: const Text('Sign up'),
                ),
                ElevatedButton(
                  onPressed: _signIn,
                  child: const Text('Sign in'),
                ),
                ElevatedButton(
                  onPressed: user != null ? _signOut : null,
                  child: const Text('Sign out'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => setState(() => items.clear()),
              child: const Text('Clear wardrobe (local)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete account'),
                  content: const Text('This is demo UI only.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
              child: const Text('Delete account'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use email and 6+ character password')),
      );
      return;
    }

    try {
      await _client.auth.signUp(email: email, password: password);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signed up. If email confirmation is on, check inbox.'),
        ),
      );
      setState(() {}); // refresh to show user if auto-logged in
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign up error: $e')));
    }
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter email and password')));
      return;
    }

    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      setState(() {}); // refresh UI with logged-in user
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in as ${res.user?.email ?? email}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign in error: $e')));
    }
  }

  Future<void> _signOut() async {
    try {
      await _client.auth.signOut();
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signed out')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign out error: $e')));
    }
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
    if (_client.auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to add wardrobe items')),
      );
      return;
    }

    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo == null) return;

    final bytes = await photo.readAsBytes();

    final imageUrl = await uploadImageToSupabase(bytes);
    if (imageUrl != null) {
      await insertWardrobeItem(
        imageUrl: imageUrl,
        category: 'Top',
        title: 'New item',
      );
    }

    setState(() {
      items.insert(0, {'bytes': bytes, 'fav': false, 'type': 'Top'});
      _index = 0;
    });
  }

  Future<void> pickImageCamera() async {
    if (_client.auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to add wardrobe items')),
      );
      return;
    }

    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo == null) return;

    final bytes = await photo.readAsBytes();

    final imageUrl = await uploadImageToSupabase(bytes);
    if (imageUrl != null) {
      await insertWardrobeItem(
        imageUrl: imageUrl,
        category: 'Top',
        title: 'New item',
      );
    }

    setState(() {
      items.insert(0, {'bytes': bytes, 'fav': false, 'type': 'Top'});
      _index = 0;
    });
  }
}


