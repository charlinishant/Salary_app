import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/leave_policy_provider.dart';

class LeavePoliciesScreen extends StatelessWidget {
  const LeavePoliciesScreen({super.key});

  void _showAddPolicyDialog(BuildContext context) {
    final provider = context.read<LeavePolicyProvider>();
    final types = provider.leaveTypes;

    if (types.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please create a Leave Type first')));
      return;
    }

    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController(text: '12');
    final noticeCtrl = TextEditingController(text: '1');
    final maxConsCtrl = TextEditingController(text: '14');
    int selectedTypeId = types.first.id;
    bool allowNegative = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Leave Policy'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Policy Name *')),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: selectedTypeId,
                  decoration: const InputDecoration(labelText: 'Leave Type *'),
                  items: types.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                  onChanged: (val) => setState(() => selectedTypeId = val!),
                ),
                const SizedBox(height: 8),
                TextField(controller: balanceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Annual Balance (Days)')),
                const SizedBox(height: 8),
                TextField(controller: noticeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min Notice Period (Days)')),
                const SizedBox(height: 8),
                TextField(controller: maxConsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max Consecutive Days')),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Allow Negative Balance'),
                  value: allowNegative,
                  onChanged: (val) => setState(() => allowNegative = val ?? false),
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
                  'leaveTypeId': selectedTypeId,
                  'annualBalance': double.tryParse(balanceCtrl.text.trim()) ?? 12,
                  'minNoticePeriodDays': int.tryParse(noticeCtrl.text.trim()) ?? 1,
                  'maxConsecutiveDays': int.tryParse(maxConsCtrl.text.trim()) ?? 14,
                  'allowNegativeBalance': allowNegative,
                };
                final success = await provider.createLeavePolicy(data);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave policy created')));
                }
              },
              child: const Text('Create Policy'),
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
        onPressed: () => _showAddPolicyDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)))
              : provider.leavePolicies.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.policy_outlined, size: 64, color: AppColors.muted),
                          const SizedBox(height: 12),
                          const Text('No leave policies configured', style: TextStyle(fontSize: 16, color: AppColors.muted)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.leavePolicies.length,
                      itemBuilder: (context, index) {
                        final policy = provider.leavePolicies[index];
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
                              child: const Icon(Icons.gavel_outlined, color: AppColors.primary),
                            ),
                            title: Text(policy.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Leave Type: ${policy.leaveType?.name ?? 'General'}', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                                  const SizedBox(height: 2),
                                  Text('Balance: ${policy.annualBalance.toInt()} Days • Max Cons: ${policy.maxConsecutiveDays} Days', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: policy.allowNegativeBalance ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                policy.allowNegativeBalance ? 'Negative Allowed' : 'Strict Balance',
                                style: TextStyle(color: policy.allowNegativeBalance ? Colors.orange[800] : Colors.green[800], fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
