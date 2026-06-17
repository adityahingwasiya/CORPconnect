import 'package:flutter/material.dart';

import '../../../core/storage/role_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await RoleStorage.instance.getRole();
    if (!mounted) return;
    setState(() {
      _role = role;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Text(
                'Logged in as: ${_role ?? 'UNKNOWN'}',
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
