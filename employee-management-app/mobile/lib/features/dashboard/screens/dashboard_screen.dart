import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/date_utils.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loader.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<DashboardProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final employee = context.watch<AuthProvider>().state.data;
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(AppConfig.logoAsset, height: 42, fit: BoxFit.contain),
        actions: [IconButton(onPressed: () => context.read<AuthProvider>().logout(), icon: const Icon(Icons.logout))],
      ),
      body: RefreshIndicator(
        onRefresh: dashboard.load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(employee?.name ?? 'Employee', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text('${employee?.employeeCode ?? ''} • ${AppDateUtils.today()}'),
              ]),
            ),
            const SizedBox(height: 12),
            if (dashboard.state.status == LoadStatus.loading) const SizedBox(height: 160, child: AppLoader()),
            if (dashboard.state.status == LoadStatus.error) SizedBox(height: 160, child: AppError(message: dashboard.state.message, onRetry: dashboard.load)),
            if (dashboard.state.status == LoadStatus.success) _SummaryGrid(data: dashboard.state.data ?? {}),
            const SizedBox(height: 12),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: .95,
              children: AppRoutes.modules.map((module) => AppCard(
                    onTap: () => Navigator.pushNamed(context, module.route),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(module.icon),
                      const SizedBox(height: 8),
                      Text(module.label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ]),
                  )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final attendance = data['attendance'] as Map<String, dynamic>?;
    final items = {
      'Punch In': attendance?['punchInTime'] ?? '--',
      'Punch Out': attendance?['punchOutTime'] ?? '--',
      'Leaves': data['remainingLeave'] ?? 0,
      'Pending': data['pendingRequests'] ?? 0,
    };
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2.4,
      children: items.entries.map((e) => AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(e.key, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Text(e.value.toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]))).toList(),
    );
  }
}
