import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/shift_model.dart';
import '../providers/shift_provider.dart';

class ShiftFormScreen extends StatefulWidget {
  final ShiftModel? shift;

  const ShiftFormScreen({super.key, this.shift});

  @override
  State<ShiftFormScreen> createState() => _ShiftFormScreenState();
}

class _ShiftFormScreenState extends State<ShiftFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _graceController;
  late TextEditingController _breakController;
  late TextEditingController _lateMarkController;
  late TextEditingController _earlyExitController;
  late TextEditingController _overtimeController;

  String _weeklyOff = 'Sunday';
  bool _isOvernight = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final s = widget.shift;
    _nameController = TextEditingController(text: s?.name ?? '');
    _codeController = TextEditingController(text: s?.code ?? '');
    _startTimeController = TextEditingController(text: s?.startTime ?? '09:30');
    _endTimeController = TextEditingController(text: s?.endTime ?? '18:30');
    _graceController = TextEditingController(text: s?.graceMinutes.toString() ?? '15');
    _breakController = TextEditingController(text: s?.breakMinutes.toString() ?? '60');
    _lateMarkController = TextEditingController(text: s?.lateMarkAfter.toString() ?? '15');
    _earlyExitController = TextEditingController(text: s?.earlyExitBefore.toString() ?? '15');
    _overtimeController = TextEditingController(text: s?.overtimeAfter.toString() ?? '480');
    _weeklyOff = s?.weeklyOff ?? 'Sunday';
    _isOvernight = s?.isOvernight ?? false;
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _graceController.dispose();
    _breakController.dispose();
    _lateMarkController.dispose();
    _earlyExitController.dispose();
    _overtimeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() => controller.text = formatted);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text.trim(),
      'code': _codeController.text.trim(),
      'startTime': _startTimeController.text.trim(),
      'endTime': _endTimeController.text.trim(),
      'graceMinutes': int.tryParse(_graceController.text.trim()) ?? 15,
      'breakMinutes': int.tryParse(_breakController.text.trim()) ?? 60,
      'lateMarkAfter': int.tryParse(_lateMarkController.text.trim()) ?? 15,
      'earlyExitBefore': int.tryParse(_earlyExitController.text.trim()) ?? 15,
      'overtimeAfter': int.tryParse(_overtimeController.text.trim()) ?? 480,
      'weeklyOff': _weeklyOff,
      'isOvernight': _isOvernight,
      'isActive': _isActive,
    };

    final provider = context.read<ShiftProvider>();
    bool success = false;

    if (widget.shift == null) {
      success = await provider.createShift(data);
    } else {
      success = await provider.updateShift(widget.shift!.id, data);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.shift == null ? 'Shift created' : 'Shift updated')),
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
    final isEditing = widget.shift != null;
    final isLoading = context.watch<ShiftProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5ECE2),
        elevation: 0,
        title: Text(isEditing ? 'Edit Shift' : 'Add Shift', style: const TextStyle(color: Color(0xFF1B241A), fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(_nameController, 'Shift Name *', required: true),
            _buildTextField(_codeController, 'Shift Code (e.g. SFT-GEN)'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startTimeController,
                    readOnly: true,
                    onTap: () => _selectTime(_startTimeController),
                    decoration: InputDecoration(
                      labelText: 'Start Time *',
                      suffixIcon: const Icon(Icons.access_time),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _endTimeController,
                    readOnly: true,
                    onTap: () => _selectTime(_endTimeController),
                    decoration: InputDecoration(
                      labelText: 'End Time *',
                      suffixIcon: const Icon(Icons.access_time),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField(_graceController, 'Grace Time (Min)', keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(_breakController, 'Break (Min)', keyboardType: TextInputType.number)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildTextField(_lateMarkController, 'Late Mark After (Min)', keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(_earlyExitController, 'Early Exit Before (Min)', keyboardType: TextInputType.number)),
              ],
            ),
            DropdownButtonFormField<String>(
              value: _weeklyOff,
              decoration: InputDecoration(
                labelText: 'Weekly Off Day',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['Sunday', 'Saturday + Sunday', 'Alternate Saturdays', 'Custom'].map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
              onChanged: (val) => setState(() => _weeklyOff = val!),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Overnight Shift', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Check if shift spans across midnight (e.g. 09:00 PM to 06:00 AM)'),
              value: _isOvernight,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => _isOvernight = val),
            ),
            SwitchListTile(
              title: const Text('Active Status', style: TextStyle(fontWeight: FontWeight.w600)),
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
                  : Text(isEditing ? 'Update Shift' : 'Create Shift', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
