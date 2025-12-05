import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_arborist/features/github/controllers/forest_controller.dart';
import 'package:repo_arborist/features/github/models/repository_stats_model.dart';
import 'package:repo_arborist/features/github/screens/forest_screen.dart';
import 'package:repo_arborist/gen/assets.gen.dart';

/// 정원 오버뷰 화면 - 모든 레포지토리를 자연스럽게 배치
class GardenOverviewScreen extends ConsumerWidget {
  /// GardenOverviewScreen 생성자
  const GardenOverviewScreen({
    this.token,
    this.username,
    super.key,
  });

  /// GitHub Personal Access Token (null인 경우 username 사용)
  final String? token;

  /// GitHub username (token이 null일 때 사용)
  final String? username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('🟢 [GardenOverview] build 호출됨');
    final reposAsync = ref.watch(forestProvider);

    return reposAsync.when(
      data: (repos) {
        debugPrint('🟢 [GardenOverview] build - 데이터 수신: ${repos.length}개');

        // created_at 기준으로 정렬 (오래된 것부터)
        final sortedRepos = List<RepositoryStatsModel>.from(repos)
          ..sort(
            (a, b) => a.repository.createdAt.compareTo(b.repository.createdAt),
          );

        return _GardenView(
          repositories: sortedRepos,
          token: token,
          username: username,
        );
      },
      loading: () {
        debugPrint('🟢 [GardenOverview] loading 상태');
        return const Scaffold(
          backgroundColor: Color(0xFFF8FAFC),
          body: Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, stack) {
        debugPrint('🔴 [GardenOverview] Error 발생: $error');
        debugPrint('Stack trace: $stack');
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Failed to Load Garden',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error: $error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B8A6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 정원 뷰 위젯
class _GardenView extends StatelessWidget {
  const _GardenView({
    required this.repositories,
    this.token,
    this.username,
  });

  final List<RepositoryStatsModel> repositories;
  final String? token;
  final String? username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF74C043),
      body: Stack(
        children: [
          // [Layer 1] 하늘 배경 (구름 패턴 - 고정)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.images.etc.bgCloudSky.path),
                  repeat: ImageRepeat.repeat, // 작은 구름 패턴 반복
                ),
              ),
            ),
          ),

          // [Layer 2] 땅 배경 (하늘 위에 얹기 - 고정)
          Positioned(
            top: 120, // 하늘이 보이도록 120px 내림
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Assets.images.etc.squareGroudtileDot.path),
                  repeat: ImageRepeat.repeat, // 바둑판식 반복
                  scale: 4.0, // 촘촘하게
                ),
              ),
            ),
          ),

          // [Layer 3] 스크롤 콘텐츠 (울타리 + 식물)
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 상단 하늘 영역만큼 여백 확보 (Layer 2의 top 값과 일치)
                    const SizedBox(height: 120),

                    // 상단 울타리 (Header) - 크기 확대
                    Container(
                      width: double.infinity,
                      height: 120, // 높이 확대 (120px)
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            Assets.images.etc.gardenBorderHedge.path,
                          ),
                          repeat: ImageRepeat.repeatX, // 가로 반복
                          fit: BoxFit.cover, // 빈틈없이 채우기
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),

                    // 식물 리스트 (Wrap 사용, 여백 제거)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.zero, // 패딩 제거
                      alignment: Alignment.center,
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: List.generate(repositories.length, (index) {
                          final repo = repositories[index];
                          final createdAt = repo.repository.createdAt;
                          final now = DateTime.now();
                          final ageInYears =
                              now.difference(createdAt).inDays / 365.0;

                          return _GardenTree(
                            repository: repo,
                            size: 64.0,
                            index: index,
                            ageInYears: ageInYears,
                            totalRepos: repositories.length,
                          );
                        }),
                      ),
                    ),

                    // 하단 울타리 (Footer) - 상단과 동일하게 설정
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            Assets.images.etc.gardenBorderHedge.path,
                          ),
                          repeat: ImageRepeat.repeatX,
                          fit: BoxFit.cover, // 빈틈없이 채우기
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            offset: const Offset(0, -4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),

                    // 하단 여백
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // UI 오버레이 (고정 헤더)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Column(
                  children: [
                    Text(
                      username != null
                          ? '$username\'s Forest — Overview'
                          : 'Your Forest — Overview',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Color(0xFF0F172A),
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.white54,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${repositories.length} repositories visualized',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 상단 우측 버튼 (Details)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ForestScreen(
                      token: token,
                      username: username,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Details',
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
          ),
        ],
      ),
    );
  }
}

/// 정원 속 나무 위젯 (애니메이션 포함)
class _GardenTree extends StatefulWidget {
  const _GardenTree({
    required this.repository,
    required this.size,
    required this.index,
    required this.ageInYears,
    required this.totalRepos,
  });

  final RepositoryStatsModel repository;
  final double size;
  final int index;
  final double ageInYears;
  final int totalRepos;

  @override
  State<_GardenTree> createState() => _GardenTreeState();
}

