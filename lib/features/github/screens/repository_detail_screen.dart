import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:repo_arborist/features/github/models/commit_model.dart';
import 'package:repo_arborist/features/github/models/pull_request_model.dart';
import 'package:repo_arborist/features/github/models/repository_stats_model.dart';
import 'package:repo_arborist/features/github/repositories/github_repository.dart';

/// Repository detail view screen.
class RepositoryDetailScreen extends StatefulWidget {
  /// Creates a repository detail screen.
  const RepositoryDetailScreen({
    required this.repository,
    this.token,
    super.key,
  });

  /// Selected repository stats.
  final RepositoryStatsModel repository;

  /// GitHub Personal Access Token (optional for public access).
  final String? token;

  @override
  State<RepositoryDetailScreen> createState() => _RepositoryDetailScreenState();
}

class _RepositoryDetailScreenState extends State<RepositoryDetailScreen> {
  List<CommitModel>? _recentCommits;
  List<PullRequestModel>? _recentPRs;
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentActivity();
  }

  Future<void> _loadRecentActivity() async {
    try {
      final parts = widget.repository.repository.fullName.split('/');
      if (parts.length != 2) {
        setState(() => _isLoading = false);
        return;
      }

      final owner = parts[0];
      final repo = parts[1];
      final githubRepo = GitHubRepository();

      final results = await Future.wait<List>([
        githubRepo.getRecentCommits(
          token: widget.token,
          owner: owner,
          repo: repo,
        ),
        githubRepo.getRecentMergedPRs(
          token: widget.token,
          owner: owner,
          repo: repo,
        ),
      ]);

      if (mounted) {
        setState(() {
          _recentCommits = results[0] as List<CommitModel>;
          _recentPRs = results[1] as List<PullRequestModel>;
          _isLoading = false;
        });
      }
    } on Exception {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.repository.treeStage;
    final variantIndex = widget.repository.variantIndex;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 헤더 - 레포지토리 이름
              Container(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 8),
                child: Row(
                  children: [
                    // 뒤로 가기 버튼
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    // 레포지토리 이름
                    Expanded(
                      child: Text(
                        widget.repository.repository.name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          height: 1.25,
                          letterSpacing: -0.015,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 트리 이미지
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Center(
                  child: Transform.scale(
                    scale:
                        widget.repository.activityTier.scaleMultiplier *
                        _getSizeMultiplier(stage),
                    child: Container(
                      height: 240,
                      decoration:
                          widget.repository.activityTier.glowIntensity > 0
                          ? BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: _getGlowColor().withValues(
                                    alpha:
                                        widget
                                            .repository
                                            .activityTier
                                            .glowIntensity *
                                        0.6,
                                  ),
                                  blurRadius:
                                      40 *
                                      widget
                                          .repository
                                          .activityTier
                                          .glowIntensity,
                                  spreadRadius:
                                      10 *
                                      widget
                                          .repository
                                          .activityTier
                                          .glowIntensity,
                                ),
                              ],
                            )
                          : null,
                      child: Opacity(
                        opacity:
                            0.3 +
                            (widget
                                    .repository
                                    .activityTier
                                    .saturationMultiplier *
                                0.7),
                        child: Image.asset(
                          _getTreeImagePath(stage, variantIndex),
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 통계 카드들
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    // Total commits 카드
                    _StatCard(
                      label: 'Total\ncommits',
                      value: widget.repository.totalCommits.toString(),
                    ),

                    // Merged PRs 카드
                    _StatCard(
                      label: 'Merged\nPRs',
                      value: widget.repository.totalMergedPRs.toString(),
                    ),

                    // Project score 카드
                    _StatCard(
                      label: 'Project\nscore',
                      value: widget.repository.projectSizeScore.toString(),
                      formula: 'commits +\nmerged\nPRs × 5',
                    ),
                  ],
                ),
              ),

              // Recent Activity Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        height: 1.25,
                        letterSpacing: -0.025,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 로딩 중
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                            color: Color(0xFF14B8A6),
                          ),
                        ),
                      )
                    else ...[
                      // 최근 커밋
                      if (_recentCommits != null &&
                          _recentCommits!.isNotEmpty) ...[
                        _SectionHeader(
                          icon: Icons.commit,
                          title: 'Recent Commits',
                          count: _recentCommits!.length,
                        ),
                        const SizedBox(height: 12),
                        ..._recentCommits!.map(
                          (commit) => _CommitItem(commit: commit),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 최근 PR
                      if (_recentPRs != null && _recentPRs!.isNotEmpty) ...[
                        _SectionHeader(
                          icon: Icons.merge,
                          title: 'Recent Merged PRs',
                          count: _recentPRs!.length,
                        ),
                        const SizedBox(height: 12),
                        ..._recentPRs!.map((pr) => _PRItem(pr: pr)),
                      ],

                      // 데이터가 없는 경우
                      if ((_recentCommits == null || _recentCommits!.isEmpty) &&
                          (_recentPRs == null || _recentPRs!.isEmpty))
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'No recent activity found',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              // 하단 여백
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Get tree image path based on language-specific plant type
  String _getTreeImagePath(TreeStage stage, int variantIndex) {
    return widget.repository.plantType.getImagePath(stage);
  }

  /// Glow 색상 가져오기 (식물 종류 기반)
  Color _getGlowColor() {
    return widget.repository.plantType.primaryColor;
  }

  /// 단계별 크기 배율 가져오기
  double _getSizeMultiplier(TreeStage stage) {
    switch (stage) {
      case TreeStage.sprout:
        return 0.9; // 새싹: 기본보다 약간 작게
      case TreeStage.bloom:
        return 1; // 꽃: 기본 크기
      case TreeStage.tree:
        return 1.2; // 나무: 꽃보다 20% 크게
    }
  }
}

/// 통계 카드 위젯
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.formula,
  });

  final String label;
  final String value;
  final String? formula;

  @override
  Widget build(BuildContext context) {
    // 카드 너비 계산 (3개가 한 줄에 들어가도록)
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32 - 32) / 3; // padding 16*2 + gap 16*2

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 10),
            blurRadius: 15,
            spreadRadius: -3,
          ),
        ],
      ),
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),

          // Value
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              height: 1.25,
              letterSpacing: -0.025,
              color: Color(0xFFFFFFFF),
            ),
          ),

          // Formula (optional)
          if (formula != null) ...[
            const SizedBox(height: 8),
            Text(
              formula!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                height: 1.333,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 섹션 헤더 위젯
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  final IconData icon;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF14B8A6), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFFFFFFFF),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Color(0xFF14B8A6),
            ),
          ),
        ),
      ],
    );
  }
}

