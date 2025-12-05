import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:repo_arborist/features/github/controllers/forest_controller.dart';
import 'package:repo_arborist/features/github/controllers/github_auth_controller.dart';
import 'package:repo_arborist/features/github/models/repository_stats_model.dart';
import 'package:repo_arborist/features/github/screens/github_login_screen.dart';
import 'package:repo_arborist/features/github/screens/repository_detail_screen.dart';
import 'package:repo_arborist/gen/assets.gen.dart';

/// GitHub Repository Forest 화면
class ForestScreen extends ConsumerWidget {
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
            data: (repos) => _buildForestView(context, repos, username),
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
    String? username,
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
                Flexible(
                  child: Text(
                    username != null ? '$username\'s Forest' : 'Your Forest',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      height: 1.25,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
        child: Stack(
          children: [
            // Background Container
            Positioned.fill(
              // Frame border is ~10% of image (100px out of 1024px)
              // Add margin to prevent frame from covering content
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: bgGradient,
                    borderRadius: BorderRadius.circular(8),
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
                      decoration: repository.treeStage == TreeStage.tree
                          ? BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 0.8,
                                colors: [
                                  Colors.white.withValues(alpha: 0.05),
                                  Colors.transparent,
                                ],
                              ),
                            )
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 17, 12, 13),
                        child: Container(
                          decoration:
                              glowIntensity > 0 &&
                                  repository.treeStage == TreeStage.tree
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

                  // Signpost with Repository Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Signpost Image
                          Image.asset(
                            Assets.images.etc.signpostEmpty.path,
                            fit: BoxFit.contain,
                          ),
                          // Repository Name on Signpost
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              repository.repository.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                height: 1.2,
                                color: const Color(0xFF2C1810),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Repository Stats
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
                        // Stats
                        Text(
                          _getStatsText(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
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
            ),

            // Frame Overlay with 9-slice scaling
            Positioned.fill(
              child: Image.asset(
                Assets.images.etc.uiFrameOakDetailed.path,
                fit: BoxFit.fill,
                // Nine-slice scaling: corners stay fixed, edges and center stretch
                // Image is 1024x1024, assuming ~100px border thickness
                // Adjust these values if frame looks stretched/squished
                centerSlice: const Rect.fromLTRB(
                  100, // left edge of stretchable area
                  100, // top edge of stretchable area
                  924, // right edge of stretchable area (1024 - 100)
                  924, // bottom edge of stretchable area (1024 - 100)
                ),
                filterQuality: FilterQuality.none, // Preserve pixel art quality
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 배경 그라디언트 가져오기 (식물 종류 기반)
  LinearGradient _getBackgroundGradient() {
    final plantType = repository.plantType;
    final primaryColor = plantType.primaryColor;

    // 식물별 배경 그라디언트
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF1E293B),
        Color.lerp(
          const Color(0xFF1E293B),
          primaryColor,
          0.15,
        )!,
      ],
    );
  }

  /// Get plant image path based on language-specific plant type
  String _getTreeImagePath() {
    return repository.plantType.getImagePath(repository.treeStage);
  }

  /// Glow 색상 가져오기 (식물 종류 기반)
  Color _getGlowColor() {
    final plantType = repository.plantType;
    return plantType.primaryColor;
  }

  /// 단계별 크기 배율 가져오기
  double _getSizeMultiplier() {
    final stage = repository.treeStage;
    switch (stage) {
      case TreeStage.sprout:
        return 1.1; // 새싹: 기본보다 약간 작게
      case TreeStage.bloom:
        return 1.3; // 꽃: 기본 크기
      case TreeStage.tree:
        return 1.5; // 나무: 꽃보다 20% 크게
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
