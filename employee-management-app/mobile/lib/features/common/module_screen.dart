import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/models/app_state.dart';
import '../../shared/models/resource_item.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_error.dart';
import '../../shared/widgets/app_loader.dart';
import '../../shared/widgets/empty_state.dart';
import 'resource_provider.dart';

class ModuleScreen<T extends ResourceProvider> extends StatefulWidget {
  const ModuleScreen({super.key, required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  State<ModuleScreen<T>> createState() => _ModuleScreenState<T>();
}

class _ModuleScreenState<T extends ResourceProvider> extends State<ModuleScreen<T>> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<T>().load());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<T>();
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: widget.action == null ? null : [widget.action!]),
      body: RefreshIndicator(
        onRefresh: provider.load,
        child: Builder(builder: (context) {
          final state = provider.state;
          if (state.status == LoadStatus.loading) return const AppLoader();
          if (state.status == LoadStatus.error) return AppError(message: state.message, onRetry: provider.load);
          if (state.status == LoadStatus.empty) return const EmptyState();
          final rows = state.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = ResourceItem(rows[index]);
              return AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: item.subtitle.isEmpty ? null : Text(item.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: rows.length,
          );
        }),
      ),
    );
  }
}
