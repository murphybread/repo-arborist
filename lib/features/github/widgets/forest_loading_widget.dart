import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:template/features/github/controllers/forest_controller.dart';
import 'package:template/features/github/models/repository_stats_model.dart';
import 'package:template/features/github/screens/garden_overview_screen.dart';

/// Forest 생성 중 로딩 위젯
class ForestLoadingWidget extends ConsumerStatefulWidget {
  /// ForestLoadingWidget 생성자
  const ForestLoadingWidget({
    this.token,
    this.username,
    super.key,
  });

  /// GitHub Personal Access Token (null인 경우 username 사용)
  final String? token;

  /// GitHub username (token이 null일 때 public repos 조회용)
  final String? username;

  @override
  ConsumerState<ForestLoadingWidget> createState() => _ForestLoadingWidgetState();
}

class _ForestLoadingWidgetState extends ConsumerState<ForestLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _treeController;
  late AnimationController _progressController;
  late AnimationController _floatController;

  late Animation<double> _tree1Scale;
  late Animation<double> _tree2Scale;
  late Animation<double> _tree3Scale;
  late Animation<double> _progressValue;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // 나무 성장 애니메이션 (Stagger)
    _treeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _tree1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _treeController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _tree2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _treeController,
        curve: const Interval(0.2, 0.6, curve: Curves.elasticOut),
      ),
    );

    _tree3Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _treeController,
        curve: const Interval(0.4, 0.8, curve: Curves.elasticOut),
      ),
    );

    // 프로그레스 바 애니메이션
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _progressValue = Tween<double>(begin: 0.0, end: 0.45).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // 부드러운 떠있는 애니메이션
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    // 애니메이션 시작
    _treeController.forward();
    _progressController.forward();
    _floatController.repeat(reverse: true);
  }

  bool _hasStartedLoading = false;
  bool _hasNavigated = false;

  /// Repository 통계 로드 시작
  void _startLoadingAndNavigation() {
    ref.read(forestProvider.notifier).loadRepositoryStats(
      token: widget.token,
      username: widget.username,
    );
  }

  @override
  void dispose() {
    _treeController.dispose();
    _progressController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 첫 빌드 시 한 번만 데이터 로드 시작
    if (!_hasStartedLoading) {
      _hasStartedLoading = true;
      // 빌드 완료 후 비동기 작업 시작
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startLoadingAndNavigation();
      });
    }

    // forestProvider 상태 감지
    ref.listen<AsyncValue<List<RepositoryStatsModel>>>(
      forestProvider,
      (previous, next) {
        next.whenData((repos) {
          if (!_hasNavigated && repos.isNotEmpty) {
            _hasNavigated = true;
            // 2초 대기 후 네비게이션
            Future.delayed(const Duration(milliseconds: 2000), () {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => GardenOverviewScreen(
                      token: widget.token,
                      username: widget.username,
                    ),
                  ),
                );
              }
            });
          }
        });
      },
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFE0F2FE),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Heading
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 58,
                    vertical: 24,
                  ),
                  child: FadeTransition(
                    opacity: _treeController,
                    child: Text(
                      'Generating your\nforest…',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 32,
                        height: 1.25,
                        letterSpacing: -0.8,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ),

                // Description
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 32,
                  ),
                  child: FadeTransition(
                    opacity: _treeController,
                    child: Text(
                      'We\'re reading your GitHub repositories and\nturning them into living trees.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        height: 1.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),

                // Animated Trees
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Tree 1 - Sprout
                            ScaleTransition(
                              scale: _tree1Scale,
                              child: SizedBox(
                                width: 87,
                                height: 100,
                                child: SvgPicture.asset(
                                  'assets/images/trees/sprout.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Tree 2 - Bloom
                            ScaleTransition(
                              scale: _tree2Scale,
                              child: SizedBox(
                                width: 80,
                                height: 80,
                                child: SvgPicture.asset(
                                  'assets/images/trees/bloom_yellow.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Tree 3 - Tree
                            ScaleTransition(
                              scale: _tree3Scale,
                              child: SizedBox(
                                width: 87,
                                height: 100,
                                child: SvgPicture.asset(
                                  'assets/images/trees/tree_green.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Status Text and Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Status Text
                      FadeTransition(
                        opacity: _progressController,
                        child: Text(
                          'Analyzing repositories, commits, and merged\nPRs…',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 1.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Progress Bar
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: AnimatedBuilder(
                          animation: _progressValue,
                          builder: (context, child) {
                            return Stack(
                              children: [
                                FractionallySizedBox(
                                  widthFactor: _progressValue.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF86EFAC),
                                      borderRadius: BorderRadius.circular(9999),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFDCFCE7)
                                              .withValues(alpha: 0.7),
                                          offset: const Offset(0, 10),
                                          blurRadius: 30,
                                          spreadRadius: -10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Info Text
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 32,
                  ),
                  child: FadeTransition(
                    opacity: _treeController,
                    child: Text(
                      'Each repo becomes a tree. Small projects appear\nas sprouts. Larger, established projects appear\nas blooming trees or mature trees.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        height: 1.5,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
