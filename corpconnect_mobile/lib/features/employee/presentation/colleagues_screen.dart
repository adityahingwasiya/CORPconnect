import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../help_request/data/help_request_repository.dart';
import '../data/employee_repository.dart';

class ColleaguesScreen extends StatefulWidget {
  const ColleaguesScreen({super.key});

  @override
  State<ColleaguesScreen> createState() => _ColleaguesScreenState();
}

class _ColleaguesScreenState extends State<ColleaguesScreen> {
  final _cityController = TextEditingController();
  final _repository = EmployeeRepository();
  final _helpRequestRepository = HelpRequestRepository();

  List<dynamic> _colleagues = [];
  bool isLoading = true;
  bool _hasActiveCitySearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadColleagues();
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  String _readString(dynamic item, String key) {
    if (item is! Map) return '-';
    final value = item[key];
    if (value == null) return '-';
    return value.toString();
  }

  int? _readColleagueId(dynamic item) {
    if (item is! Map) return null;
    final id = item['id'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    return null;
  }

  Future<void> _showRequestHelpDialog(
    BuildContext context, {
    required int helperId,
    required String colleagueName,
  }) async {
    final didSend = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _HelpRequestDialog(
          helpRequestRepository: _helpRequestRepository,
          helperId: helperId,
          colleagueName: colleagueName,
        );
      },
    );

    if (didSend == true && mounted) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Help request sent successfully')),
      );
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

  Future<void> _loadColleagues() async {
    setState(() => isLoading = true);
    try {
      final list = await _repository.getColleagues();
      if (!mounted) return;
      setState(() {
        _colleagues = list;
        _hasActiveCitySearch = false;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageForError(error))),
      );
      setState(() {
        _colleagues = [];
        _hasActiveCitySearch = false;
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _onSearch() async {
    FocusScope.of(context).unfocus();
    final city = _cityController.text.trim();

    setState(() => isLoading = true);
    try {
      final list = await _repository.getColleagues(
        city: city.isEmpty ? null : city,
      );
      if (!mounted) return;
      setState(() {
        _colleagues = list;
        _hasActiveCitySearch = city.isNotEmpty;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageForError(error))),
      );
      setState(() {
        _colleagues = [];
        _hasActiveCitySearch = city.isNotEmpty;
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Colleagues')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _cityController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'City (optional)',
                  hintText: 'Filter by city, or leave empty for default',
                  helperText: 'Search employees by current or base city',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: isLoading ? null : _onSearch,
                child: const Text('Search'),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildListBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildListBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_colleagues.isEmpty) {
      return Center(
        child: Text(
          _hasActiveCitySearch
              ? 'No colleagues found for this city'
              : 'No colleagues found',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: _colleagues.length,
      itemBuilder: (context, index) {
        final item = _colleagues[index];
        final name = _readString(item, 'name');
        final email = _readString(item, 'email');
        final currentCity = _readString(item, 'currentCity');
        final phone = _readString(item, 'phone');
        final colleagueId = _readColleagueId(item);
        final textStyle = Theme.of(context).textTheme.bodyMedium;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Card(
            elevation: 3,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.email,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(email, style: textStyle)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(currentCity, style: textStyle)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(phone, style: textStyle)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonal(
                      onPressed: colleagueId == null
                          ? null
                          : () => _showRequestHelpDialog(
                                context,
                                helperId: colleagueId,
                                colleagueName: name,
                              ),
                      child: const Text('Request Help'),
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
}

class _HelpRequestDialog extends StatefulWidget {
  const _HelpRequestDialog({
    required this.helpRequestRepository,
    required this.helperId,
    required this.colleagueName,
  });

  final HelpRequestRepository helpRequestRepository;
  final int helperId;
  final String colleagueName;

  @override
  State<_HelpRequestDialog> createState() => _HelpRequestDialogState();
}

class _HelpRequestDialogState extends State<_HelpRequestDialog> {
  late final TextEditingController _messageController;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      await widget.helpRequestRepository.sendHelpRequest(
        widget.helperId,
        message,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageForError(error))),
      );
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request help'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.colleagueName),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            maxLines: 4,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'Describe what you need help with',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _sending ? null : _onSend,
          child: _sending
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Send'),
        ),
      ],
    );
  }
}
