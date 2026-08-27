import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/leave_policy_provider.dart';

class LeaveTypesScreen extends StatelessWidget {
  const LeaveTypesScreen({super.key});

  void _showAddTypeDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final allocCtrl = TextEditingController(text: '12');
    bool isPaid = true;
    bool carryForward = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Leave Type'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Leave Name *')),
                const SizedBox(height: 8),
                TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Code (e.g. CL)')),
                const SizedBox(height: 8),
                TextField(controller: allocCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Annual Allocation (Days)')),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Paid Leave'),
                  value: isPaid,
                  onChanged: (val) => setState(() => isPaid = val ?? true),
                ),
                CheckboxListTile(
                  title: const Text('Allow Carry Forward'),
                  value: carryForward,
                  onChanged: (val) => setState(() => carryForward = val ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                final data = {
                  'name': nameCtrl.text.trim(),
                  'code': codeCtrl.text.trim(),
                  'annualAllocation': double.tryParse(allocCtrl.text.trim()) ?? 12,
                  'isPaid': isPaid,
                  'carryForward': carryForward,
                };
                final success = await context.read<LeavePolicyProvider>().createLeaveType(data);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave type created')));
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeavePolicyProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTypeDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.leaveTypes.length,
                  itemBuilder: (context, index) {
                    final type = provider.leaveTypes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E9DE)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE5ECE2),
                          child: Icon(type.isPaid ? Icons.monetization_on_outlined : Icons.money_off_outlined, color: AppColors.primary),
                        ),
                        title: Text(type.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(
                          'Code: ${type.code ?? 'N/A'} • ${type.isPaid ? 'Paid' : 'Unpaid'} • ${type.annualAllocation.toInt()} Days/Year',
                          style: const TextStyle(fontSize: 13, color: AppColors.muted),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: type.carryForward ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            type.carryForward ? 'Carry Forward' : 'No Carry',
                            style: TextStyle(color: type.carryForward ? Colors.blue[800] : Colors.grey[800], fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
