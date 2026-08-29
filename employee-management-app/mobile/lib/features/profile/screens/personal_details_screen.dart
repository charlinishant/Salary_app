import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/session/app_session.dart';
import '../../auth/providers/auth_provider.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key, this.initialData});
  final Map<String, dynamic>? initialData;

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _guardianController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyRelController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _emergencyAddressController;

  // Government IDs
  late TextEditingController _aadhaarController;
  late TextEditingController _panController;
  late TextEditingController _drivingLicenseController;
  late TextEditingController _voterIdController;
  late TextEditingController _uanController;

  // Address
  late TextEditingController _currentAddressController;
  late TextEditingController _permanentAddressController;

  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedBloodGroup;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData ?? {};
    final auth = context.read<AuthProvider>().state.data;

    final fullName = d['name'] ?? (auth != null ? auth.name : AppSession.instance.selectedEmployeeName ?? 'Nishant More');
    final phone = d['phone'] ?? (auth != null ? auth.phone : '7249766173');
    final email = d['email'] ?? (auth != null ? auth.email : 'nishant@example.com');
    final dob = d['dateOfBirth'] != null ? d['dateOfBirth'].toString().split('T')[0] : '';

    _nameController = TextEditingController(text: fullName);
    _phoneController = TextEditingController(text: phone);
    _emailController = TextEditingController(text: email);
    _dobController = TextEditingController(text: dob);
    _selectedGender = d['gender']?.toString().toUpperCase() == 'FEMALE' ? 'Female' : 'Male';
    _selectedMaritalStatus = d['maritalStatus'] ?? 'Unmarried';
    _selectedBloodGroup = d['bloodGroup'] ?? 'O+';

    _guardianController = TextEditingController(text: d['guardianName'] ?? '');
    _emergencyNameController = TextEditingController(text: d['emergencyContactName'] ?? '');
    _emergencyRelController = TextEditingController(text: d['emergencyRelationship'] ?? 'Father');
    _emergencyPhoneController = TextEditingController(text: d['emergencyPhone'] ?? '');
    _emergencyAddressController = TextEditingController(text: d['emergencyAddress'] ?? '');

    _aadhaarController = TextEditingController(text: d['aadhaar'] ?? '');
    _panController = TextEditingController(text: d['pan'] ?? '');
    _drivingLicenseController = TextEditingController(text: d['drivingLicense'] ?? '');
    _voterIdController = TextEditingController(text: d['voterId'] ?? '');
    _uanController = TextEditingController(text: d['uan'] ?? '');

    _currentAddressController = TextEditingController(text: d['address'] ?? 'Pune, Maharashtra');
    _permanentAddressController = TextEditingController(text: d['permanentAddress'] ?? d['address'] ?? 'Pune, Maharashtra');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _guardianController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyAddressController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();
    _drivingLicenseController.dispose();
    _voterIdController.dispose();
    _uanController.dispose();
    _currentAddressController.dispose();
    _permanentAddressController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1998, 1, 1),
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveDetails() async {
    setState(() => _isSaving = true);
    try {
      final apiClient = Provider.of<ApiClient>(context, listen: false);
      final employeeId = AppSession.instance.selectedEmployeeId ?? 1;

      DateTime? parsedDob;
      if (_dobController.text.isNotEmpty) {
        try {
          if (_dobController.text.contains('/')) {
            parsedDob = DateFormat('dd/MM/yyyy').parse(_dobController.text);
          } else {
            parsedDob = DateTime.tryParse(_dobController.text);
          }
        } catch (_) {}
      }

      final payload = {
        'employeeId': employeeId,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'gender': _selectedGender?.toUpperCase(),
        if (parsedDob != null) 'dateOfBirth': parsedDob.toIso8601String(),
        'address': _currentAddressController.text.trim(),
      };

      await apiClient.put('/employees/me', data: payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal Details saved successfully!'),
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
          'Personal Details',
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
                    // --- SECTION 1: BASIC DETAILS ---
                    _buildSectionHeader('Basic Details'),
                    const SizedBox(height: 12),

                    _buildFieldLabel('Staff Name'),
                    _buildTextInput(controller: _nameController, hint: 'Nishant More'),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Mobile Number'),
                    _buildPhoneInput(controller: _phoneController),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Personal Email ID'),
                    _buildTextInput(controller: _emailController, hint: 'eg. personal_email@gmail.com', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Date Of Birth'),
                    _buildDateInput(controller: _dobController, onTap: _pickDate),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Gender'),
                    _buildDropdown(
                      value: _selectedGender,
                      items: const ['Male', 'Female', 'Other'],
                      hint: 'eg. Male',
                      onChanged: (val) => setState(() => _selectedGender = val),
                    ),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Marital Status'),
                    _buildDropdown(
                      value: _selectedMaritalStatus,
                      items: const ['Unmarried', 'Married', 'Divorced', 'Widowed'],
                      hint: 'eg. Unmarried',
                      onChanged: (val) => setState(() => _selectedMaritalStatus = val),
                    ),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Blood Group'),
                    _buildDropdown(
                      value: _selectedBloodGroup,
                      items: const ['O+', 'A+', 'B+', 'AB+', 'O-', 'A-', 'B-', 'AB-'],
                      hint: 'eg. O+',
                      onChanged: (val) => setState(() => _selectedBloodGroup = val),
                    ),
                    const SizedBox(height: 14),

                    _buildFieldLabel("Guardian's Name"),
                    _buildTextInput(controller: _guardianController, hint: 'eg. Name'),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Emergency Contact Name'),
                    _buildTextInput(controller: _emergencyNameController, hint: 'Contact Name'),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Emergency Contact Relationship'),
                    _buildTextInput(controller: _emergencyRelController, hint: 'eg. Father'),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Emergency Contact Mobile'),
                    _buildPhoneInput(controller: _emergencyPhoneController),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Emergency Contact Address'),
                    _buildTextInput(controller: _emergencyAddressController, hint: 'eg. XYZ Society, sector 101, Gurgaon'),
                    const SizedBox(height: 24),

                    // --- SECTION 2: GOVERNMENT IDS ---
                    _buildSectionHeader('Government IDs'),
                    const SizedBox(height: 12),

                    _buildFieldLabel('Aadhaar'),
                    _buildTextInput(controller: _aadhaarController, hint: 'eg. 2345 6789 0123', keyboardType: TextInputType.number),
                    const SizedBox(height: 14),

                    _buildFieldLabel('PAN'),
                    _buildTextInput(controller: _panController, hint: 'eg. ABCPD1234E', textCapitalization: TextCapitalization.characters),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Driving License'),
                    _buildTextInput(controller: _drivingLicenseController, hint: 'eg. DL01 20110012345'),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Voter ID'),
                    _buildTextInput(controller: _voterIdController, hint: 'eg. ABC1234567'),
                    const SizedBox(height: 14),

                    _buildFieldLabel('UAN'),
                    _buildTextInput(controller: _uanController, hint: 'eg. 123456789012', keyboardType: TextInputType.number),
                    const SizedBox(height: 24),

                    // --- SECTION 3: ADDRESS DETAILS ---
                    _buildSectionHeader('Address Details'),
                    const SizedBox(height: 12),

                    _buildFieldLabel('Current Address'),
                    _buildTextInput(controller: _currentAddressController, hint: 'eg. XYZ Society, sector 101, Gurgaon'),
                    const SizedBox(height: 14),

                    _buildFieldLabel('Permanent Address'),
                    _buildTextInput(controller: _permanentAddressController, hint: 'eg. XYZ Society, sector 101, Gurgaon'),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Save Details Button (Matches Images)
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

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFFF8FAFC),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
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

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
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

  Widget _buildPhoneInput({required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: const Row(
              children: [
                Text('+91', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(width: 4),
                Icon(Icons.arrow_drop_down, size: 18, color: Colors.black54),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: '7249766173',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
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
