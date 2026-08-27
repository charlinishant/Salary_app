import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/department_model.dart';
import '../providers/department_provider.dart';

class DepartmentFormScreen extends StatefulWidget {
  final DepartmentModel? department;

  const DepartmentFormScreen({super.key, this.department});

  @override
  State<DepartmentFormScreen> createState() => _DepartmentFormScreenState();
}

class _DepartmentFormScreenState extends State<DepartmentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final d = widget.department;
    _nameController = TextEditingController(text: d?.name ?? '');
    _codeController = TextEditingController(text: d?.code ?? '');
    _descController = TextEditingController(text: d?.description ?? '');
    _isActive = d?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'description': _descController.text.trim(),
      'isActive': _isActive,
    };

    final provider = context.read<DepartmentProvider>();
    bool success = false;

    if (widget.department == null) {
      success = await provider.createDepartment(data);
    } else {
      success = await provider.updateDepartment(widget.department!.id, data);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.department == null ? 'Department created' : 'Department updated')),
      );
      Navigator.pop(context);
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.department != null;
    final isLoading = context.watch<DepartmentProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5ECE2),
        elevation: 0,
        title: Text(isEditing ? 'Edit Department' : 'Add Department', style: const TextStyle(color: Color(0xFF1B241A), fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(_nameController, 'Department Name *', required: true),
            _buildTextField(_codeController, 'Department Code (e.g. DEP-HR)'),
            _buildTextField(_descController, 'Description', maxLines: 3),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Active Status', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(_isActive ? 'Department is active' : 'Department is inactive'),
              value: _isActive,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _isActive = val),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(isEditing ? 'Update Department' : 'Create Department', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) {
            return '$label is required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E9DE))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E9DE))),
        ),
      ),
    );
  }
}
