import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_arborist/features/github/controllers/forest_controller.dart';
import 'package:repo_arborist/shared/utils/time_utils.dart';

/// Displays the last update time from forest controller.
class ForestUpdateTimeText extends ConsumerWidget {
  const ForestUpdateTimeText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastUpdate = ref.read(forestProvider.notifier).lastUpdateTime;
    if (lastUpdate == null) return const SizedBox.shrink();

    return Text(
      'Updated ${getTimeAgo(lastUpdate)}',
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        fontSize: 11,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}
