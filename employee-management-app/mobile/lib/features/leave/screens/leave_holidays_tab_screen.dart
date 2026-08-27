import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../holidays/screens/holidays_screen.dart';
import '../providers/leave_policy_provider.dart';
import '../providers/leave_provider.dart';
import 'leave_screen.dart';
import 'leave_types_screen.dart';
import 'leave_policies_screen.dart';

class LeaveHolidaysTabScreen extends StatefulWidget {
  const LeaveHolidaysTabScreen({super.key});

  @override
  State<LeaveHolidaysTabScreen> createState() => _LeaveHolidaysTabScreenState();
}

class _LeaveHolidaysTabScreenState extends State<LeaveHolidaysTabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() {
      if (mounted) {
        context.read<LeavePolicyProvider>().loadData();
        context.read<LeaveProvider>().load();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5ECE2),
        elevation: 0,
        title: const Text('Leave & Holidays', style: TextStyle(color: Color(0xFF1B241A), fontSize: 20, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.muted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Leave Requests'),
            Tab(text: 'Leave Types'),
            Tab(text: 'Leave Policies'),
            Tab(text: 'Holiday List'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LeaveScreen(),
          LeaveTypesScreen(),
          LeavePoliciesScreen(),
          HolidaysScreen(),
        ],
      ),
    );
  }
}
