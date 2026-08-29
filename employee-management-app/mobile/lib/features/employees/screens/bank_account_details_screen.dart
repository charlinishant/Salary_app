import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/api_client.dart';
import '../providers/employee_provider.dart';

enum BankPaymentType { bankAccount, upi }

class BankAccountDetailsScreen extends StatefulWidget {
  final int? employeeId;
  final String employeeName;
  final Map<String, dynamic>? initialData;

  const BankAccountDetailsScreen({
    super.key,
    this.employeeId,
    required this.employeeName,
    this.initialData,
  });

  @override
  State<BankAccountDetailsScreen> createState() => _BankAccountDetailsScreenState();
}

class _BankAccountDetailsScreenState extends State<BankAccountDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late BankPaymentType _selectedType;

  late final TextEditingController _accountHolderController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _ifscController;
  late final TextEditingController _upiController;

  bool _isSaving = false;

  // Teal brand colors matching the design screenshot
  static const Color _tealPrimary = Color(0xFF00C292);
  static const Color _tealLight = Color(0xFFE8F8F5);
  static const Color _borderGrey = Color(0xFFE0E0E0);
  static const Color _labelGrey = Color(0xFF555555);
  static const Color _hintGrey = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    final data = widget.initialData ?? {};

    final hasUpiOnly = (data['upiId'] != null && data['upiId'].toString().trim().isNotEmpty) &&
        (data['accountNumber'] == null || data['accountNumber'].toString().trim().isEmpty);

    _selectedType = hasUpiOnly ? BankPaymentType.upi : BankPaymentType.bankAccount;

    _accountHolderController = TextEditingController(
      text: data['accountHolderName']?.toString() ?? widget.employeeName,
    );
    _accountNumberController = TextEditingController(
      text: data['accountNumber']?.toString() ?? '',
    );
    _bankNameController = TextEditingController(
      text: data['bankName']?.toString() ?? '',
    );
    _ifscController = TextEditingController(
      text: data['ifsc']?.toString() ?? '',
    );
    _upiController = TextEditingController(
      text: data['upiId']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final payload = <String, dynamic>{
        'accountHolderName': _accountHolderController.text.trim(),
        'bankName': _selectedType == BankPaymentType.bankAccount ? _bankNameController.text.trim() : null,
        'accountNumber': _selectedType == BankPaymentType.bankAccount ? _accountNumberController.text.trim() : null,
        'ifsc': _selectedType == BankPaymentType.bankAccount ? _ifscController.text.trim().toUpperCase() : null,
        'upiId': _selectedType == BankPaymentType.upi ? _upiController.text.trim() : (_upiController.text.trim().isNotEmpty ? _upiController.text.trim() : null),
      };

      final apiClient = context.read<ApiClient>();

      if (widget.employeeId != null) {
        await apiClient.put('/employees/${widget.employeeId}', data: payload);
        if (mounted) {
          context.read<EmployeeProvider>().loadDetail(widget.employeeId!);
        }
      } else {
        await apiClient.put('/employees/me', data: payload);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bank details saved successfully!'),
          backgroundColor: _tealPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save bank details: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.employeeName.trim().isNotEmpty
        ? widget.employeeName.trim()
        : 'Employee';
    final title = "$displayName's Bank Account Details";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Toggle Cards (Bank Account / UPI)
                      Row(
                        children: [
                          Expanded(
                            child: _buildTypeCard(
                              type: BankPaymentType.bankAccount,
                              title: 'Bank Account',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildTypeCard(
                              type: BankPaymentType.upi,
                              title: 'UPI',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Form Fields Based on Selected Mode
                      if (_selectedType == BankPaymentType.bankAccount) ...[
                        _buildInputField(
                          label: "Account Holder's Name",
                          hintText: 'Enter Name',
                          controller: _accountHolderController,
                          validator: (v) => v == null || v.trim().isEmpty ? "Please enter account holder's name" : null,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: 'Account Number',
                          hintText: 'Enter Account Number',
                          controller: _accountNumberController,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (_selectedType == BankPaymentType.bankAccount) {
                              if (v == null || v.trim().isEmpty) return 'Please enter account number';
                              if (v.trim().length < 8) return 'Please enter a valid account number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: 'Bank Name',
                          hintText: 'Enter Bank Name',
                          controller: _bankNameController,
                          validator: (v) {
                            if (_selectedType == BankPaymentType.bankAccount && (v == null || v.trim().isEmpty)) {
                              return 'Please enter bank name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: 'IFSC Code',
                          hintText: 'Enter IFSC Code',
                          controller: _ifscController,
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) {
                            if (_selectedType == BankPaymentType.bankAccount) {
                              if (v == null || v.trim().isEmpty) return 'Please enter IFSC code';
                              if (v.trim().length != 11) return 'IFSC code must be 11 characters';
                            }
                            return null;
                          },
                        ),
                      ] else ...[
                        _buildInputField(
                          label: "Account Holder's Name",
                          hintText: 'Enter Name',
                          controller: _accountHolderController,
                          validator: (v) => v == null || v.trim().isEmpty ? "Please enter account holder's name" : null,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: 'UPI ID / VPA',
                          hintText: 'Enter UPI ID (e.g. mobile@upi or name@okaxis)',
                          controller: _upiController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (_selectedType == BankPaymentType.upi) {
                              if (v == null || v.trim().isEmpty) return 'Please enter UPI ID';
                              if (!v.contains('@')) return 'Please enter a valid UPI ID (e.g. username@upi)';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Save Details Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tealPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: _tealPrimary.withOpacity(0.6),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({required BankPaymentType type, required String title}) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? _tealLight : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _tealPrimary : _borderGrey,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? _tealPrimary : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? _tealPrimary : Colors.black87,
                  fontSize: 14.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _labelGrey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: _hintGrey,
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _borderGrey, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _borderGrey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _tealPrimary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