/// 커밋 아이템 위젯
class _CommitItem extends StatelessWidget {
  const _CommitItem({required this.commit});

  final CommitModel commit;

  @override
  Widget build(BuildContext context) {
    // 커밋 메시지 첫 줄만 가져오기
    final firstLine = commit.message.split('\n').first;
    final shortMessage = firstLine.length > 60
        ? '${firstLine.substring(0, 60)}...'
        : firstLine;

    // 날짜 포맷
    final now = DateTime.now();
    final difference = now.difference(commit.date);
    String timeAgo;
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes}m ago';
    } else {
      timeAgo = 'Just now';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 커밋 메시지
          Text(
            shortMessage,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFFFFFFFF),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // 작성자와 날짜
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Text(
                commit.author,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// PR 아이템 위젯
class _PRItem extends StatelessWidget {
  const _PRItem({required this.pr});

  final PullRequestModel pr;

  @override
  Widget build(BuildContext context) {
    // 제목 줄이기
    final shortTitle = pr.title.length > 60
        ? '${pr.title.substring(0, 60)}...'
        : pr.title;

    // 날짜 포맷
    final mergedDate = pr.mergedAt;
    String timeAgo = 'Unknown';
    if (mergedDate != null) {
      final now = DateTime.now();
      final difference = now.difference(mergedDate);
      if (difference.inDays > 0) {
        timeAgo = '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        timeAgo = '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        timeAgo = '${difference.inMinutes}m ago';
      } else {
        timeAgo = 'Just now';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x1AFFFFFF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PR 제목
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#${pr.number}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  shortTitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFFFFFFFF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 작성자와 날짜
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Text(
                pr.author,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.merge, size: 14, color: Color(0xFF10B981)),
              const SizedBox(width: 4),
              Text(
                'Merged $timeAgo',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
