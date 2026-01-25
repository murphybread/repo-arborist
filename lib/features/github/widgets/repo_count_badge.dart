import 'package:flutter/material.dart';

class RepoCountBadge extends StatelessWidget {
  final int count;

  const RepoCountBadge({
    required this.count,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        '$count repos',
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: const Color(0xFF14B8A6),
        ),
      ),
    );
  }
}
