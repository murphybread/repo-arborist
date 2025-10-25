import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:template/features/github/controllers/forest_controller.dart';
import 'package:template/features/github/models/repository_stats_model.dart';
import 'package:template/features/github/screens/forest_screen.dart';

/// 정원 오버뷰 화면 - 모든 레포지토리를 자연스럽게 배치
class GardenOverviewScreen extends ConsumerWidget {
  /// GardenOverviewScreen 생성자
  const GardenOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reposAsync = ref.watch(forestProvider);

    return reposAsync.when(
      data: (repos) {
        // created_at 기준으로 정렬 (오래된 것부터)
        final sortedRepos = List<RepositoryStatsModel>.from(repos)
          ..sort((a, b) => a.repository.createdAt.compareTo(b.repository.createdAt));

        return _GardenView(repositories: sortedRepos);
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

/// 정원 뷰 위젯
class _GardenView extends StatelessWidget {
  const _GardenView({required this.repositories});

  final List<RepositoryStatsModel> repositories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // 배경 그라디언트
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.3, -0.8),
                radius: 1.2,
                colors: [
                  Color(0x26B4FFD2), // rgba(180, 255, 210, 0.15)
                  Colors.transparent,
                ],
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF8FAFC),
                    Color(0xFFFFFFFF),
                  ],
                  stops: [0.0, 0.7],
                ),
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
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ForestScreen(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000), // rgba(0, 0, 0, 0.05)
                            offset: Offset(0, 4),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color(0x14000000), // rgba(0, 0, 0, 0.08)
                            offset: Offset(0, 30),
                            blurRadius: 80,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            // 단순한 배경 (진한 초록/갈색 - 땅 느낌)
                            Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF86A789), // 올리브/카키 초록 (흙 느낌)
                              ),
                            ),

                            // 정원 트리들
                            _NaturalGardenLayout(repositories: repositories),

                            // "Press anywhere" 힌트 (하단)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 20,
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
                                    'Tap anywhere to see details',
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
                          ],
                        ),
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

        // 고정 크기
        const treeSize = 48.0;
        const spacing = 48.0; // 52 → 48 (더 빽빽하게)

        // 그리드 계산
        final cols = (width / spacing).floor();
        final rows = ((height - 80) / spacing).floor(); // 하단 힌트 영역 제외

        // 외곽부터 안쪽으로 채워나가는 순서
        final positions = _calculateSpiralPositions(
          repositories.length,
          cols,
          rows,
          spacing,
          width,
          height - 80,
        );

        return Stack(
          children: List.generate(
            math.min(repositories.length, positions.length),
            (index) {
              final repo = repositories[index];
              final position = positions[index];

              return Positioned(
                left: position.dx,
                top: position.dy,
                child: _GardenTree(
                  repository: repo,
                  size: treeSize,
                  index: index,
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

    // 중앙 정렬을 위한 오프셋
    final offsetX = (width - (cols * spacing)) / 2;
    final offsetY = (height - (rows * spacing)) / 2;

    // 중심 좌표
    final centerCol = cols ~/ 2;
    final centerRow = rows ~/ 2;

    // 중심부터 시작
    positions.add(Offset(
      offsetX + centerCol * spacing + spacing / 2,
      offsetY + centerRow * spacing + spacing / 2,
    ));

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
          positions.add(Offset(
            offsetX + x * spacing + spacing / 2,
            offsetY + y * spacing + spacing / 2,
          ));
        }
      }

      // 아래로 steps번
      for (var i = 0; i < steps && positions.length < count; i++) {
        y++;
        if (x >= 0 && x < cols && y >= 0 && y < rows) {
          positions.add(Offset(
            offsetX + x * spacing + spacing / 2,
            offsetY + y * spacing + spacing / 2,
          ));
        }
      }

      steps++;

      // 왼쪽으로 steps번
      for (var i = 0; i < steps && positions.length < count; i++) {
        x--;
        if (x >= 0 && x < cols && y >= 0 && y < rows) {
          positions.add(Offset(
            offsetX + x * spacing + spacing / 2,
            offsetY + y * spacing + spacing / 2,
          ));
        }
      }

      // 위로 steps번
      for (var i = 0; i < steps && positions.length < count; i++) {
        y--;
        if (x >= 0 && x < cols && y >= 0 && y < rows) {
          positions.add(Offset(
            offsetX + x * spacing + spacing / 2,
            offsetY + y * spacing + spacing / 2,
          ));
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
  });

  final RepositoryStatsModel repository;
  final double size;
  final int index;

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
    _swayAnimation = Tween<double>(
      begin: -maxAngle,
      end: maxAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stage = widget.repository.treeStage;
    final variantIndex = widget.repository.variantIndex;
    final imagePath = _getTreeImagePath(stage, variantIndex);

    return AnimatedBuilder(
      animation: _swayAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _swayAnimation.value,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 나무 이미지
          SizedBox(
            width: widget.size,
            height: widget.size * 1.2,
            child: SvgPicture.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
          // 그림자
          Container(
            width: widget.size * 0.9,
            height: widget.size * 0.2,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
      ),
    );
  }

  /// 트리 이미지 경로 가져오기
  String _getTreeImagePath(TreeStage stage, int variantIndex) {
    switch (stage) {
      case TreeStage.sprout:
        return 'assets/images/trees/sprout.svg';
      case TreeStage.bloom:
        const bloomVariants = [
          'assets/images/trees/bloom_yellow.svg',
          'assets/images/trees/bloom_blue.svg',
          'assets/images/trees/bloom_orange.svg',
          'assets/images/trees/bloom_pink.svg',
        ];
        return bloomVariants[variantIndex];
      case TreeStage.tree:
        const treeVariants = [
          'assets/images/trees/tree_green.svg',
          'assets/images/trees/tree_red.svg',
        ];
        return treeVariants[variantIndex];
    }
  }
}

