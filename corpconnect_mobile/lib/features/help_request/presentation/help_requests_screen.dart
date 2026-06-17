import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/help_request_repository.dart';

class HelpRequestsScreen extends StatefulWidget {
  const HelpRequestsScreen({super.key});

  @override
  State<HelpRequestsScreen> createState() => _HelpRequestsScreenState();
}

class _HelpRequestsScreenState extends State<HelpRequestsScreen> {
  final HelpRequestRepository _repository = HelpRequestRepository();

  List<dynamic> _requests = [];
  bool _isLoading = true;
  int? _processingRequestId;

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
      final requests = await _repository.getAssignedRequests();
      if (!mounted) return;
      setState(() => _requests = requests);
    } catch (error) {
      if (!mounted) return;
      setState(() => _requests = []);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageForError(error))));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _acceptRequest(int requestId) async {
    setState(() => _processingRequestId = requestId);
    try {
      await _repository.acceptRequest(requestId);
      await _loadRequests();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request accepted')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageForError(error))));
    } finally {
      if (mounted) {
        setState(() => _processingRequestId = null);
      }
    }
  }

  Future<void> _resolveRequest(int requestId) async {
    setState(() => _processingRequestId = requestId);
    try {
      await _repository.resolveRequest(requestId);
      await _loadRequests();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request resolved')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_messageForError(error))));
    } finally {
      if (mounted) {
        setState(() => _processingRequestId = null);
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

  int? _readRequestId(dynamic item) {
    if (item is! Map) return null;

    final id = item['id'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    return null;
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
        if (text.isNotEmpty) {
          return text;
        }
      }
    }

    return fallback;
  }

  String? _readRequesterName(dynamic item) {
    if (item is! Map<dynamic, dynamic>) return null;

    final directName = _readString(
      item,
      const ['requesterName', 'employeeName', 'requestFromName'],
    );
    if (directName.isNotEmpty) {
      return directName;
    }

    final requester = item['requester'];
    if (requester is Map<dynamic, dynamic>) {
      final nestedName = _readString(
        requester,
        const ['name', 'fullName', 'employeeName'],
      );
      if (nestedName.isNotEmpty) {
        return nestedName;
      }
    }

    return null;
  }

  String? _readHelperName(dynamic item) {
    if (item is! Map<dynamic, dynamic>) return null;

    final directName = _readString(
      item,
      const ['helperName', 'helperEmployeeName'],
    );
    if (directName.isNotEmpty) {
      return directName;
    }

    final helper = item['helper'];
    if (helper is Map<dynamic, dynamic>) {
      final nestedName = _readString(
        helper,
        const ['name', 'fullName', 'employeeName'],
      );
      if (nestedName.isNotEmpty) {
        return nestedName;
      }
    }

    return null;
  }

  /// Friendly status label
  String _statusLabel(String rawStatus) {
    return switch (rawStatus) {
      'PENDING' => 'Waiting',
      'ACCEPTED' => 'Help accepted',
      'RESOLVED' => 'Help completed',
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
      appBar: AppBar(title: const Text('Help Requests')),
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 56,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No help requests',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Requests assigned to you will appear here',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
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

        final requestId = _readRequestId(item);
        final message = _readString(
          item,
          const ['message', 'requestMessage'],
          fallback: 'No message provided',
        );
        final status = _readString(
          item,
          const ['status'],
          fallback: 'UNKNOWN',
        ).toUpperCase();
        final requesterName = _readRequesterName(item);
        final helperName = _readHelperName(item);
        final isProcessing =
            requestId != null && _processingRequestId == requestId;
        final statusColor = _statusColor(status);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: requester name + status chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: statusColor.withValues(alpha: 0.12),
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
                            if (requesterName != null)
                              Text(
                                requesterName,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            if (helperName != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Helper: $helperName',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
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
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Action section
                  _RequestActionSection(
                    status: status,
                    isProcessing: isProcessing,
                    canPerformAction: requestId != null,
                    onAccept: requestId == null
                        ? null
                        : () => _acceptRequest(requestId),
                    onResolve: requestId == null
                        ? null
                        : () => _resolveRequest(requestId),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RequestActionSection extends StatelessWidget {
  const _RequestActionSection({
    required this.status,
    required this.isProcessing,
    required this.canPerformAction,
    required this.onAccept,
    required this.onResolve,
  });

  final String status;
  final bool isProcessing;
  final bool canPerformAction;
  final VoidCallback? onAccept;
  final VoidCallback? onResolve;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (status == 'RESOLVED') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF059669).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: Color(0xFF059669),
            ),
            const SizedBox(width: 8),
            Text(
              'Help completed',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF059669),
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'PENDING') {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: isProcessing || !canPerformAction ? null : onAccept,
          icon: isProcessing
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded, size: 18),
          label: Text(isProcessing ? 'Accepting...' : 'Accept Request'),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            minimumSize: const Size(double.infinity, 46),
          ),
        ),
      );
    }

    if (status == 'ACCEPTED') {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.tonal(
          onPressed: isProcessing || !canPerformAction ? null : onResolve,
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 46),
          ),
          child: isProcessing
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.task_alt_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Mark as Resolved',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
