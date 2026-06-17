import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/storage/role_storage.dart';
import '../data/auth_repository.dart';
import '../domain/login_type.dart';
import '../../home/presentation/company_home_screen.dart';
import '../../home/presentation/employee_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();
  bool _loading = false;
  bool _obscurePassword = true;
  LoginType _loginType = LoginType.employee;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _messageForError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (error.message != null && error.message!.isNotEmpty) {
        return error.message!;
      }
      return 'Login failed';
    }
    return error.toString();
  }

  Future<void> _onLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await _authRepository.login(
        _emailController.text.trim(),
        _passwordController.text,
        _loginType,
      );
      if (!mounted) return;
      final role = await RoleStorage.instance.getRole();
      if (!mounted) return;
      final Widget? next = switch (role) {
        'EMPLOYEE' => const EmployeeHomeScreen(),
        'COMPANY_ADMIN' => const CompanyHomeScreen(),
        _ => null,
      };
      if (next == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown role: ${role ?? 'null'}')),
        );
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => next),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageForError(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo / App identity
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
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
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.connect_without_contact_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'CorpConnect',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    'Sign in to continue',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Role toggle
                Text(
                  'Sign in as',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<LoginType>(
                  segments: const [
                    ButtonSegment<LoginType>(
                      value: LoginType.employee,
                      label: Text('Employee'),
                      icon: Icon(Icons.person_outline_rounded, size: 18),
                    ),
                    ButtonSegment<LoginType>(
                      value: LoginType.companyAdmin,
                      label: Text('Company'),
                      icon: Icon(Icons.business_outlined, size: 18),
                    ),
                  ],
                  selected: {_loginType},
                  onSelectionChanged: (Set<LoginType> selection) {
                    setState(() => _loginType = selection.first);
                  },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor:
                        colorScheme.primary.withValues(alpha: 0.1),
                    selectedForegroundColor: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 28),

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'your@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 18),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Login button
                FilledButton(
                  onPressed: _loading ? null : _onLogin,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
