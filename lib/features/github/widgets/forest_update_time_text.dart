import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_arborist/features/github/controllers/forest_controller.dart';

/// Displays the last update time from forest controller.
class ForestUpdateTimeText extends ConsumerWidget {
  const ForestUpdateTimeText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastUpdate = ref.read(forestProvider.notifier).lastUpdateTime;
    if (lastUpdate == null) return const SizedBox.shrink();

    return Text(
      'Updated ${_getTimeAgo(lastUpdate)}',
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w400,
        fontSize: 11,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}

/// Get human-readable time difference.
String _getTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
  } else if (difference.inDays < 30) {
    final days = difference.inDays;
    return '$days ${days == 1 ? 'day' : 'days'} ago';
  } else {
    final months = (difference.inDays / 30).floor();
    return '$months ${months == 1 ? 'month' : 'months'} ago';
  }
}
