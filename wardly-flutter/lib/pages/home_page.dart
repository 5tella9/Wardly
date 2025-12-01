import 'package:flutter/material.dart';
import '../auth_service.dart';


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
    // back to login (replace)
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
