import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/employee_repository.dart';

class ViewEmployeesScreen extends StatefulWidget {
  const ViewEmployeesScreen({super.key, required this.companyId});

  final int companyId;

  @override
  State<ViewEmployeesScreen> createState() => _ViewEmployeesScreenState();
}

class _ViewEmployeesScreenState extends State<ViewEmployeesScreen> {
  final _repository = EmployeeRepository();
  List<dynamic> _employees = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  String _readString(dynamic item, String key) {
    if (item is! Map) return '-';
    final value = item[key];
    if (value == null) return '-';
    return value.toString();
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
      return 'Failed to load employees';
    }
    return error.toString();
  }

  Future<void> _loadEmployees() async {
    setState(() => _loading = true);
    try {
      final list =
          await _repository.getEmployeesByCompany(widget.companyId);
      if (!mounted) return;
      setState(() => _employees = list);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageForError(e))),
      );
      setState(() => _employees = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Employees'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_employees.length}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadEmployees,
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (_employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_off_outlined,
              size: 56,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No employees found',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: _employees.length,
      itemBuilder: (context, index) {
        final emp = _employees[index];
        final name = _readString(emp, 'name');
        final email = _readString(emp, 'email');
        final currentCity = _readString(emp, 'currentCity');
        final baseCity = _readString(emp, 'baseCity');
        final phone = _readString(emp, 'phone');

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(
                    height: 1,
                    color:
                        colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        icon: Icons.location_on_outlined,
                        label: currentCity,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      _buildInfoChip(
                        context,
                        icon: Icons.home_outlined,
                        label: baseCity,
                        color: colorScheme.tertiary,
                      ),
                    ],
                  ),
                  if (phone != '-') ...[
                    const SizedBox(height: 8),
                    _buildInfoChip(
                      context,
                      icon: Icons.phone_outlined,
                      label: phone,
                      color: colorScheme.secondary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
