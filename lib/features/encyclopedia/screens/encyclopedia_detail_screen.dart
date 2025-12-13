import 'package:flutter/material.dart';
import 'package:repo_arborist/features/encyclopedia/models/plant_encyclopedia_data.dart';
import 'package:repo_arborist/features/github/models/repository_stats_model.dart';
import 'package:repo_arborist/gen/assets.gen.dart';

/// Encyclopedia detail screen showing plant family information
class EncyclopediaDetailScreen extends StatelessWidget {
  const EncyclopediaDetailScreen({
    required this.entry,
    super.key,
  });

  final PlantEncyclopediaEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: entry.plantType.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          entry.familyName,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section with plant image
            // EncyclopediaDetailScreen 내부의 build 메소드 안쪽
            // Header section with plant image 부분을 찾아서 교체하세요.
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    entry.plantType.primaryColor,
                    entry.plantType.primaryColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  // [수정] 아래쪽 패딩을 32 -> 50으로 늘려서 텍스트 아래 공간 확보
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 50),
                  child: Column(
                    children: [
                      // [수정] 나무 이미지 크기 확대 (180 -> 250)
                      Image.asset(
                        entry.plantType.getImagePath(TreeStage.tree),
                        width: 250,
                        height: 250,
                        filterQuality: FilterQuality.none,
                        fit: BoxFit.contain,
                      ),

                      // [수정] 나무와 글자 사이 간격 벌리기 (20 -> 30)
                      // 글자를 좀 더 아래로 밀어내는 역할
                      const SizedBox(height: 30),

                      // [수정] 글자 크기 축소 (28 -> 22)
                      Text(
                        entry.familyName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description card with plant_card_bg background
                  Stack(
                    children: [
                      Image.asset(
                        Assets.images.encyclopedia.plantCardBg.path,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // Increased padding for safe area
                      Padding(
                        padding: const EdgeInsets.fromLTRB(40, 50, 40, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Languages tags
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: entry.languages.map((lang) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: entry.plantType.primaryColor
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: entry.plantType.primaryColor
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    lang,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                      color: entry.plantType.primaryColor,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            // Title with semi-transparent background
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Description',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Description text with better contrast
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                entry.description,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(0xFF1E293B),
                                  height: 1.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Growth stages - one per row
                  const Text(
                    'Growth Stages',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStageCard(
                    context,
                    TreeStage.sprout,
                    'Sprout',
                    '< 100',
                  ),
                  const SizedBox(height: 12),
                  _buildStageCard(
                    context,
                    TreeStage.bloom,
                    'Bloom',
                    '100-299',
                  ),
                  const SizedBox(height: 12),
                  _buildStageCard(
                    context,
                    TreeStage.tree,
                    'Tree',
                    '≥ 300',
                  ),

                  const SizedBox(height: 24),

                  // Characteristics
                  const Text(
                    'Characteristics',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...entry.characteristics.map((char) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: entry.plantType.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              char,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // Growth info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: entry.plantType.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: entry.plantType.primaryColor.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: entry.plantType.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.growthInfo,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: entry.plantType.primaryColor.withValues(
                                red: entry.plantType.primaryColor.r * 0.7,
                                green: entry.plantType.primaryColor.g * 0.7,
                                blue: entry.plantType.primaryColor.b * 0.7,
                              ),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageCard(
    BuildContext context,
    TreeStage stage,
    String name,
    String score,
  ) {
    return Container(
      width: double.infinity,
      // 내부 패딩을 줄여서 이미지가 커질 공간 확보 (20 -> 16)
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.plantType.primaryColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. 이미지 대폭 확대 (120 -> 150)
          Image.asset(
            entry.plantType.getImagePath(stage),
            width: 150,
            height: 150,
            filterQuality: FilterQuality.none,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16), // 간격 조정
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    // 2. 이름 글자 크기 축소 (20 -> 16)
                    fontSize: 16,
                    color: entry.plantType.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: entry.plantType.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Score: $score',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      // 3. 점수 글자 크기 축소 (14 -> 12)
                      fontSize: 12,
                      color: entry.plantType.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
