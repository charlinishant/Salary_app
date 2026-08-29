import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../employees/screens/bank_account_details_screen.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ProfileProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final data = provider.state.data ?? {};
    final fullName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Employee Profile')),
      body: provider.state.status == LoadStatus.loading
          ? const AppLoader()
          : provider.state.status == LoadStatus.error
              ? AppError(message: provider.state.message, onRetry: provider.load)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _section('Personal Details', {
                      'Employee ID': data['employeeCode'],
                      'Name': fullName,
                      'Email': data['email'],
                      'Phone': data['phone'],
                      'Gender': data['gender'],
                      'Date of Birth': data['dateOfBirth'],
                      'Address': data['address'],
                    }),
                    _section('Employment Details', {
                      'Department': (data['department'] as Map?)?['name'],
                      'Designation': (data['designation'] as Map?)?['name'],
                      'Joining Date': data['joiningDate'],
                      'Employment Type': data['employmentType'],
                      'Reporting Manager': data['reportingManager'],
                      'Shift': (data['shift'] as Map?)?['name'],
                      'Work Location': data['workLocation'],
                    }),
                    _section(
                      'Bank Details',
                      {
                        'Bank Name': data['bankName'],
                        'Account Number': _mask(data['accountNumber']?.toString()),
                        'IFSC': data['ifsc'],
                        'Branch': data['branch'],
                        'Account Holder': data['accountHolderName'],
                        'UPI ID': data['upiId'],
                      },
                      onTap: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BankAccountDetailsScreen(
                              employeeId: null,
                              employeeName: fullName,
                              initialData: data,
                            ),
                          ),
                        );
                        if (updated == true && mounted) {
                          context.read<ProfileProvider>().load();
                        }
                      },
                    ),
                  ],
                ),
    );
  }

  Widget _section(String title, Map<String, dynamic> rows, {VoidCallback? onTap}) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (onTap != null)
                  const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            ...rows.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(children: [
                    Expanded(child: Text(e.key)),
                    Expanded(child: Text(e.value?.toString() ?? '--', textAlign: TextAlign.end)),
                  ]),
                )),
          ]),
        ),
  String _mask(String? value) => value == null || value.length < 4 ? '--' : '****${value.substring(value.length - 4)}';
}
