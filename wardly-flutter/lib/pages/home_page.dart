import 'dart:io';

import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../add_clothing_page.dart'; // adjust path if needed

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = '';
  String _email = '';
  String _id = '';

  // local wardrobe list
  final List<Map<String, dynamic>> _clothes = [];

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

  Future<void> _openAddClothingPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddClothingPage(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _clothes.add(result);
      });
    }
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

  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _deleteAccount,
              child: const Text('Delete account'),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My Wardrobe',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _clothes.isEmpty
                  ? const Center(
                      child: Text(
                        'No clothes yet. Tap + to add one.',
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _clothes.length,
                      itemBuilder: (context, index) {
                        final item = _clothes[index];
                        final imagePath = item['imagePath'] as String?;
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: imagePath == null
                                    ? const Icon(Icons.image, size: 48)
                                    : ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                        child: Image.file(
                                          File(imagePath),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item['brand'] ?? ''} • ${item['size'] ?? ''}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['category'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddClothingPage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
