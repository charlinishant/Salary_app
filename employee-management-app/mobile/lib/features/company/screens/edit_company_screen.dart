import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/company_model.dart';
import '../providers/company_provider.dart';

class EditCompanyScreen extends StatefulWidget {
  final CompanyModel company;

  const EditCompanyScreen({super.key, required this.company});

  @override
  State<EditCompanyScreen> createState() => _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _legalNameController;
  late TextEditingController _codeController;
  late TextEditingController _industryController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _gstinController;
  late TextEditingController _panController;
  late TextEditingController _tanController;
  late TextEditingController _pfController;
  late TextEditingController _esiController;
  late TextEditingController _ptController;

  @override
  void initState() {
    super.initState();
    final c = widget.company;
    _nameController = TextEditingController(text: c.name);
    _legalNameController = TextEditingController(text: c.legalName);
    _codeController = TextEditingController(text: c.companyCode);
    _industryController = TextEditingController(text: c.industry);
    _emailController = TextEditingController(text: c.email);
    _phoneController = TextEditingController(text: c.phone);
    _websiteController = TextEditingController(text: c.website);
    _addressController = TextEditingController(text: c.address);
    _cityController = TextEditingController(text: c.city);
    _stateController = TextEditingController(text: c.state);
    _postalCodeController = TextEditingController(text: c.postalCode);
    _gstinController = TextEditingController(text: c.gstin);
    _panController = TextEditingController(text: c.pan);
    _tanController = TextEditingController(text: c.tan);
    _pfController = TextEditingController(text: c.pfNumber);
    _esiController = TextEditingController(text: c.esiNumber);
    _ptController = TextEditingController(text: c.ptNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _legalNameController.dispose();
    _codeController.dispose();
    _industryController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _tanController.dispose();
    _pfController.dispose();
    _esiController.dispose();
    _ptController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text.trim(),
      'legalName': _legalNameController.text.trim(),
      'companyCode': _codeController.text.trim(),
      'industry': _industryController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'website': _websiteController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'postalCode': _postalCodeController.text.trim(),
      'gstin': _gstinController.text.trim(),
      'pan': _panController.text.trim(),
      'tan': _tanController.text.trim(),
      'pfNumber': _pfController.text.trim(),
      'esiNumber': _esiController.text.trim(),
      'ptNumber': _ptController.text.trim(),
    };

    final success = await context.read<CompanyProvider>().updateCompany(data);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<CompanyProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5ECE2),
        elevation: 0,
        title: const Text('Edit Company Profile', style: TextStyle(color: Color(0xFF1B241A), fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(_nameController, 'Company Name *', required: true),
            _buildTextField(_legalNameController, 'Legal Business Name'),
            _buildTextField(_codeController, 'Company Code *', required: true),
            _buildTextField(_industryController, 'Industry'),
            _buildTextField(_emailController, 'Company Email', keyboardType: TextInputType.emailAddress),
            _buildTextField(_phoneController, 'Phone Number', keyboardType: TextInputType.phone),
            _buildTextField(_websiteController, 'Website'),
            _buildTextField(_addressController, 'Address'),
            Row(
              children: [
                Expanded(child: _buildTextField(_cityController, 'City')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(_stateController, 'State')),
              ],
            ),
            _buildTextField(_postalCodeController, 'PIN / Postal Code'),
            const SizedBox(height: 16),
            const Text('Registration & Tax Numbers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildTextField(_gstinController, 'GSTIN'),
            _buildTextField(_panController, 'PAN'),
            _buildTextField(_tanController, 'TAN'),
            _buildTextField(_pfController, 'PF Registration No'),
            _buildTextField(_esiController, 'ESI Registration No'),
            _buildTextField(_ptController, 'Professional Tax No'),
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
                  : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
