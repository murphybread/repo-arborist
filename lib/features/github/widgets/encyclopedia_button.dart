import 'package:flutter/material.dart';
import 'package:repo_arborist/features/encyclopedia/screens/encyclopedia_grid_screen.dart';
import 'package:repo_arborist/gen/assets.gen.dart';

class EncyclopediaButton extends StatelessWidget {
  const EncyclopediaButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const EncyclopediaGridScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF8B7355).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF8B7355),
            width: 1,
          ),
        ),
        child: Image.asset(
          Assets.images.encyclopedia.plantBookIcon.path,
          width: 20,
          height: 20,
        ),
      ),
    );
  }
}
