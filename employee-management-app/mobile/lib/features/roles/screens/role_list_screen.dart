import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/role_model.dart';
import '../providers/role_provider.dart';
import 'permission_matrix_screen.dart';

class RoleListScreen extends StatefulWidget {
  const RoleListScreen({super.key});

  @override
  State<RoleListScreen> createState() => _RoleListScreenState();
}

class _RoleListScreenState extends State<RoleListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<RoleProvider>().loadRoles());
  }

  void _showAddRoleDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Role Name *')),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final success = await context.read<RoleProvider>().createRole(
                    nameCtrl.text.trim(),
                    descCtrl.text.trim(),
                  );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role created')));
              }
            },
            child: const Text('Create Role'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoleProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5ECE2),
        elevation: 0,
        title: const Text('Roles & Permissions', style: TextStyle(color: Color(0xFF1B241A), fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1B241A)),
            onPressed: _showAddRoleDialog,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.roles.length,
                  itemBuilder: (context, index) {
                    final role = provider.roles[index];
                    return _buildRoleCard(context, role);
                  },
                ),
    );
  }

  Widget _buildRoleCard(BuildContext context, RoleModel role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E9DE)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE5ECE2),
          child: Icon(
            role.isSystem ? Icons.verified_user_outlined : Icons.shield_outlined,
            color: AppColors.primary,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                role.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B241A)),
              ),
            ),
            if (role.isSystem)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'SYSTEM',
                  style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (role.description != null && role.description!.isNotEmpty)
                Text(role.description!, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 14, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text('${role.employeeCount} Users Assigned', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  const Icon(Icons.lock_outline, size: 14, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text('${role.permissions.length} Permissions', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF2C382A)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PermissionMatrixScreen(role: role),
            ),
          );
        },
      ),
    );
  }
}
