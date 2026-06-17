import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/help_request_repository.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final HelpRequestRepository _repository = HelpRequestRepository();

  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRequests();
    });
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _repository.getMyRequests();
      if (!mounted) return;
      setState(() => _requests = requests);
    } catch (error) {
      if (!mounted) return;
      setState(() => _requests = []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageForError(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
      return 'Request failed';
    }
    return error.toString();
  }

  String _readString(
    Map<dynamic, dynamic> item,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = item[key];
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
    }
    return fallback;
  }

  /// Friendly status label
  String _statusLabel(String rawStatus) {
    return switch (rawStatus) {
      'PENDING' => 'Waiting',
      'ACCEPTED' => 'Help Accepted',
      'RESOLVED' => 'Help Completed',
      _ => rawStatus,
    };
  }

  /// Color for status chip
  Color _statusColor(String rawStatus) {
    return switch (rawStatus) {
      'PENDING' => const Color(0xFFD97706),
      'ACCEPTED' => const Color(0xFF4F46E5),
      'RESOLVED' => const Color(0xFF059669),
      _ => Colors.grey,
    };
  }

  IconData _statusIcon(String rawStatus) {
    return switch (rawStatus) {
      'PENDING' => Icons.hourglass_top_rounded,
      'ACCEPTED' => Icons.handshake_rounded,
      'RESOLVED' => Icons.check_circle_rounded,
      _ => Icons.info_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRequests,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (_requests.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        size: 36,
                        color: colorScheme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No requests sent yet',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Help requests you send will appear here',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final item = _requests[index];
        if (item is! Map<dynamic, dynamic>) {
          return const SizedBox.shrink();
        }

        final message = _readString(
          item,
          const ['message'],
          fallback: 'No message provided',
        );
        final status = _readString(
          item,
          const ['status'],
          fallback: 'UNKNOWN',
        ).toUpperCase();
        final helperName = _readString(
          item,
          const ['helperName'],
        );
        final statusColor = _statusColor(status);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: helper info + status chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            statusColor.withValues(alpha: 0.12),
                        child: Icon(
                          _statusIcon(status),
                          size: 20,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (helperName.isNotEmpty)
                              Text(
                                helperName,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            const SizedBox(height: 2),
                            Text(
                              helperName.isNotEmpty
                                  ? 'Requested helper'
                                  : 'Helper not assigned',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _statusLabel(status),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bottom status indicator
                  _StatusIndicator(status: status, color: statusColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({
    required this.status,
    required this.color,
  });

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (status) {
      'PENDING' => (Icons.schedule_rounded, 'Waiting for helper to respond'),
      'ACCEPTED' => (Icons.thumb_up_alt_rounded, 'Helper has accepted your request'),
      'RESOLVED' => (Icons.task_alt_rounded, 'This request has been completed'),
      _ => (Icons.info_outline_rounded, status),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
