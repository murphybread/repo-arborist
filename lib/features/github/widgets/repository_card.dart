import 'package:flutter/material.dart';
import 'package:repo_arborist/features/github/screens/repository_detail_screen.dart';
import 'package:repo_arborist/gen/assets.gen.dart';
import 'package:repo_arborist/features/github/models/repository_stats_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RepositoryCard extends StatelessWidget {
  const RepositoryCard({
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
              // Frame border thickness requires adequate padding
              // to prevent frame from covering content
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
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
                  // Tree Image - Takes full space
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
                      padding: const EdgeInsets.all(12),
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
              ),
            ),

            // Frame Overlay
            Positioned.fill(
              child: Transform.scale(
                scale: 0.95,
                child: Image.asset(
                  Assets.images.etc.uiFrameOakDetailed.path,
                  fit: BoxFit.fill,
                  filterQuality:
                      FilterQuality.none, // Preserve pixel art quality
                ),
              ),
            ),

            // Repository Name - Positioned above frame
            Positioned(
              left: 14,
              right: 14,
              bottom: 22,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Text(
                  repository.repository.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        return 0.9; // 새싹: 기본보다 약간 작게
      case TreeStage.bloom:
        return 0.8; // 꽃: 기본 크기
      case TreeStage.tree:
        return 0.65; // 나무: 꽃보다 20% 크게
    }
  }
}
