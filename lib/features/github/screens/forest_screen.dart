import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_arborist/features/contact/widgets/contact_button.dart';
import 'package:repo_arborist/features/github/controllers/forest_controller.dart';
import 'package:repo_arborist/features/github/models/repository_sort_type_model.dart';
import 'package:repo_arborist/features/github/models/repository_stats_model.dart';
import 'package:repo_arborist/features/github/widgets/forest_empty_state.dart';
import 'package:repo_arborist/features/github/widgets/forest_error_state.dart';
import 'package:repo_arborist/features/github/widgets/forest_header.dart';
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
              return _buildForestView(
                context,
                sortedRepos,
                widget.username,
              );
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
        ForestHeader(
          username: username ?? 'Unknown',
          repoCount: repos.length,
          currentSortType: _sortType,
          onSortChanged: (value) {
            setState(() {
              _sortType = value;
            });
          },
        ),
        // Contact button below header
        ContactButton(
          repositoryOwner: username ?? 'unknown',
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
