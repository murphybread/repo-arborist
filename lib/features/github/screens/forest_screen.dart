import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:repo_arborist/features/contact/screens/contact_screen.dart';
import 'package:repo_arborist/features/encyclopedia/screens/encyclopedia_grid_screen.dart';
import 'package:repo_arborist/features/github/controllers/forest_controller.dart';
import 'package:repo_arborist/features/github/controllers/github_auth_controller.dart';
import 'package:repo_arborist/features/github/controllers/github_pat_controller.dart';
import 'package:repo_arborist/features/github/models/repository_stats_model.dart';
import 'package:repo_arborist/features/github/screens/github_login_screen.dart';
import 'package:repo_arborist/features/github/screens/repository_detail_screen.dart';
import 'package:repo_arborist/gen/assets.gen.dart';

import 'package:repo_arborist/features/github/widgets/forest_empty_state.dart';
import 'package:repo_arborist/features/github/widgets/repo_count_badge.dart';
import 'package:repo_arborist/features/github/widgets/encyclopedia_button.dart';

import 'package:repo_arborist/features/github/widgets/forest_sort_button.dart';
import 'package:repo_arborist/features/github/models/repository_sort_type_model.dart';

import 'package:repo_arborist/features/github/widgets/forest_error_state.dart';
import 'package:repo_arborist/features/github/widgets/forest_user_info_section.dart';

import 'package:repo_arborist/features/github/widgets/forest_logout_button.dart';
import 'package:repo_arborist/features/github/widgets/forest_garden_button.dart';

import 'package:repo_arborist/features/contact/widgets/contact_button.dart';

import 'package:repo_arborist/features/github/widgets/repository_card.dart';

/// GitHub Repository Forest 화면
class ForestScreen extends ConsumerStatefulWidget {
  /// ForestScreen 생성자
  const ForestScreen({
    this.token,
    this.username,
    super.key,
  });

  /// GitHub Personal Access Token (optional)
  final String? token;

  /// GitHub username (optional)
  final String? username;

  @override
  ConsumerState<ForestScreen> createState() => _ForestScreenState();
}

class _ForestScreenState extends ConsumerState<ForestScreen> {
  RepositorySortType _sortType = RepositorySortType.recentCommits;

  @override
  Widget build(BuildContext context) {
    final forestState = ref.watch(forestProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F1729),
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: SafeArea(
          child: forestState.when(
            data: (repos) {
              final sortedRepos = _sortRepositories(repos);
              return _buildForestView(context, sortedRepos, widget.username);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF14B8A6),
                ),
              ),
            ),
            error: (error, stack) => ForestErrorState(
              error: error,
            ),
          ),
        ),
      ),
    );
  }

  /// Sort repositories based on selected sort type.
  List<RepositoryStatsModel> _sortRepositories(
    List<RepositoryStatsModel> repos,
  ) {
    final sortedRepos = List<RepositoryStatsModel>.from(repos);

    switch (_sortType) {
      case RepositorySortType.recentCommits:
        sortedRepos.sort((a, b) {
          final aDate = a.lastCommitDate;
          final bDate = b.lastCommitDate;

          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;

          return bDate.compareTo(aDate); // Descending (newest first)
        });
      case RepositorySortType.recentPRs:
        sortedRepos.sort((a, b) {
          final aDate = a.lastMergedPRDate;
          final bDate = b.lastMergedPRDate;

          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;

          return bDate.compareTo(aDate); // Descending (newest first)
        });
      case RepositorySortType.activitySize:
        sortedRepos.sort((a, b) {
          return b.projectSizeScore.compareTo(a.projectSizeScore); // Descending
        });
    }

    return sortedRepos;
  }

  Widget _buildForestView(
    BuildContext context,
    List<RepositoryStatsModel> repos,
    String? username,
  ) {
    if (repos.isEmpty) {
      return ForestEmptyState();
    }

    return Column(
      children: [
        // Header - 더 명확한 스타일
        Container(
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
                  child: ForestUserInfoSection(username: username ?? 'Unknown'),
                ),

                const SizedBox(width: 8),
                // Sort button
                ForestSortButton(
                  currentSortType: _sortType,
                  onSortChanged: (value) {
                    setState(() {
                      _sortType = value;
                    });
                  },
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
                RepoCountBadge(count: repos.length),
              ],
            ),
          ),
        ),

        // Contact button below header
        Consumer(
          builder: (context, ref, child) {
            final patState = ref.watch(githubPATProvider);
            final patOwner = patState.username ?? 'unknown';

            return ContactButton(
              patOwner: patOwner,
              repositoryOwner: username ?? 'unknown',
            );
          },
        ),

        // Repository List (Single Column)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 1.0, // More vertical space for plants
                mainAxisSpacing: 20,
              ),
              itemCount: repos.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },

                  child: RepositoryCard(
                    repository: repos[index],
                    token: widget.token,
                  ), // Repository Card 위젯
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
