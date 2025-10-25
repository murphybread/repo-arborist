import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:template/features/github/models/repository_stats_model.dart';

/// 레포지토리 상세 정보 화면
class RepositoryDetailScreen extends StatelessWidget {
  /// RepositoryDetailScreen 생성자
  const RepositoryDetailScreen({
    required this.repository,
    super.key,
  });

  /// 레포지토리 통계 모델
  final RepositoryStatsModel repository;

  @override
  Widget build(BuildContext context) {
    final stage = repository.treeStage;
    final variantIndex = repository.variantIndex;

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
                        repository.repository.name,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Center(
                  child: SizedBox(
                    height: 200,
                    child: SvgPicture.asset(
                      _getTreeImagePath(stage, variantIndex),
                      fit: BoxFit.contain,
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
                      value: repository.totalCommits.toString(),
                    ),

                    // Merged PRs 카드
                    _StatCard(
                      label: 'Merged\nPRs',
                      value: repository.totalMergedPRs.toString(),
                    ),

                    // Project score 카드
                    _StatCard(
                      label: 'Project\nscore',
                      value: repository.projectSizeScore.toString(),
                      formula: 'commits +\nmerged\nPRs × 5',
                    ),
                  ],
                ),
              ),

              // Activity timeline (preview)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Activity timeline (preview)',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          height: 1.25,
                          letterSpacing: -0.025,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Commit history / activity chart will\nappear here.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.5,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
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
