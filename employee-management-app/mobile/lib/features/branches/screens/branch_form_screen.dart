import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/branch_model.dart';
import '../providers/branch_provider.dart';

class BranchFormScreen extends StatefulWidget {
  final BranchModel? branch;

  const BranchFormScreen({super.key, this.branch});

  @override
  State<BranchFormScreen> createState() => _BranchFormScreenState();
}

class _BranchFormScreenState extends State<BranchFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _postalCodeController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _radiusController;

  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final b = widget.branch;
    _nameController = TextEditingController(text: b?.name ?? '');
    _codeController = TextEditingController(text: b?.code ?? '');
    _addressController = TextEditingController(text: b?.address ?? '');
    _cityController = TextEditingController(text: b?.city ?? '');
    _stateController = TextEditingController(text: b?.state ?? '');
    _countryController = TextEditingController(text: b?.country ?? 'India');
    _postalCodeController = TextEditingController(text: b?.postalCode ?? '');
    _phoneController = TextEditingController(text: b?.phone ?? '');
    _emailController = TextEditingController(text: b?.email ?? '');
    _latController = TextEditingController(text: b?.latitude?.toString() ?? '');
    _lngController = TextEditingController(text: b?.longitude?.toString() ?? '');
    _radiusController = TextEditingController(text: b?.geofenceRadius.toInt().toString() ?? '100');
    _isActive = b?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'country': _countryController.text.trim(),
      'postalCode': _postalCodeController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'latitude': _latController.text.isNotEmpty ? double.tryParse(_latController.text.trim()) : null,
      'longitude': _lngController.text.isNotEmpty ? double.tryParse(_lngController.text.trim()) : null,
      'geofenceRadius': _radiusController.text.isNotEmpty ? double.tryParse(_radiusController.text.trim()) : 100,
      'isActive': _isActive,
    };

    final provider = context.read<BranchProvider>();
    bool success = false;

    if (widget.branch == null) {
      success = await provider.createBranch(data);
    } else {
      success = await provider.updateBranch(widget.branch!.id, data);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.branch == null ? 'Branch created' : 'Branch updated')),
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
    final isEditing = widget.branch != null;
    final isLoading = context.watch<BranchProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5ECE2),
        elevation: 0,
        title: Text(isEditing ? 'Edit Branch' : 'Add Branch', style: const TextStyle(color: Color(0xFF1B241A), fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(_nameController, 'Branch Name *', required: true),
            _buildTextField(_codeController, 'Branch Code *', required: true),
            _buildTextField(_addressController, 'Address'),
            Row(
              children: [
                Expanded(child: _buildTextField(_cityController, 'City')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(_stateController, 'State')),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildTextField(_countryController, 'Country')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(_postalCodeController, 'PIN Code')),
              ],
            ),
            _buildTextField(_phoneController, 'Phone Number', keyboardType: TextInputType.phone),
            _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            const Text('GPS Attendance Location & Geofence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildTextField(_latController, 'Latitude (e.g. 18.5204)', keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(_lngController, 'Longitude (e.g. 73.8567)', keyboardType: TextInputType.number)),
              ],
            ),
            _buildTextField(_radiusController, 'Allowed Radius (Meters)', keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Active Status', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(_isActive ? 'Branch is active for attendance and assignments' : 'Branch is inactive'),
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
                  : Text(isEditing ? 'Update Branch' : 'Save Branch', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool required = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
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
