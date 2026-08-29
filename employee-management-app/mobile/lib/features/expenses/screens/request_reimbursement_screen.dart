import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';

class RequestReimbursementScreen extends StatefulWidget {
  const RequestReimbursementScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<RequestReimbursementScreen> createState() => _RequestReimbursementScreenState();
}

class _RequestReimbursementScreenState extends State<RequestReimbursementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<File> _attachedFiles = [];
  bool _isSubmitting = false;

  // History state
  bool _isLoadingHistory = false;
  List<dynamic> _historyList = [];
  String _selectedStatusFilter = 'ALL';

  final ImagePicker _picker = ImagePicker();

  // Colors matching design
  static const Color _darkHeader = Color(0xFF263238);
  static const Color _tealPrimary = Color(0xFF00C292);
  static const Color _borderGrey = Color(0xFFCFD8DC);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        _loadHistory();
      }
    });
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked != null) {
        setState(() {
          _attachedFiles.add(File(picked.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Attachment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: _tealPrimary),
                title: const Text('Take Photo from Camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: _tealPrimary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _tealPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitReimbursement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final apiClient = context.read<ApiClient>();

      final formData = FormData();
      formData.fields.add(MapEntry('amount', _amountController.text.trim()));
      formData.fields.add(MapEntry('paymentAmount', _amountController.text.trim()));
      formData.fields.add(MapEntry('date', _selectedDate.toIso8601String()));
      formData.fields.add(MapEntry('notes', _notesController.text.trim()));
      formData.fields.add(MapEntry('description', _notesController.text.trim()));
      formData.fields.add(const MapEntry('expenseType', 'Reimbursement'));

      for (int i = 0; i < _attachedFiles.length; i++) {
        final file = _attachedFiles[i];
        formData.files.add(
          MapEntry(
            'attachments',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split(Platform.pathSeparator).last,
            ),
          ),
        );
      }

      await apiClient.multipart('/reimbursements', formData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reimbursement requested successfully!'),
          backgroundColor: _tealPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Reset form
      _amountController.clear();
      _notesController.clear();
      setState(() {
        _attachedFiles.clear();
        _selectedDate = DateTime.now();
      });

      // Switch to History tab and reload
      _tabController.animateTo(1);
      _loadHistory();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit reimbursement: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final apiClient = context.read<ApiClient>();
      final res = await apiClient.get(
        '/reimbursements',
        query: {
          if (_selectedStatusFilter != 'ALL') 'status': _selectedStatusFilter,
        },
      );
      final list = res is Map && res['data'] is List
          ? res['data']
          : (res is List ? res : []);
      if (mounted) {
        setState(() {
          _historyList = list;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final employee = context.watch<AuthProvider>().state.data;
    final title = employee?.name.trim().isNotEmpty == true
        ? employee!.name.trim()
        : 'Reimbursement';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _darkHeader,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          tabs: const [
            Tab(text: 'ADD REIMBURSEMENT'),
            Tab(text: 'REIMBURSEMENT HISTORY'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAddReimbursementTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // TAB 1: ADD REIMBURSEMENT
  Widget _buildAddReimbursementTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Amount Field (Outlined with focused teal label)
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter payment amount';
                      final numVal = double.tryParse(v.trim());
                      if (numVal == null || numVal <= 0) return 'Please enter a valid amount';
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Payment Amount',
                      labelStyle: const TextStyle(
                        color: _tealPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: 'Enter Amount',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: _tealPrimary, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: _tealPrimary, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Row: Date of Payment & Notes
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date of Payment
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: _borderGrey, width: 1.0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat('dd MMM yyyy').format(_selectedDate),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey.shade600),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Notes Input
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: TextFormField(
                            controller: _notesController,
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Notes',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: _borderGrey, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: _tealPrimary, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Add Attachments Section
                  const Text(
                    'Add Attachments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ADD FILE Button and Thumbnails
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      // Square ADD FILE Button
                      InkWell(
                        onTap: _showAttachmentOptions,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: _borderGrey, width: 1.2),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'ADD',
                                  style: TextStyle(
                                    color: Color(0xFF0288D1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'FILE',
                                  style: TextStyle(
                                    color: Color(0xFF0288D1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Attached File Previews
                      ..._attachedFiles.map((file) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _tealPrimary.withOpacity(0.5)),
                                image: DecorationImage(
                                  image: FileImage(file),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -6,
                              right: -6,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _attachedFiles.remove(file);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),

        // Bottom Add Reimbursement Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReimbursement,
              style: ElevatedButton.styleFrom(
                backgroundColor: _tealPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: _tealPrimary.withOpacity(0.6),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Add Reimbursement',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // TAB 2: REIMBURSEMENT HISTORY
  Widget _buildHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator(color: _tealPrimary));
    }

    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: _tealPrimary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['ALL', 'PENDING', 'APPROVED', 'REJECTED', 'PAID'].map((status) {
                final isSelected = _selectedStatusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    selectedColor: _tealPrimary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      setState(() => _selectedStatusFilter = status);
                      _loadHistory();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          if (_historyList.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 60),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No reimbursement claims found',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _tabController.animateTo(0),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _tealPrimary,
                      side: const BorderSide(color: _tealPrimary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Reimbursement'),
                  ),
                ],
              ),
            )
          else
            ..._historyList.map((item) {
              final rawAmount = item['amount']?.toString() ?? '0';
              final formattedAmount = double.tryParse(rawAmount)?.toStringAsFixed(2) ?? rawAmount;
              final rawDate = item['date']?.toString() ?? item['createdAt']?.toString();
              final dateStr = rawDate != null
                  ? DateFormat('dd MMM yyyy').format(DateTime.parse(rawDate))
                  : '--';
              final desc = item['description']?.toString() ?? item['notes']?.toString() ?? 'Reimbursement';
              final status = item['status']?.toString() ?? 'PENDING';
              final attachments = (item['attachments'] as List?) ?? [];

              Color statusColor;
              Color statusBg;
              switch (status.toUpperCase()) {
                case 'APPROVED':
                  statusColor = const Color(0xFF00C292);
                  statusBg = const Color(0xFFE8F8F5);
                  break;
                case 'REJECTED':
                  statusColor = Colors.redAccent;
                  statusBg = const Color(0xFFFFEBEE);
                  break;
                case 'PAID':
                  statusColor = Colors.blue;
                  statusBg = const Color(0xFFE3F2FD);
                  break;
                default:
                  statusColor = Colors.orange;
                  statusBg = const Color(0xFFFFF3E0);
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderGrey.withOpacity(0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹ $formattedAmount',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        if (attachments.isNotEmpty) ...[
                          const SizedBox(width: 14),
                          Icon(Icons.attach_file, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 2),
                          Text(
                            '${attachments.length} attachment(s)',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ],
                    ),
                    if (attachments.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: attachments.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, idx) {
                            final fileUrl = attachments[idx]['fileUrl']?.toString() ?? '';
                            final fullUrl = fileUrl.startsWith('http') ? fileUrl : '$baseUrl$fileUrl';
                            return InkWell(
                              onTap: () {
                                _showFullImageDialog(context, fullUrl);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  fullUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.receipt, size: 22, color: Colors.grey),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showFullImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: const Text('Unable to load receipt image'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
