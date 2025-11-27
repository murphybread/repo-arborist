import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:template/features/github/controllers/forest_controller.dart';
import 'package:template/features/github/controllers/github_auth_controller.dart';
import 'package:template/features/github/models/repository_stats_model.dart';
import 'package:template/features/github/screens/github_login_screen.dart';
import 'package:template/features/github/screens/repository_detail_screen.dart';
import 'package:template/gen/assets.gen.dart';

/// GitHub Repository Forest 화면
class ForestScreen extends ConsumerWidget {
  /// ForestScreen 생성자
  const ForestScreen({
    this.token,
    super.key,
  });

  /// GitHub Personal Access Token (optional)
  final String? token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            data: (repos) => _buildForestView(context, repos),
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF14B8A6),
                ),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading repositories',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForestView(
    BuildContext context,
    List<RepositoryStatsModel> repos,
  ) {
    if (repos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.forest_outlined,
                size: 64,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 24),
              Text(
                'No repositories found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create some repositories to grow your forest!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
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
                Icon(
                  Icons.park_outlined,
                  color: const Color(0xFF14B8A6),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Forest',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    height: 1.25,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                // Logout 버튼
                Consumer(
                  builder: (context, ref, child) {
                    return GestureDetector(
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            backgroundColor: const Color(0xFF1E293B),
                            title: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Are you sure you want to logout?',
                              style: TextStyle(color: Color(0xFF94A3B8)),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Color(0xFF94A3B8)),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: Color(0xFFF43F5E)),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          // 로그아웃 실행
                          ref.read(githubAuthProvider.notifier).signOut();
                          // 로그인 화면으로 이동 (모든 스택 제거)
                          await Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const GithubLoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0x20F43F5E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0x50F43F5E),
                          ),
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: Color(0xFFF43F5E),
                          size: 16,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                // Go to Garden 버튼
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.grid_view_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Go to Garden',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x2014B8A6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0x5014B8A6),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${repos.length} repos',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: const Color(0xFF14B8A6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Repository Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
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
                  child: _RepositoryCard(
                    repository: repos[index],
                    token: token,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Repository Card 위젯
class _RepositoryCard extends StatelessWidget {
  const _RepositoryCard({
    required this.repository,
    this.token,
  });

  final RepositoryStatsModel repository;
  final String? token;

  @override
  Widget build(BuildContext context) {
    final treeImagePath = _getTreeImagePath();
    final glowColor = _getGlowColor();
    final bgGradient = _getBackgroundGradient();

    // ActivityTier 기반 효과
    final activityTier = repository.activityTier;
    final scale = activityTier.scaleMultiplier;
    final glowIntensity = activityTier.glowIntensity;
    final opacity = 0.3 + (activityTier.saturationMultiplier * 0.7);
    final borderColor = _getBorderColor();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RepositoryDetailScreen(
              repository: repository,
              token: token,
            ),
          ),
        );
      },
      child: Transform.scale(
        scale: scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: bgGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tree Image with better background
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Colors.white.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 34, 24, 26),
                    child: Container(
                      decoration: glowIntensity > 0
                          ? BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: glowColor.withValues(
                                    alpha: glowIntensity * 0.8,
                                  ),
                                  blurRadius: 50 * glowIntensity,
                                  spreadRadius: 10 * glowIntensity,
                                ),
                              ],
                            )
                          : null,
                      child: Transform.scale(
                        scale: _getSizeMultiplier(),
                        child: Opacity(
                          opacity: opacity,
                          child: treeImagePath.endsWith('.png')
                              ? Image.asset(
                                  treeImagePath,
                                  fit: BoxFit.contain,
                                )
                              : SvgPicture.asset(
                                  treeImagePath,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Repository Info with clearer background
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Repository Name
                    Text(
                      repository.repository.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.25,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Stats
                    Text(
                      _getStatsText(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        height: 1.4,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 배경 그라디언트 가져오기
  LinearGradient _getBackgroundGradient() {
    final stage = repository.treeStage;

    switch (stage) {
      case TreeStage.sprout:
        // 새싹 - 연한 회색/청록색
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF334155),
          ],
        );
      case TreeStage.bloom:
        // 꽃 - 색상별 미묘한 배경
        final index = repository.variantIndex;
        switch (index) {
          case 0: // Yellow
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E293B),
                const Color(0xFF3D2C1F),
              ],
            );
          case 1: // Blue
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E293B),
                const Color(0xFF1E3A5F),
              ],
            );
          case 2: // Orange
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E293B),
                const Color(0xFF3D2A1F),
              ],
            );
          case 3: // Pink
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E293B),
                const Color(0xFF3D1F2E),
              ],
            );
          default:
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E293B),
                const Color(0xFF334155),
              ],
            );
        }
      case TreeStage.tree:
        // 나무 - 더 강한 색상
        final index = repository.variantIndex;
        if (index == 0) {
          // Green tree
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E293B),
              const Color(0xFF1F3D2E),
            ],
          );
        } else {
          // Red tree
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E293B),
              const Color(0xFF3D1F2A),
            ],
          );
        }
    }
  }

  /// 나무 이미지 경로 가져오기
  String _getTreeImagePath() {
    final stage = repository.treeStage;
    final index = repository.variantIndex;
    final isCactus = repository.isCactusMode;

    // 선인장 모드 (1년 이상 방치)
    if (isCactus) {
      switch (stage) {
        case TreeStage.sprout:
          return Assets.images.trees.cactusSprout.path;
        case TreeStage.bloom:
          return Assets.images.trees.cactusBloom.path;
        case TreeStage.tree:
          return Assets.images.trees.cactusTree.path;
      }
    }

    // 일반 나무
    switch (stage) {
      case TreeStage.sprout:
        return Assets.images.trees.sproutDot.path;
      case TreeStage.bloom:
        final bloomAssets = [
          Assets.images.trees.bloomOrangeDot.path,
          Assets.images.trees.bloomPurpleDot.path,
        ];
        return bloomAssets[index % bloomAssets.length];
      case TreeStage.tree:
        // 모든 tree 단계는 maple.png 사용
        return Assets.images.trees.maple.path;
    }
  }

  /// 테두리 색상 가져오기
  Color _getBorderColor() {
    final stage = repository.treeStage;

    switch (stage) {
      case TreeStage.sprout:
        return const Color(0xFF64748B); // 회색
      case TreeStage.bloom:
        final index = repository.variantIndex;
        switch (index) {
          case 0:
            return const Color(0xFFFDE047); // Yellow
          case 1:
            return const Color(0xFF60A5FA); // Blue
          case 2:
            return const Color(0xFFFB923C); // Orange
          case 3:
            return const Color(0xFFF472B6); // Pink
          default:
            return const Color(0xFF64748B);
        }
      case TreeStage.tree:
        final index = repository.variantIndex;
        if (index == 0) {
          return const Color(0xFF22C55E); // Green
        } else {
          return const Color(0xFFF43F5E); // Red
        }
    }
  }

  /// Glow 색상 가져오기
  Color _getGlowColor() {
    final stage = repository.treeStage;
    final isCactus = repository.isCactusMode;

    // 선인장이면 선인장 색상
    if (isCactus) {
      return const Color(0xFF86A17A); // 선인장 색상
    }

    switch (stage) {
      case TreeStage.sprout:
        return const Color(0xFF34D399); // 초록색 글로우
      case TreeStage.bloom:
        final index = repository.variantIndex;
        switch (index) {
          case 0:
            return const Color(0xFFFDE047); // Yellow
          case 1:
            return const Color(0xFF60A5FA); // Blue
          case 2:
            return const Color(0xFFFB923C); // Orange
          case 3:
            return const Color(0xFFF472B6); // Pink
          default:
            return const Color(0xFF34D399); // 기본 초록
        }
      case TreeStage.tree:
        final index = repository.variantIndex;
        if (index == 0) {
          return const Color(0xFF22C55E); // Green
        } else {
          return const Color(0xFFF43F5E); // Red
        }
    }
  }

  /// 단계별 크기 배율 가져오기
  double _getSizeMultiplier() {
    final stage = repository.treeStage;
    switch (stage) {
      case TreeStage.sprout:
        return 0.9; // 새싹: 기본보다 약간 작게
      case TreeStage.bloom:
        return 1; // 꽃: 기본 크기
      case TreeStage.tree:
        return 1.2; // 나무: 꽃보다 20% 크게
    }
  }

  /// 통계 텍스트 가져오기
  String _getStatsText() {
    final commits = repository.totalCommits;
    final prs = repository.totalMergedPRs;
    final score = repository.projectSizeScore;

    if (commits == 0 && prs == 0) {
      return 'New repository\nScore: $score';
    }

    final parts = <String>[];
    if (commits > 0) {
      parts.add('$commits commits');
    }
    if (prs > 0) {
      parts.add('$prs PRs');
    }

    return '${parts.join(' • ')}\nScore: $score';
  }
}
