import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/role_model.dart';
import '../providers/role_provider.dart';

class PermissionMatrixScreen extends StatefulWidget {
  final RoleModel role;

  const PermissionMatrixScreen({super.key, required this.role});

  @override
  State<PermissionMatrixScreen> createState() => _PermissionMatrixScreenState();
}

class _PermissionMatrixScreenState extends State<PermissionMatrixScreen> {
  late List<RolePermissionModel> _permissions;

  @override
  void initState() {
    super.initState();
    _initPermissions();
  }

  void _initPermissions() {
    final allPerms = context.read<RoleProvider>().allPermissions;
    final rolePerms = widget.role.permissions;

    _permissions = allPerms.map((p) {
      final existing = rolePerms.firstWhere(
        (rp) => rp.code == p.code,
        orElse: () => RolePermissionModel(
          permissionId: p.permissionId,
          code: p.code,
          category: p.category,
          name: p.name,
          canView: false,
          canCreate: false,
          canEdit: false,
          canApprove: false,
          canDelete: false,
        ),
      );
      return RolePermissionModel(
        permissionId: p.permissionId,
        code: p.code,
        category: p.category,
        name: p.name,
        canView: existing.canView,
        canCreate: existing.canCreate,
        canEdit: existing.canEdit,
        canApprove: existing.canApprove,
        canDelete: existing.canDelete,
      );
    }).toList();
  }

  Future<void> _save() async {
    final success = await context.read<RoleProvider>().updatePermissions(
          widget.role.id,
          _permissions,
        );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissions matrix updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<RoleProvider>().isLoading;

    final categories = <String, List<RolePermissionModel>>{};
    for (var p in _permissions) {
      categories.putIfAbsent(p.category, () => []).add(p);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5ECE2),
        elevation: 0,
        title: Text('${widget.role.name} Permissions', style: const TextStyle(color: Color(0xFF1B241A), fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primary),
            onPressed: isLoading ? null : _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...categories.entries.map((entry) {
            return _buildCategoryCard(entry.key, entry.value);
          }).toList(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save Permission Matrix', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category, List<RolePermissionModel> perms) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E9DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFE5ECE2),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Text(
              category,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B241A)),
            ),
          ),
          ...perms.map((p) => _buildPermissionRow(p)).toList(),
        ],
      ),
    );
  }

  Widget _buildPermissionRow(RolePermissionModel p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F4EC))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1B241A))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildToggleChip('View', p.canView, (val) => setState(() => p.canView = val)),
              _buildToggleChip('Create', p.canCreate, (val) => setState(() => p.canCreate = val)),
              _buildToggleChip('Edit', p.canEdit, (val) => setState(() => p.canEdit = val)),
              _buildToggleChip('Approve', p.canApprove, (val) => setState(() => p.canApprove = val)),
              _buildToggleChip('Delete', p.canDelete, (val) => setState(() => p.canDelete = val)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChip(String label, bool isSelected, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.text, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: const Color(0xFFF4F6F2),
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.all(0),
      visualDensity: VisualDensity.compact,
      onSelected: onChanged,
    );
  }
}
