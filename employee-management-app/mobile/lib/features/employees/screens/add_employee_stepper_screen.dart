import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../providers/employee_provider.dart';

class AddEmployeeStepperScreen extends StatefulWidget {
  const AddEmployeeStepperScreen({super.key});

  @override
  State<AddEmployeeStepperScreen> createState() => _AddEmployeeStepperScreenState();
}

class _AddEmployeeStepperScreenState extends State<AddEmployeeStepperScreen> {
  int _currentStep = 0;
  bool _isSaving = false;

  // Step 1: Personal Details
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _gender = 'MALE';
  final _dobController = TextEditingController();
  final _mobileController = TextEditingController();
  final _altMobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentAddressController = TextEditingController();
  final _permanentAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pinCodeController = TextEditingController();

  // Step 2: Employment Details
  final _employeeCodeController = TextEditingController(text: 'EMP-0011');
  String? _departmentId = '1';
  String? _designationId = '1';
  final _joiningDateController = TextEditingController(text: DateTime.now().toString().split(' ')[0]);
  String _employmentType = 'FULL_TIME';
  final _managerController = TextEditingController(text: 'Kuldeep Kumavat');
  String? _shiftId = '1';
  final _locationController = TextEditingController(text: 'Pune Main Branch');
  final _salaryController = TextEditingController(text: '40000');

  // Step 3: Bank Details
  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _accountNoController = TextEditingController();
  final _confirmAccountNoController = TextEditingController();
  final _ifscController = TextEditingController();
  final _branchController = TextEditingController();
  final _upiIdController = TextEditingController();

