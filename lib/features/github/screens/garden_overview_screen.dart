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
          backgroundColor: Color(0xFFF8FAFC),
          body: Center(child: Text('Error: $error')),
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
      backgroundColor: const Color(0xFF1E293B),
      body: Stack(
        children: [
          // 배경 그라디언트
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F172A), // 진한 남색
                  Color(0xFF1E293B), // 중간 남색
                ],
              ),
            ),
          ),

          // 메인 컨텐츠
          SafeArea(
            child: Column(
              children: [
                // 헤더 (간결하게)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 6), // 15,12 → 8,6
                  child: Column(
                    children: [
                      const Text(
                        'Your Forest — Overview',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 14, // 15 → 14
                          height: 1.4,
                          letterSpacing: -0.03,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2), // 4 → 2
                      Text(
                        '${repositories.length} repositories visualized',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 10, // 11 → 10
                          height: 1.1,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // 정원 영역
                Expanded(
                  child: Container(
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
                          offset: Offset(0, 4),
                          blurRadius: 12,
                        ),
                        BoxShadow(
                          color: Color(0x14000000), // rgba(0, 0, 0, 0.08)
                          offset: Offset(0, 30),
                          blurRadius: 80,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // 단순한 배경 (진한 갈색 - 땅 느낌)
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF5D4E37), // 진한 갈색 (흙 느낌)
                            ),
                          ),

                          // InteractiveViewer로 정원 트리들 감싸기
                          InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4,
                            boundaryMargin: const EdgeInsets.all(200),
                            child: _NaturalGardenLayout(
                              repositories: repositories,
                            ),
                          ),

                          // "Press anywhere" 힌트 (하단) - 터치 무시하도록 수정
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 20,
                            child: IgnorePointer(
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x66000000),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Pinch to zoom • Drag to explore',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // ForestScreen으로 이동하는 버튼 (우측 상단)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ForestScreen(token: token),
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
                                      color: const Color(
                                        0xFF14B8A6,
                                      ).withValues(alpha: 0.3),
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
                    ),
                  ),
                ),

                // 하단 여백
                const SizedBox(height: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 격자형 정원 레이아웃 - 외곽부터 채워나가는 방식
class _NaturalGardenLayout extends StatelessWidget {
  const _NaturalGardenLayout({required this.repositories});

  final List<RepositoryStatsModel> repositories;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // 고정 크기 (더 크게)
        const treeSize = 64.0; // 48 → 64
        const spacing = 64.0; // 48 → 64

        // 그리드 계산 - 패딩 고려
        final cols = ((width - 100) / spacing).floor();
        final rows = ((height - 100) / spacing).floor();

        // 외곽부터 안쪽으로 채워나가는 순서
        final positions = _calculateSpiralPositions(
          repositories.length,
          cols,
          rows,
          spacing,
          width - 100,
          height - 100,
        );

        return Stack(
          children: List.generate(
            math.min(repositories.length, positions.length),
            (index) {
              final repo = repositories[index];
              final position = positions[index];

              // 레포지토리 나이 계산 (년 단위)
              final createdAt = repo.repository.createdAt;
              final now = DateTime.now();
              final ageInYears = now.difference(createdAt).inDays / 365.0;

              return Positioned(
                left: position.dx,
                top: position.dy,
                child: _GardenTree(
                  repository: repo,
                  size: treeSize,
                  index: index,
                  ageInYears: ageInYears,
                  totalRepos: repositories.length,
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// 중심에서 바깥으로 나선형 순서로 위치 계산
  List<Offset> _calculateSpiralPositions(
    int count,
    int cols,
    int rows,
    double spacing,
    double width,
    double height,
  ) {
    final positions = <Offset>[];

    // 중앙 정렬을 위한 오프셋 (중심을 왼쪽으로 이동)
    final offsetX =
        (width - (cols * spacing)) / 2 + 50; // 왼쪽으로 조금만 이동 (50px 오른쪽)
    final offsetY = (height - (rows * spacing)) / 2 + 50; // 패딩 고려

    // 중심 좌표
    final centerCol = cols ~/ 2;
    final centerRow = rows ~/ 2;

    // 중심부터 시작
    positions.add(
      Offset(
        offsetX + centerCol * spacing + spacing / 2,
        offsetY + centerRow * spacing + spacing / 2,
      ),
    );

    if (count <= 1) return positions;

    // 나선형으로 바깥으로 확장 (오른쪽 → 아래 → 왼쪽 → 위)
    var x = centerCol;
    var y = centerRow;
    var steps = 1;

    while (positions.length < count) {
      // 오른쪽으로 steps번
      for (var i = 0; i < steps && positions.length < count; i++) {
        x++;
        if (x >= 0 && x < cols && y >= 0 && y < rows) {
          positions.add(
            Offset(
              offsetX + x * spacing + spacing / 2,
              offsetY + y * spacing + spacing / 2,
            ),
          );
        }
      }

      // 아래로 steps번
      for (var i = 0; i < steps && positions.length < count; i++) {
        y++;
        if (x >= 0 && x < cols && y >= 0 && y < rows) {
          positions.add(
            Offset(
              offsetX + x * spacing + spacing / 2,
              offsetY + y * spacing + spacing / 2,
            ),
          );
        }
      }

      steps++;

      // 왼쪽으로 steps번
      for (var i = 0; i < steps && positions.length < count; i++) {
        x--;
        if (x >= 0 && x < cols && y >= 0 && y < rows) {
          positions.add(
            Offset(
              offsetX + x * spacing + spacing / 2,
              offsetY + y * spacing + spacing / 2,
            ),
          );
        }
      }

      // 위로 steps번
      for (var i = 0; i < steps && positions.length < count; i++) {
        y--;
        if (x >= 0 && x < cols && y >= 0 && y < rows) {
          positions.add(
            Offset(
              offsetX + x * spacing + spacing / 2,
              offsetY + y * spacing + spacing / 2,
            ),
          );
        }
      }

      steps++;
    }

    return positions;
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

    // 나이 기반 색상 조정 (0년 = 1.0, 10년+ = 0.5)
    final ageInYears = widget.ageInYears;
    final ageFactor = 1.0 - (ageInYears / 10).clamp(0.0, 0.5); // 최대 50% 감소
    final treeOpacity =
        (0.3 + (activityTier.saturationMultiplier * 0.7)) * ageFactor;

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
          // 땅바닥 원형 (나이별 색상)
          Positioned(
            bottom: widget.size * 0.1,
            child: Container(
              width: widget.size * 1.5,
              height: widget.size * 1.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _getGroundColor(ageInYears).withValues(alpha: 0.6),
                    _getGroundColor(ageInYears).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // 나무와 라벨
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 나무 이미지 (글로우 효과 포함)
              // 단계별 크기: 새싹 < 꽃 < 나무
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
              // 이름표 (그림자 + 텍스트)
              Container(
                width: widget.size * 0.9,
                height: widget.size * 0.2,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  repo.repository.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 7,
                    color: Colors.white.withValues(alpha: 0.9),
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

  /// 트리 이미지 경로 가져오기 (언어 기반)
  String _getTreeImagePath(TreeStage stage, int variantIndex, bool isCactus) {
    final plantType = widget.repository.plantType;

    // 성장 단계별 이미지 반환
    switch (stage) {
      case TreeStage.sprout:
        switch (plantType) {
          case PlantType.bamboo:
            return Assets.images.plants.sproutBambooDot.path;
          case PlantType.blossom:
            return Assets.images.plants.sproutBlossomDot.path;
          case PlantType.cactus:
            return Assets.images.plants.sproutCactusDot.path;
          case PlantType.coffee:
            return Assets.images.plants.sproutCoffeeDot.path;
          case PlantType.fir:
            return Assets.images.plants.sproutFirDot.path;
          case PlantType.ginkgo:
            return Assets.images.plants.sproutGinkgoDot.path;
          case PlantType.maple:
            return Assets.images.plants.sproutMapleDot.path;
          case PlantType.oak:
            return Assets.images.plants.sproutOakDot.path;
          case PlantType.pine:
            return Assets.images.plants.sproutPineDot.path;
          case PlantType.snakePlant:
            return Assets.images.plants.sproutSnakePlantDot.path;
        }
      case TreeStage.bloom:
        switch (plantType) {
          case PlantType.bamboo:
            return Assets.images.plants.flowerBambooDot.path;
          case PlantType.blossom:
            return Assets.images.plants.flowerBlossomDot.path;
          case PlantType.cactus:
            return Assets.images.plants.flowerCactusDot.path;
          case PlantType.coffee:
            return Assets.images.plants.flowerCoffeeDot.path;
          case PlantType.fir:
            return Assets.images.plants.flowerFirDot.path;
          case PlantType.ginkgo:
            return Assets.images.plants.flowerGinkgoDot.path;
          case PlantType.maple:
            return Assets.images.plants.flowerMapleDot.path;
          case PlantType.oak:
            return Assets.images.plants.flowerOakDot.path;
          case PlantType.pine:
            return Assets.images.plants.flowerPineDot.path;
          case PlantType.snakePlant:
            return Assets.images.plants.flowerSnakePlantDot.path;
        }
      case TreeStage.tree:
        switch (plantType) {
          case PlantType.bamboo:
            return Assets.images.plants.treeBambooDot.path;
          case PlantType.blossom:
            return Assets.images.plants.treeBlossomDot.path;
          case PlantType.cactus:
            return Assets.images.plants.treeCactusDot.path;
          case PlantType.coffee:
            return Assets.images.plants.treeCoffeeDot.path;
          case PlantType.fir:
            return Assets.images.plants.treeFirDot.path;
          case PlantType.ginkgo:
            return Assets.images.plants.treeGinkgoDot.path;
          case PlantType.maple:
            return Assets.images.plants.treeMapleDot.path;
          case PlantType.oak:
            return Assets.images.plants.treeOakDot.path;
          case PlantType.pine:
            return Assets.images.plants.treePineDot.path;
          case PlantType.snakePlant:
            return Assets.images.plants.treeSnakePlantDot.path;
        }
    }
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

  /// 레포지토리 나이에 따른 땅바닥 색상
  /// 0년 = 밝은 색, 5년+ = 어두운 색
  Color _getGroundColor(double ageInYears) {
    if (ageInYears < 1) {
      // 1년 미만: 밝은 갈색/연두
      return const Color(0xFF8B7355);
    } else if (ageInYears < 2) {
      // 1-2년: 중간 밝은 갈색
      return const Color(0xFF7A6F5D);
    } else if (ageInYears < 3) {
      // 2-3년: 중간 갈색
      return const Color(0xFF6B5D4F);
    } else if (ageInYears < 5) {
      // 3-5년: 어두운 갈색
      return const Color(0xFF5D4E37);
    } else {
      // 5년 이상: 매우 어두운 갈색
      return const Color(0xFF4A3C28);
    }
  }
}
