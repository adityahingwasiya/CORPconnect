import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/storage/role_storage.dart';
import '../../../core/storage/user_storage.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/login_screen.dart';
import '../../employee/presentation/colleagues_screen.dart';
import '../../employee/presentation/update_location_screen.dart';
import '../../help_request/presentation/help_requests_screen.dart';
import '../../help_request/presentation/my_requests_screen.dart';

class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  String _name = '';
  String _currentCity = '';
  String _role = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await UserStorage.instance.getName();
    final city = await UserStorage.instance.getCurrentCity();
    final role = await RoleStorage.instance.getRole();
    if (!mounted) return;
    setState(() {
      _name = name ?? 'Employee';
      _currentCity = city ?? 'Unknown';
      _role = role ?? 'EMPLOYEE';
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await AuthRepository().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String _formatRole(String role) {
    return switch (role) {
      'EMPLOYEE' => 'Employee',
      'ADMIN' => 'Admin',
      _ => role,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context),
              const SizedBox(height: 28),
              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              _buildActionCards(context),
              const SizedBox(height: 28),
              Text(
                'Recent Activity',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              _buildRecentActivity(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  _name.isNotEmpty ? _name[0].toUpperCase() : '?',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _name,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildWelcomeChip(
                icon: Icons.location_on_outlined,
                label: _currentCity.isNotEmpty ? _currentCity : 'Not set',
              ),
              const SizedBox(width: 10),
              _buildWelcomeChip(
                icon: Icons.badge_outlined,
                label: _formatRole(_role),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.people_alt_rounded,
                title: 'Find\nColleagues',
                color: const Color(0xFF4F46E5),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ColleaguesScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ActionCard(
                icon: Icons.handshake_rounded,
                title: 'Help\nRequests',
                color: const Color(0xFF059669),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const HelpRequestsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.send_rounded,
                title: 'My\nRequests',
                color: const Color(0xFF7C3AED),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const MyRequestsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ActionCard(
                icon: Icons.edit_location_alt_rounded,
                title: 'Update\nLocation',
                color: const Color(0xFFD97706),
                onTap: () async {
                  final updated = await Navigator.of(context).push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (_) => const UpdateLocationScreen(),
                    ),
                  );
                  if (updated == true) {
                    _loadUserData();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Placeholder activity items — in a real app these would come from an API
    final activities = [
      {
        'icon': Icons.check_circle_outline_rounded,
        'text': 'Your help request was accepted',
        'time': 'Just now',
        'color': const Color(0xFF059669),
      },
      {
        'icon': Icons.location_on_outlined,
        'text': 'Location updated to $_currentCity',
        'time': 'Today',
        'color': const Color(0xFFD97706),
      },
      {
        'icon': Icons.group_outlined,
        'text': 'New colleagues found nearby',
        'time': 'Yesterday',
        'color': const Color(0xFF4F46E5),
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: activities.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item['text'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  trailing: Text(
                    item['time'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                if (index < activities.length - 1)
                  Divider(
                    height: 1,
                    indent: 72,
                    endIndent: 16,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
