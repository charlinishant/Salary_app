import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../models/shift_model.dart';
import '../providers/shift_provider.dart';
import 'shift_form_screen.dart';
import 'shift_assignment_screen.dart';

class ShiftListScreen extends StatefulWidget {
  const ShiftListScreen({super.key});

  @override
  State<ShiftListScreen> createState() => _ShiftListScreenState();
}

class _ShiftListScreenState extends State<ShiftListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ShiftProvider>().loadShifts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShiftProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5ECE2),
        elevation: 0,
        title: const Text('Shifts', style: TextStyle(color: Color(0xFF1B241A), fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_ind_outlined, color: Color(0xFF1B241A)),
            tooltip: 'Assign Shift',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShiftAssignmentScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1B241A)),
            tooltip: 'Add Shift',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ShiftFormScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: const Color(0xFFE5ECE2),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => provider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search shifts...',
                prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          // List content
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)))
                    : provider.shifts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.access_time, size: 64, color: AppColors.muted),
                                const SizedBox(height: 12),
                                const Text('No shifts found', style: TextStyle(fontSize: 16, color: AppColors.muted)),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ShiftFormScreen()));
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Shift'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.shifts.length,
                            itemBuilder: (context, index) {
                              final shift = provider.shifts[index];
                              return _buildShiftCard(context, shift);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(BuildContext context, ShiftModel shift) {
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
            shift.isOvernight ? Icons.nights_stay_outlined : Icons.wb_sunny_outlined,
            color: AppColors.primary,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                shift.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B241A)),
              ),
            ),
            if (shift.isOvernight)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'OVERNIGHT',
                  style: TextStyle(color: Colors.indigo, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Timing: ${shift.startTime} – ${shift.endTime} • Grace: ${shift.graceMinutes}m',
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text('Off: ${shift.weeklyOff}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 12),
                  const Icon(Icons.people_outline, size: 14, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text('${shift.assignedEmployeesCount} Assigned', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (val) {
            if (val == 'edit') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ShiftFormScreen(shift: shift)));
            } else if (val == 'assign') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ShiftAssignmentScreen(initialShiftId: shift.id)));
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit Shift')])),
            const PopupMenuItem(value: 'assign', child: Row(children: [Icon(Icons.assignment_ind, size: 18, color: AppColors.primary), SizedBox(width: 8), Text('Assign Employees')])),
          ],
        ),
      ),
    );
  }
}
