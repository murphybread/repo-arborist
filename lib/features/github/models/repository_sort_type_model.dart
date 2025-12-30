// repository_sort_type.dart
import 'package:flutter/material.dart';

/// Sort options for repository list
enum RepositorySortType {
  /// Sort by most recent commit date
  recentCommits('Recent Commits', Icons.commit),

  /// Sort by most recent PR merge date
  recentPRs('Recent PRs', Icons.merge),

  /// Sort by total activity size
  activitySize('Activity Size', Icons.trending_up);

  const RepositorySortType(this.label, this.icon);

  final String label;
  final IconData icon;
}