  // Step 5: Permissions
  bool _permAttendance = true;
  bool _permLeave = true;
  bool _permExpenses = true;
  bool _permTrips = true;
  bool _permNotes = true;
  bool _permDocuments = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _altMobileController.dispose();
    _emailController.dispose();
    _currentAddressController.dispose();
    _permanentAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    _employeeCodeController.dispose();
    _joiningDateController.dispose();
    _managerController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNoController.dispose();
    _confirmAccountNoController.dispose();
    _ifscController.dispose();
    _branchController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> _saveEmployee() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _mobileController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete required fields (First name, Last name, Mobile, Email)')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
      await employeeProvider.createEmployee({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _mobileController.text.trim(),
        'gender': _gender,
        'dateOfBirth': _dobController.text.isNotEmpty ? _dobController.text : null,
        'address': '${_currentAddressController.text} ${_cityController.text}'.trim(),
        'departmentId': _departmentId != null ? int.parse(_departmentId!) : 1,
        'designationId': _designationId != null ? int.parse(_designationId!) : 1,
        'shiftId': _shiftId != null ? int.parse(_shiftId!) : 1,
        'joiningDate': _joiningDateController.text.isNotEmpty ? _joiningDateController.text : DateTime.now().toIso8601String().split('T').first,
        'employmentType': _employmentType,
        'reportingManager': _managerController.text,
        'workLocation': _locationController.text,
        'bankName': _bankNameController.text,
        'accountNumber': _accountNoController.text,
        'ifsc': _ifscController.text,
        'branch': _branchController.text,
        'accountHolderName': _accountHolderController.text,
        'upiId': _upiIdController.text,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee added successfully!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding employee: $msg'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New Employee', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 4) {
            setState(() => _currentStep += 1);
          } else {
            _saveEmployee();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('PREVIOUS'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isSaving ? null : details.onStepContinue,
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                        : Text(_currentStep == 4 ? 'SAVE EMPLOYEE' : 'NEXT'),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          // STEP 1: Personal Details
          Step(
            title: const Text('Personal'),
            isActive: _currentStep >= 0,
            content: Column(
              children: [
                _buildTextField(_firstNameController, 'First Name *'),
                _buildTextField(_middleNameController, 'Middle Name'),
                _buildTextField(_lastNameController, 'Last Name *'),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: const [
                    DropdownMenuItem(value: 'MALE', child: Text('Male')),
                    DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                    DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                  ],
                  onChanged: (val) => setState(() => _gender = val!),
                ),
                _buildTextField(_dobController, 'Date of Birth (YYYY-MM-DD)'),
                _buildTextField(_mobileController, 'Mobile Number *', keyboardType: TextInputType.phone),
                _buildTextField(_altMobileController, 'Alternate Mobile'),
                _buildTextField(_emailController, 'Email Address *', keyboardType: TextInputType.emailAddress),
                _buildTextField(_currentAddressController, 'Current Address'),
                _buildTextField(_cityController, 'City'),
                _buildTextField(_stateController, 'State'),
                _buildTextField(_pinCodeController, 'PIN Code'),
              ],
            ),
          ),

          // STEP 2: Employment Details
          Step(
            title: const Text('Employment'),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                _buildTextField(_employeeCodeController, 'Employee Code (Auto-generated)', enabled: false),
                DropdownButtonFormField<String>(
                  value: _departmentId,
                  decoration: const InputDecoration(labelText: 'Department *'),
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('HR')),
                    DropdownMenuItem(value: '2', child: Text('Sales')),
                    DropdownMenuItem(value: '3', child: Text('Engineering')),
                    DropdownMenuItem(value: '4', child: Text('Finance')),
                  ],
                  onChanged: (val) => setState(() => _departmentId = val),
                ),
                DropdownButtonFormField<String>(
                  value: _designationId,
                  decoration: const InputDecoration(labelText: 'Designation *'),
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('HR Manager')),
                    DropdownMenuItem(value: '2', child: Text('Sales Executive')),
                    DropdownMenuItem(value: '3', child: Text('Senior Developer')),
                    DropdownMenuItem(value: '4', child: Text('Accountant')),
                  ],
                  onChanged: (val) => setState(() => _designationId = val),
                ),
                _buildTextField(_joiningDateController, 'Date of Joining *'),
                DropdownButtonFormField<String>(
                  value: _employmentType,
                  decoration: const InputDecoration(labelText: 'Employment Type'),
                  items: const [
                    DropdownMenuItem(value: 'FULL_TIME', child: Text('Full Time')),
                    DropdownMenuItem(value: 'PART_TIME', child: Text('Part Time')),
                    DropdownMenuItem(value: 'CONTRACT', child: Text('Contract')),
                    DropdownMenuItem(value: 'INTERN', child: Text('Intern')),
                  ],
                  onChanged: (val) => setState(() => _employmentType = val!),
                ),
                _buildTextField(_managerController, 'Reporting Manager'),
                _buildTextField(_locationController, 'Work Location'),
                _buildTextField(_salaryController, 'Gross Salary (Monthly)'),
              ],
            ),
          ),

          // STEP 3: Bank Details
          Step(
            title: const Text('Bank'),
            isActive: _currentStep >= 2,
            content: Column(
              children: [
                _buildTextField(_bankNameController, 'Bank Name'),
                _buildTextField(_accountHolderController, 'Account Holder Name'),
                _buildTextField(_accountNoController, 'Account Number'),
                _buildTextField(_confirmAccountNoController, 'Confirm Account Number'),
                _buildTextField(_ifscController, 'IFSC Code'),
                _buildTextField(_branchController, 'Branch Name'),
                _buildTextField(_upiIdController, 'UPI ID'),
              ],
            ),
          ),

          // STEP 4: Documents
          Step(
            title: const Text('Documents'),
            isActive: _currentStep >= 3,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Upload Employee Documents (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildDocUploadCard('Aadhaar Card', Icons.badge_outlined),
                _buildDocUploadCard('PAN Card', Icons.credit_card_outlined),
                _buildDocUploadCard('Joining Letter', Icons.description_outlined),
              ],
            ),
          ),

          // STEP 5: Permissions
          Step(
            title: const Text('Permissions'),
            isActive: _currentStep >= 4,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Module Access Permissions', style: TextStyle(fontWeight: FontWeight.bold)),
                SwitchListTile(
                  title: const Text('Attendance Access'),
                  value: _permAttendance,
                  onChanged: (v) => setState(() => _permAttendance = v),
                ),
                SwitchListTile(
                  title: const Text('Leave Management'),
                  value: _permLeave,
                  onChanged: (v) => setState(() => _permLeave = v),
                ),
                SwitchListTile(
                  title: const Text('Expense Reimbursement'),
                  value: _permExpenses,
                  onChanged: (v) => setState(() => _permExpenses = v),
                ),
                SwitchListTile(
                  title: const Text('Trips & Meetings'),
                  value: _permTrips,
                  onChanged: (v) => setState(() => _permTrips = v),
                ),
                SwitchListTile(
                  title: const Text('Employee Documents'),
                  value: _permDocuments,
                  onChanged: (v) => setState(() => _permDocuments = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool enabled = true, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildDocUploadCard(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: OutlinedButton(
          onPressed: () {},
          child: const Text('Upload'),
        ),
      ),
    );
  }
}
