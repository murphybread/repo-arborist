import 'package:flutter/material.dart';
import 'package:repo_arborist/features/github/models/repository_sort_type_model.dart';
import 'package:repo_arborist/features/github/widgets/forest_user_info_section.dart';
import 'package:repo_arborist/features/github/widgets/forest_sort_button.dart';
import 'package:repo_arborist/features/github/widgets/encyclopedia_button.dart';
import 'package:repo_arborist/features/github/widgets/forest_logout_button.dart';
import 'package:repo_arborist/features/github/widgets/forest_garden_button.dart';
import 'package:repo_arborist/features/github/widgets/repo_count_badge.dart';

class ForestHeader extends StatelessWidget {
  const ForestHeader({
    // ← const 추가
    required this.username,
    required this.repoCount,
    required this.currentSortType,
    required this.onSortChanged,
    super.key, // ← 필수
  });

  final String username;
  final int repoCount;
  final RepositorySortType currentSortType;
  final Function(RepositorySortType) onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF14B8A6),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: ForestUserInfoSection(username: username),
            ),

            const SizedBox(width: 8),
            // Sort button
            ForestSortButton(
              currentSortType: currentSortType,
              onSortChanged: onSortChanged,
            ),
            const SizedBox(width: 8),
            // Encyclopedia button
            EncyclopediaButton(),

            const SizedBox(width: 8),
            // Logout 버튼
            ForestLogoutButton(),
            const SizedBox(width: 8),
            // Go to Garden 버튼
            ForestGardenButton(),

            const SizedBox(width: 8),
            RepoCountBadge(count: repoCount),
          ],
        ),
      ),
    );
  }
}
