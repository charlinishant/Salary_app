import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/shift_provider.dart';

class ShiftAssignmentScreen extends StatefulWidget {
  final int? initialShiftId;

  const ShiftAssignmentScreen({super.key, this.initialShiftId});

  @override
  State<ShiftAssignmentScreen> createState() => _ShiftAssignmentScreenState();
}

class _ShiftAssignmentScreenState extends State<ShiftAssignmentScreen> {
  int? _selectedShiftId;
  String _assignType = 'EMPLOYEE'; // 'EMPLOYEE', 'DEPARTMENT', 'BRANCH'

  final TextEditingController _effectiveFromCtrl = TextEditingController(text: DateTime.now().toString().split(' ')[0]);

  @override
  void initState() {
    super.initState();
    _selectedShiftId = widget.initialShiftId;
    Future.microtask(() => context.read<ShiftProvider>().loadShifts());
  }

  @override
  void dispose() {
    _effectiveFromCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedShiftId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a shift')));
      return;
    }

    final data = {
      'shiftId': _selectedShiftId,
      'effectiveFrom': _effectiveFromCtrl.text,
    };

    final provider = context.read<ShiftProvider>();
    final success = await provider.assignShift(data);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shift assignment updated successfully')));
      Navigator.pop(context);
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error!), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final shifts = context.watch<ShiftProvider>().shifts;
    final isLoading = context.watch<ShiftProvider>().isLoading;

    if (_selectedShiftId == null && shifts.isNotEmpty) {
      _selectedShiftId = shifts.first.id;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5ECE2),
        elevation: 0,
        title: const Text('Shift Assignment', style: TextStyle(color: Color(0xFF1B241A), fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E9DE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Shift *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedShiftId,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF4F6F2),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: shifts.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.startTime} - ${s.endTime})'))).toList(),
                  onChanged: (val) => setState(() => _selectedShiftId = val),
                ),
                const SizedBox(height: 16),
                const Text('Assign Scope', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('All Employees'),
                        selected: _assignType == 'EMPLOYEE',
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: _assignType == 'EMPLOYEE' ? Colors.white : AppColors.text),
                        onSelected: (_) => setState(() => _assignType = 'EMPLOYEE'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Effective Date *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _effectiveFromCtrl,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: const Color(0xFFF4F6F2),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
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
                : const Text('Assign Shift to Workforce', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
