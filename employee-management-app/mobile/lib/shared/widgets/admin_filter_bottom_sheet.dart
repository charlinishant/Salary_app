import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FilterState {
  FilterState({
    this.departmentId,
    this.departmentName,
    this.designationId,
    this.designationName,
    this.shiftId,
    this.shiftName,
    this.status,
    this.employmentType,
    this.location,
  });

  int? departmentId;
  String? departmentName;
  int? designationId;
  String? designationName;
  int? shiftId;
  String? shiftName;
  String? status;
  String? employmentType;
  String? location;

  bool get hasFilters =>
      departmentId != null ||
      designationId != null ||
      shiftId != null ||
      (status != null && status!.isNotEmpty) ||
      (employmentType != null && employmentType!.isNotEmpty) ||
      (location != null && location!.isNotEmpty);

  void reset() {
    departmentId = null;
    departmentName = null;
    designationId = null;
    designationName = null;
    shiftId = null;
    shiftName = null;
    status = null;
    employmentType = null;
    location = null;
  }
}

class AdminFilterBottomSheet extends StatefulWidget {
  const AdminFilterBottomSheet({
    super.key,
    required this.initialFilters,
    required this.departments,
    required this.designations,
    required this.shifts,
    required this.onApply,
  });

  final FilterState initialFilters;
  final List<Map<String, dynamic>> departments;
  final List<Map<String, dynamic>> designations;
  final List<Map<String, dynamic>> shifts;
  final ValueChanged<FilterState> onApply;

  @override
  State<AdminFilterBottomSheet> createState() => _AdminFilterBottomSheetState();
}

class _AdminFilterBottomSheetState extends State<AdminFilterBottomSheet> {
  late FilterState _filters;

  @override
  void initState() {
    super.initState();
    _filters = FilterState(
      departmentId: widget.initialFilters.departmentId,
      departmentName: widget.initialFilters.departmentName,
      designationId: widget.initialFilters.designationId,
      designationName: widget.initialFilters.designationName,
      shiftId: widget.initialFilters.shiftId,
      shiftName: widget.initialFilters.shiftName,
      status: widget.initialFilters.status,
      employmentType: widget.initialFilters.employmentType,
      location: widget.initialFilters.location,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Employees',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Department
            _buildDropdown(
              label: 'Department',
              value: _filters.departmentId,
              items: widget.departments.map((d) => DropdownMenuItem<int>(
                value: d['id'] as int,
                child: Text(d['name'] as String),
              )).toList(),
              onChanged: (val) {
                setState(() {
                  _filters.departmentId = val;
                  _filters.departmentName = widget.departments.firstWhere((d) => d['id'] == val, orElse: () => {})['name'] as String?;
                });
              },
            ),
            const SizedBox(height: 12),

            // Designation
            _buildDropdown(
              label: 'Designation',
              value: _filters.designationId,
              items: widget.designations.map((d) => DropdownMenuItem<int>(
                value: d['id'] as int,
                child: Text(d['name'] as String),
              )).toList(),
              onChanged: (val) {
                setState(() {
                  _filters.designationId = val;
                  _filters.designationName = widget.designations.firstWhere((d) => d['id'] == val, orElse: () => {})['name'] as String?;
                });
              },
            ),
            const SizedBox(height: 12),

            // Shift
            _buildDropdown(
              label: 'Shift',
              value: _filters.shiftId,
              items: widget.shifts.map((s) => DropdownMenuItem<int>(
                value: s['id'] as int,
                child: Text(s['name'] as String),
              )).toList(),
              onChanged: (val) {
                setState(() {
                  _filters.shiftId = val;
                  _filters.shiftName = widget.shifts.firstWhere((s) => s['id'] == val, orElse: () => {})['name'] as String?;
                });
              },
            ),
            const SizedBox(height: 12),

            // Status
            _buildDropdownString(
              label: 'Status',
              value: _filters.status,
              items: const [
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
              ],
              onChanged: (val) => setState(() => _filters.status = val),
            ),
            const SizedBox(height: 12),

            // Employment Type
            _buildDropdownString(
              label: 'Employment Type',
              value: _filters.employmentType,
              items: const [
                DropdownMenuItem(value: 'FULL_TIME', child: Text('Full Time')),
                DropdownMenuItem(value: 'PART_TIME', child: Text('Part Time')),
                DropdownMenuItem(value: 'CONTRACT', child: Text('Contract')),
                DropdownMenuItem(value: 'INTERN', child: Text('Intern')),
              ],
              onChanged: (val) => setState(() => _filters.employmentType = val),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      setState(() => _filters.reset());
                    },
                    child: const Text('RESET', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      widget.onApply(_filters);
                      Navigator.of(context).pop();
                    },
                    child: const Text('APPLY FILTERS', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        DropdownButtonFormField<T>(
          value: value,
          items: [
            DropdownMenuItem<T>(value: null, child: const Text('[ All ]')),
            ...items,
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownString({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          items: [
            const DropdownMenuItem<String>(value: null, child: Text('[ All ]')),
            ...items,
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