class _GardenTreeState extends State<_GardenTree>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _swayAnimation;

  @override
  void initState() {
    super.initState();

    // 각 나무마다 다른 타이밍으로 흔들림
    final duration = 2000 + (widget.index * 137) % 1000; // 2-3초 사이
    _controller = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    )..repeat(reverse: true);

    // 각 나무마다 다른 각도로 흔들림
    final maxAngle = 0.02 + (widget.index % 3) * 0.005; // 0.02 - 0.03 라디안
    _swayAnimation =
        Tween<double>(
          begin: -maxAngle,
          end: maxAngle,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.repository;
    final stage = repo.treeStage;
    final variantIndex = repo.variantIndex;
    final isCactus = repo.isCactusMode;
    final activityTier = repo.activityTier;
    final imagePath = _getTreeImagePath(stage, variantIndex, isCactus);

    // ActivityTier 기반 스케일
    final scale = activityTier.scaleMultiplier;
    final glowIntensity = activityTier.glowIntensity;

    // 나이 기반 색상 조정
    final ageInYears = widget.ageInYears;
    final ageFactor = 1.0 - (ageInYears / 10).clamp(0.0, 0.5);

    final treeOpacity = 1.0;

    return AnimatedBuilder(
      animation: _swayAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: _swayAnimation.value,
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Shadow image only for tree level
          if (stage == TreeStage.tree)
            Positioned(
              bottom: widget.size * 0.05,
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  Assets.images.etc.plantShadow.path,
                  width: widget.size * 1.2,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          if (stage == TreeStage.bloom)
            Positioned(
              bottom: widget.size * 0.4,
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  Assets.images.etc.plantShadow.path,
                  width: widget.size * 0.7,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // Shadow image only for sprout level
          if (stage == TreeStage.sprout)
            Positioned(
              bottom: widget.size * 0.32,
              child: Opacity(
                opacity: 0.95,
                child: Image.asset(
                  Assets.images.etc.sproutShadow.path,
                  width: widget.size * 0.85,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // 나무와 라벨
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 나무 이미지 + 이펙트
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // 나무 본체
                  Transform.scale(
                    scale: _getSizeMultiplier(stage),
                    child: Container(
                      width: widget.size,
                      height: widget.size * 1.2,
                      decoration: glowIntensity > 0
                          ? BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: _getGlowColor(
                                    stage,
                                    isCactus,
                                  ).withValues(alpha: glowIntensity * 0.6),
                                  blurRadius: 20 * glowIntensity,
                                  spreadRadius: 5 * glowIntensity,
                                ),
                              ],
                            )
                          : null,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(
                          _getAgeColorMatrix(ageFactor),
                        ),
                        child: Opacity(
                          opacity: treeOpacity,
                          child: Image.asset(
                            imagePath,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 반짝이는 이펙트 (Warm)
                  if (activityTier == ActivityTier.warm)
                    Positioned(
                      top: -widget.size * 0.1,
                      right: -widget.size * 0.1,
                      child: Image.asset(
                        Assets.images.etc.sparklingEffectSpriteDot.path,
                        width: widget.size * 0.4,
                        height: widget.size * 0.4,
                        fit: BoxFit.contain,
                      ),
                    ),

                  // 싱그러운 이펙트 (Fresh)
                  if (activityTier == ActivityTier.fresh)
                    Positioned(
                      top: -widget.size * 0.2,
                      right: -widget.size * 0.2,
                      child: Image.asset(
                        Assets.images.etc.freshEffectSpriteDot.path,
                        width: widget.size * 0.5,
                        height: widget.size * 0.5,
                        fit: BoxFit.contain,
                      ),
                    ),

                  // 방치된 이펙트 (Dormant) - 일시 비활성화
                  // if (activityTier == ActivityTier.dormant) ...
                ],
              ),

              // 이름표 (그림자 + 텍스트)
              Container(
                width: widget.size * 1.2,
                height: widget.size * 0.25,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  repo.repository.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get tree image path based on language-specific plant type
  String _getTreeImagePath(TreeStage stage, int variantIndex, bool isCactus) {
    return widget.repository.plantType.getImagePath(stage);
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

  /// 글로우 색상 가져오기 (식물 종류 기반)
  Color _getGlowColor(TreeStage stage, bool isCactus) {
    return widget.repository.plantType.primaryColor;
  }

  /// 나이 기반 색상 매트릭스 (세피아/탈색 효과)
  /// [ageFactor] 1.0 = 새로운, 0.5 = 오래된
  List<double> _getAgeColorMatrix(double ageFactor) {
    // 세피아 톤으로 변환 (오래될수록 강하게)
    final sepiaStrength = 1.0 - ageFactor; // 0 = 없음, 0.5 = 강함

    return [
      // R  G  B  A  Const
      0.393 + 0.607 * (1 - sepiaStrength),
      0.769 - 0.769 * (1 - sepiaStrength),
      0.189 - 0.189 * (1 - sepiaStrength),
      0,
      0, // R
      0.349 - 0.349 * (1 - sepiaStrength),
      0.686 + 0.314 * (1 - sepiaStrength),
      0.168 - 0.168 * (1 - sepiaStrength),
      0,
      0, // G
      0.272 - 0.272 * (1 - sepiaStrength),
      0.534 - 0.534 * (1 - sepiaStrength),
      0.131 + 0.869 * (1 - sepiaStrength),
      0,
      0, // B
      0, 0, 0, 1, 0, // A
    ];
  }
}
