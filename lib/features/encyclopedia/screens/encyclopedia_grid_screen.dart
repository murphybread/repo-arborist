import 'package:flutter/material.dart';
import 'package:repo_arborist/features/encyclopedia/models/plant_encyclopedia_data.dart';
import 'package:repo_arborist/features/encyclopedia/screens/encyclopedia_detail_screen.dart';
import 'package:repo_arborist/features/github/models/repository_stats_model.dart';
import 'package:repo_arborist/gen/assets.gen.dart';

/// Encyclopedia grid screen showing all plant families
class EncyclopediaGridScreen extends StatelessWidget {
  const EncyclopediaGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14B8A6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              Assets.images.encyclopedia.plantBookIcon.path,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Plant Encyclopedia',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Plant Families',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Discover the 11 plant families and their meanings',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),

              // [Modified] Use ListView.separated instead of GridView
              // This allows the cards to have a fixed height (defined in _PlantFamilyCard)
              // while stretching horizontally to fill the screen width.
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: PlantEncyclopedia.entries.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final entry = PlantEncyclopedia.entries[index];
                  return _PlantFamilyCard(entry: entry);
                },
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),
              const Text(
                'Growth Stages',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              ...GrowthStageInfo.stages.map((stage) {
                return _GrowthStageItem(info: stage);
              }),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),
              const Text(
                'Activity Tiers',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              ...ActivityTierInfo.tiers.map((tier) {
                return _ActivityTierItem(info: tier);
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Plant family card widget with ui_slot_vine background and actual plant image
class _PlantFamilyCard extends StatelessWidget {
  const _PlantFamilyCard({required this.entry});

  final PlantEncyclopediaEntry entry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EncyclopediaDetailScreen(entry: entry),
          ),
        );
      },
      // [Modified] Use SizedBox with reduced height to create horizontal stretch
      // Full width with shorter height creates a landscape rectangle
      child: SizedBox(
        height: 160,
        width: double.infinity,
        child: Transform(
          transform: Matrix4.diagonal3Values(1.1, 1.1, 1),
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.images.encyclopedia.uiSlotVine.path),
                fit: BoxFit.fill,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 64,
                right: 24,
                top: 6,
                bottom: 6,
              ),
              child: Row(
                children: [
                  // Tree Image
                  Image.asset(
                    entry.plantType.getImagePath(TreeStage.tree),
                    width: 100,
                    height: 100,
                    filterQuality: FilterQuality.none,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    width: 12,
                  ), // Added slight spacing between image and text
                  // Text Content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.familyName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: entry.plantType.primaryColor,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: entry.languages.take(3).map((lang) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: entry.plantType.primaryColor.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: entry.plantType.primaryColor
                                      .withValues(
                                        alpha: 0.3,
                                      ),
                                ),
                              ),
                              child: Text(
                                lang,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  color: entry.plantType.primaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Growth stage info item
class _GrowthStageItem extends StatelessWidget {
  const _GrowthStageItem({required this.info});

  final GrowthStageInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            info.requirement,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: Color(0xFF14B8A6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            info.description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

/// Activity tier info item
class _ActivityTierItem extends StatelessWidget {
  const _ActivityTierItem({required this.info});

  final ActivityTierInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getTierColor(info.tier),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                info.name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            info.timeframe,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: Color(0xFF14B8A6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            info.description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Effect: ${info.visualEffect}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(ActivityTier tier) {
    switch (tier) {
      case ActivityTier.fresh:
        return const Color(0xFF22C55E);
      case ActivityTier.warm:
        return const Color(0xFFFBBF24);
      case ActivityTier.cooling:
        return const Color(0xFF94A3B8);
      case ActivityTier.dormant:
        return const Color(0xFF64748B);
    }
  }
}
