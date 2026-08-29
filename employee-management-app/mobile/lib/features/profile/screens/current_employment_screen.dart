import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/session/app_session.dart';
import '../../auth/providers/auth_provider.dart';

class CurrentEmploymentScreen extends StatefulWidget {
  const CurrentEmploymentScreen({super.key, this.initialData});
  final Map<String, dynamic>? initialData;

  @override
  State<CurrentEmploymentScreen> createState() => _CurrentEmploymentScreenState();
}

class _CurrentEmploymentScreenState extends State<CurrentEmploymentScreen> {
  late TextEditingController _branchController;
  late TextEditingController _departmentController;
  late TextEditingController _jobTitleController;
  late TextEditingController _dojController;
  late TextEditingController _dolController;
  late TextEditingController _employeeIdController;

  String? _selectedEmployeeType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData ?? {};
    final auth = context.read<AuthProvider>().state.data;

    final branchName = d['branchRef']?['name'] ?? d['workLocation'] ?? 'Yogesh Krushi Seva Kendra PM';
    final deptName = d['department']?['name'] ?? (auth != null ? auth.departmentName : 'All Departments Assigned');
    final title = d['designation']?['name'] ?? (auth != null ? auth.designationName : 'Staff Title');
    final doj = d['joiningDate'] != null ? d['joiningDate'].toString().split('T')[0] : '';
    final code = d['employeeCode'] ?? (auth != null ? auth.employeeCode : AppSession.instance.selectedEmployeeCode ?? 'EMP-0021');

    _branchController = TextEditingController(text: branchName);
    _departmentController = TextEditingController(text: deptName ?? 'All Departments Assigned');
    _jobTitleController = TextEditingController(text: title ?? 'Staff Title');
    _dojController = TextEditingController(text: doj);
    _dolController = TextEditingController(text: '');
    _employeeIdController = TextEditingController(text: code);

    _selectedEmployeeType = 'Full Time';
    if (d['employmentType'] != null) {
      final t = d['employmentType'].toString().toUpperCase();
      if (t == 'PART_TIME') _selectedEmployeeType = 'Part Time';
      else if (t == 'CONTRACT') _selectedEmployeeType = 'Contract';
      else if (t == 'INTERN') _selectedEmployeeType = 'Intern';
      else _selectedEmployeeType = 'Full Time';
    }
  }

  @override
  void dispose() {
    _branchController.dispose();
    _departmentController.dispose();
    _jobTitleController.dispose();
    _dojController.dispose();
    _dolController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2010),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveDetails() async {
    setState(() => _isSaving = true);
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final employeeId = AppSession.instance.selectedEmployeeId ?? 1;

      DateTime? parsedDoj;
      if (_dojController.text.isNotEmpty) {
        try {
          if (_dojController.text.contains('/')) {
            parsedDoj = DateFormat('dd/MM/yyyy').parse(_dojController.text);
          } else {
            parsedDoj = DateTime.tryParse(_dojController.text);
          }
        } catch (_) {}
      }

      String empTypeEnum = 'FULL_TIME';
      if (_selectedEmployeeType == 'Part Time') empTypeEnum = 'PART_TIME';
      else if (_selectedEmployeeType == 'Contract') empTypeEnum = 'CONTRACT';
      else if (_selectedEmployeeType == 'Intern') empTypeEnum = 'INTERN';

      final payload = {
        'employeeId': employeeId,
        'workLocation': _branchController.text.trim(),
        'employmentType': empTypeEnum,
        if (parsedDoj != null) 'joiningDate': parsedDoj.toIso8601String(),
      };

      await apiClient.put('/employees/me', data: payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current Employment details saved successfully!'),
            backgroundColor: Color(0xFF00BFA5),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save details: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Current Employment',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
              label: const Text('Biodata', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Downloading Biodata PDF...'),
                    backgroundColor: Color(0xFF00BFA5),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Branch'),
                    _buildTextInput(controller: _branchController, hint: 'Yogesh Krushi Seva Kendra PM'),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Departments'),
                    _buildTextInput(controller: _departmentController, hint: 'All Departments Assigned'),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Employee Type'),
                    _buildDropdown(
                      value: _selectedEmployeeType,
                      items: const ['Full Time', 'Part Time', 'Contract', 'Intern'],
                      hint: 'eg. Full Time',
                      onChanged: (val) => setState(() => _selectedEmployeeType = val),
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Job Title'),
                    _buildTextInput(controller: _jobTitleController, hint: 'Staff Title'),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Date Of Joining'),
                    _buildDateInput(controller: _dojController, onTap: () => _pickDate(_dojController)),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Date of Leaving'),
                    _buildDateInput(controller: _dolController, onTap: () => _pickDate(_dolController)),
                    const SizedBox(height: 16),

                    _buildFieldLabel('Employee ID'),
                    _buildTextInput(controller: _employeeIdController, hint: 'EMP-0021'),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Save Details Button (Matches Image 5)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2)),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: _isSaving ? null : _saveDetails,
                  child: _isSaving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextInput({required TextEditingController controller, required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDateInput({required TextEditingController controller, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              controller.text.isNotEmpty ? controller.text : 'DD/MM/YYYY',
              style: TextStyle(
                fontSize: 15,
                color: controller.text.isNotEmpty ? Colors.black87 : Colors.grey.shade400,
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 20, color: Color(0xFF00BFA5)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : null,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
