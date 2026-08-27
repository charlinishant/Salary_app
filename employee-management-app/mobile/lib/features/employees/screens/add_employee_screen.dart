import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/employee_provider.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Section A: Personal Details
  File? _profilePhoto;
  final _firstName = TextEditingController();
  final _middleName = TextEditingController();
  final _lastName = TextEditingController();
  final _dob = TextEditingController();
  String _gender = 'MALE';
  final _phone = TextEditingController();
  final _altPhone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pinCode = TextEditingController();

  // Section B: Employment Details
  final _joiningDate = TextEditingController(text: DateTime.now().toString().split(' ')[0]);
  String _employmentType = 'FULL_TIME';
  final _reportingManager = TextEditingController();
  final _workLocation = TextEditingController(text: 'Pune Branch');
  final _salary = TextEditingController();

  // Section C: Bank Details
  final _bankName = TextEditingController();
  final _accountHolderName = TextEditingController();
  final _accountNumber = TextEditingController();
  final _confirmAccountNumber = TextEditingController();
  final _ifsc = TextEditingController();
  final _bankBranch = TextEditingController();
  final _upiId = TextEditingController();

  // Section D: Role / Permissions
  String _appRole = 'EMPLOYEE';

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profilePhoto = File(picked.path));
    }
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_accountNumber.text.isNotEmpty && _accountNumber.text != _confirmAccountNumber.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account numbers do not match!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'gender': _gender,
        'dateOfBirth': _dob.text.trim(),
        'address': _address.text.trim(),
        'joiningDate': _joiningDate.text.trim(),
        'employmentType': _employmentType,
        'reportingManager': _reportingManager.text.trim(),
        'workLocation': _workLocation.text.trim(),
        'bankName': _bankName.text.trim(),
        'accountHolderName': _accountHolderName.text.trim(),
        'accountNumber': _accountNumber.text.trim(),
        'ifsc': _ifsc.text.trim(),
        'branch': _bankBranch.text.trim(),
        'upiId': _upiId.text.trim(),
        'appRole': _appRole,
      };

      await context.read<EmployeeProvider>().createEmployee(
            payload,
            photoPath: _profilePhoto?.path,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee added successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Add New Employee', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 4) {
              setState(() => _currentStep += 1);
            } else {
              _submitForm();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: _currentStep == 4 ? (_isSubmitting ? 'Saving...' : 'Submit Employee') : 'Next Section',
                      onPressed: _isSubmitting ? null : details.onStepContinue,
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            // Step 1: Personal Details
            Step(
              title: const Text('Personal'),
              isActive: _currentStep >= 0,
              content: Column(
                children: [
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: const Color(0xFF0D9488),
                      backgroundImage: _profilePhoto != null ? FileImage(_profilePhoto!) : null,
                      child: _profilePhoto == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, color: Colors.white, size: 28),
                                Text('Photo', style: TextStyle(color: Colors.white, fontSize: 11)),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(label: 'First Name *', controller: _firstName, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Middle Name', controller: _middleName),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Last Name *', controller: _lastName, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Mobile Number *', controller: _phone, keyboardType: TextInputType.phone, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Email Address *', controller: _email, keyboardType: TextInputType.emailAddress, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'MALE', child: Text('Male')),
                      DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                      DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                    ],
                    onChanged: (val) => setState(() => _gender = val!),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Address', controller: _address),
                ],
              ),
            ),

            // Step 2: Employment Details
            Step(
              title: const Text('Employment'),
              isActive: _currentStep >= 1,
              content: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Employee ID: Auto-Generated (EMP-XXXX)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _employmentType,
                    decoration: InputDecoration(
                      labelText: 'Employment Type',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'FULL_TIME', child: Text('Permanent (Full Time)')),
                      DropdownMenuItem(value: 'CONTRACT', child: Text('Contract')),
                      DropdownMenuItem(value: 'INTERN', child: Text('Intern')),
                      DropdownMenuItem(value: 'PART_TIME', child: Text('Part Time')),
                    ],
                    onChanged: (val) => setState(() => _employmentType = val!),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Date of Joining (YYYY-MM-DD)', controller: _joiningDate),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Reporting Manager', controller: _reportingManager),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Work Location', controller: _workLocation),
                ],
              ),
            ),

            // Step 3: Bank Details
            Step(
              title: const Text('Bank'),
              isActive: _currentStep >= 2,
              content: Column(
                children: [
                  AppTextField(label: 'Bank Name', controller: _bankName),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Account Holder Name', controller: _accountHolderName),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Account Number', controller: _accountNumber, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Confirm Account Number', controller: _confirmAccountNumber, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  AppTextField(label: 'IFSC Code', controller: _ifsc),
                  const SizedBox(height: 12),
                  AppTextField(label: 'UPI ID', controller: _upiId),
                ],
              ),
            ),

            // Step 4: Role / Permissions
            Step(
              title: const Text('Role'),
              isActive: _currentStep >= 3,
              content: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _appRole,
                    decoration: InputDecoration(
                      labelText: 'App Role',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'EMPLOYEE', child: Text('EMPLOYEE (Self-Service Portal)')),
                      DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN (Full Management Access)')),
                    ],
                    onChanged: (val) => setState(() => _appRole = val!),
                  ),
                ],
              ),
            ),

            // Step 5: Document Uploads
            Step(
              title: const Text('Documents'),
              isActive: _currentStep >= 4,
              content: Column(
                children: [
                  const Icon(Icons.file_present_rounded, size: 56, color: Color(0xFF0D9488)),
                  const SizedBox(height: 8),
                  const Text('Employee document uploads can be attached after creating the profile.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
