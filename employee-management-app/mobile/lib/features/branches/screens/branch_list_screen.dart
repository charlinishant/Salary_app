import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/branch_model.dart';
import '../providers/branch_provider.dart';
import 'branch_form_screen.dart';

class BranchListScreen extends StatefulWidget {
  const BranchListScreen({super.key});

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<BranchProvider>().loadBranches());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BranchProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5ECE2),
        elevation: 0,
        title: const Text('Branches', style: TextStyle(color: Color(0xFF1B241A), fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1B241A)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BranchFormScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar & Filter Chips
          Container(
            color: const Color(0xFFE5ECE2),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search branches...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Active', 'Inactive'].map((filter) {
                      final isSelected = provider.selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.text, fontWeight: FontWeight.w600),
                          backgroundColor: Colors.white,
                          onSelected: (_) => provider.setFilter(filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // List content
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)))
                    : provider.branches.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.domain_disabled_outlined, size: 64, color: AppColors.muted),
                                const SizedBox(height: 12),
                                const Text('No branches found', style: TextStyle(fontSize: 16, color: AppColors.muted)),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const BranchFormScreen()));
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Branch'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.branches.length,
                            itemBuilder: (context, index) {
                              final branch = provider.branches[index];
                              return _buildBranchCard(context, branch);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchCard(BuildContext context, BranchModel branch) {
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
          child: Icon(Icons.domain_outlined, color: branch.isActive ? AppColors.primary : Colors.grey),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                branch.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B241A)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: branch.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                branch.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: branch.isActive ? Colors.green[800] : Colors.red[800],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Code: ${branch.code} • City: ${branch.city ?? 'N/A'}', style: const TextStyle(fontSize: 13, color: AppColors.muted)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 14, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text('${branch.employeeCount} Employees', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text('Geofence ${branch.geofenceRadius.toInt()}m', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) async {
            if (val == 'edit') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => BranchFormScreen(branch: branch)));
            } else if (val == 'delete') {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Branch'),
                  content: Text('Are you sure you want to delete ${branch.name}?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                  ],
                ),
              );

              if (ok == true && mounted) {
                final success = await context.read<BranchProvider>().deleteBranch(branch.id);
                if (!success && mounted) {
                  final err = context.read<BranchProvider>().error;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'Failed to delete branch')));
                }
              }
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ),
    );
  }
}
