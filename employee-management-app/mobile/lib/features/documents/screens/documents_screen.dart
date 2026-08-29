import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/session/app_session.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  String _selectedDocType = 'Aadhar Card';
  final _remarksController = TextEditingController();
  final _docNumberController = TextEditingController();
  File? _selectedFile;
  String? _selectedFileName;

  bool _isSubmitting = false;
  bool _isLoadingList = true;
  List<Map<String, dynamic>> _documents = [];
  String _statusFilter = 'ALL';

  final List<String> _docTypes = [
    'Aadhar Card',
    'PAN Card',
    'Driving License',
    'Passport',
    'Voter ID Card',
    'Bank Passbook / Cheque',
    'Educational Degree / Marksheet',
    'Previous Company Relieving Letter',
    'Salary Slip',
    'Resume / CV',
    'Other Document',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDocuments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _remarksController.dispose();
    _docNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoadingList = true);
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final res = await apiClient.get('/documents');
      if (res.data != null && res.data['data'] != null) {
        setState(() {
          _documents = List<Map<String, dynamic>>.from(res.data['data']);
        });
      }
    } catch (e) {
      debugPrint('Error loading documents: $e');
    } finally {
      if (mounted) setState(() => _isLoadingList = false);
    }
  }

  Future<void> _pickFile(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        setState(() {
          _selectedFile = File(picked.path);
          _selectedFileName = picked.name;
        });
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  Future<void> _pickDocumentPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedFileName = result.files.single.name;
        });
      }
    } catch (e) {
      debugPrint('File pick error: $e');
    }
  }

  Future<void> _submitDocument() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or capture a document image/PDF'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final empId = AppSession.instance.selectedEmployeeId ?? 1;

      final fullRemarks = [
        if (_docNumberController.text.trim().isNotEmpty) 'ID: ${_docNumberController.text.trim()}',
        if (_remarksController.text.trim().isNotEmpty) _remarksController.text.trim(),
      ].join(' | ');

      final formData = FormData.fromMap({
        'employeeId': empId,
        'documentType': _selectedDocType,
        'remarks': fullRemarks,
        'status': 'PENDING',
        'document': await MultipartFile.fromFile(
          _selectedFile!.path,
          filename: _selectedFileName ?? 'document_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      await apiClient.multipart('/documents', formData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded successfully!'),
          backgroundColor: Color(0xFF00BFA5),
        ),
      );

      // Reset form
      _docNumberController.clear();
      _remarksController.clear();
      setState(() {
        _selectedFile = null;
        _selectedFileName = null;
      });

      // Reload list and switch to My Documents tab
      _loadDocuments();
      _tabController.animateTo(1);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteDocument(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document?'),
        content: const Text('Are you sure you want to remove this uploaded document?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      await apiClient.delete('/documents/$id');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document deleted'), backgroundColor: Colors.black87),
        );
        _loadDocuments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final empName = AppSession.instance.selectedEmployeeName ?? 'Kuldeep Kumavat';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF263238),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          empName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00BFA5),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
          tabs: const [
            Tab(text: 'ADD DOCUMENT'),
            Tab(text: 'MY DOCUMENTS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAddDocumentTab(),
          _buildMyDocumentsTab(),
        ],
      ),
    );
  }

  Widget _buildAddDocumentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document Type Selector
          const Text('Document Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF00BFA5), width: 1.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDocType,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00BFA5)),
                items: _docTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDocType = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Document / ID Number Field
          const Text('Document / ID Number (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          TextField(
            controller: _docNumberController,
            decoration: InputDecoration(
              hintText: 'e.g. XXXX-XXXX-XXXX / ABCD1234E',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 18),

          // Notes / Remarks Field
          const Text('Notes / Description (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          TextField(
            controller: _remarksController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add any remarks or notes about this document...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 2)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 24),

          // Add Attachment Card
          const Text('Upload Document File', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedFile != null) ...[
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
                          border: Border.all(color: const Color(0xFF00BFA5)),
                        ),
                        child: _selectedFileName != null && _selectedFileName!.toLowerCase().endsWith('.pdf')
                            ? const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: Image.file(_selectedFile!, fit: BoxFit.cover),
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFileName ?? 'Uploaded Document',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            const Text('Ready to upload', style: TextStyle(color: Color(0xFF00BFA5), fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() {
                          _selectedFile = null;
                          _selectedFileName = null;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                // Action Buttons to Pick File
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00BFA5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.camera_alt, color: Color(0xFF00BFA5), size: 18),
                        label: const Text('CAMERA', style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold, fontSize: 13)),
                        onPressed: () => _pickFile(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00BFA5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.photo_library, color: Color(0xFF00BFA5), size: 18),
                        label: const Text('GALLERY', style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold, fontSize: 13)),
                        onPressed: () => _pickFile(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00BFA5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.folder_open, color: Color(0xFF00BFA5), size: 18),
                        label: const Text('PDF / DOC', style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold, fontSize: 13)),
                        onPressed: _pickDocumentPdf,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: _isSubmitting ? null : _submitDocument,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Upload Document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyDocumentsTab() {
    if (_isLoadingList) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00BFA5)));
    }

    final filtered = _documents.where((d) {
      if (_statusFilter == 'ALL') return true;
      return (d['status'] ?? 'PENDING') == _statusFilter;
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadDocuments,
      color: const Color(0xFF00BFA5),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['ALL', 'PENDING', 'VERIFIED', 'REJECTED'].map((filter) {
                final isSelected = _statusFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00BFA5),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (val) => setState(() => _statusFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          if (filtered.isEmpty) ...[
            const SizedBox(height: 60),
            const Icon(Icons.folder_open, size: 70, color: Colors.grey),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'No documents found',
                style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
          ] else ...[
            ...filtered.map((doc) => _buildDocumentCard(doc)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    final type = doc['documentType'] ?? 'Document';
    final status = doc['status'] ?? 'PENDING';
    final remarks = doc['remarks'] ?? '';
    final createdAt = doc['createdAt'] != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(doc['createdAt']))
        : 'Recently';
    final fileUrl = doc['fileUrl'] as String?;

    Color statusColor;
    switch (status) {
      case 'VERIFIED':
        statusColor = const Color(0xFF00BFA5);
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    final isPdf = fileUrl != null && fileUrl.toLowerCase().endsWith('.pdf');
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA5).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.description_outlined,
                    color: isPdf ? Colors.red : const Color(0xFF00BFA5),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        createdAt,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            if (remarks.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  remarks,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (fileUrl != null)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF00BFA5)),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () {
                      _showFileModal('$baseUrl$fileUrl', isPdf);
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _deleteDocument(doc['id'] as int),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFileModal(String url, bool isPdf) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: const Color(0xFF263238),
              title: const Text('Document Preview', style: TextStyle(fontSize: 16, color: Colors.white)),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: isPdf
                  ? const Column(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red, size: 60),
                        SizedBox(height: 12),
                        Text('PDF Document Attached', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(child: Text('Failed to load image preview')),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
