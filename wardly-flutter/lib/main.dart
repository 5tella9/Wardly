import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../auth_service.dart';
import 'pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = '';
  String _email = '';
  String _id = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final u = await AuthService.currentUser();
    if (u != null) {
      setState(() {
        _username = u.username;
        _email = u.email;
        _id = u.id;
      });
    }
  }

  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    // back to login (replace)
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }

  void _deleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text('Are you sure to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await AuthService.deleteAccount(_id);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WARDLY'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              child: Text(
                _username.isNotEmpty ? _username[0].toUpperCase() : '?',
              ),
            ),
            const SizedBox(height: 8),
            Text('Hello, $_username', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(_email),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _deleteAccount,
              child: const Text('Delete account'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const WardlyApp());
}

class WardlyApp extends StatelessWidget {
  const WardlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WARDLY',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
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
  List<Map<String, dynamic>> items = [];
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WARDLY'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget buildHome() {
    return Column(
      children: [
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            'All',
            'Pants',
            'Skirts',
            'Top',
            'Dresses',
          ].map((e) => Chip(label: Text(e))).toList(),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final it = items[i];
              Widget img;
              if (it.containsKey('bytes')) {
                img = Image.memory(it['bytes'] as Uint8List, fit: BoxFit.cover);
              } else {
                img = Container(color: Colors.grey);
              }

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
                      onPressed: () =>
                          setState(() => items[i]['fav'] = !items[i]['fav']),
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

  Widget buildAdd() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: pickImageGallery,
            icon: Icon(Icons.photo),
            label: Text('Pick from gallery'),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: pickImageCamera,
            icon: Icon(Icons.camera_alt),
            label: Text('Take a photo'),
          ),
        ],
      ),
    );
  }

  Widget buildProfile() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          SizedBox(height: 10),
          Text('Username', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => setState(() => items.clear()),
            child: Text('Clear wardrobe'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Delete account'),
                content: Text('This is demo - no backend'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            ),
            child: Text('Delete account'),
          ),
        ],
      ),
    );
  }

  Future<void> pickImageGallery() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo == null) return;
    final bytes = await photo.readAsBytes();
    setState(
      () => items.insert(0, {'bytes': bytes, 'fav': false, 'type': 'Top'}),
    );
    setState(() => _index = 0);
  }

  Future<void> pickImageCamera() async {
    final photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo == null) return;
    final bytes = await photo.readAsBytes();
    setState(
      () => items.insert(0, {'bytes': bytes, 'fav': false, 'type': 'Top'}),
    );
    setState(() => _index = 0);
  }
}

