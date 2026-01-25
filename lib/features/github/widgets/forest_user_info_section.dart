import 'package:flutter/material.dart';

/// Displays username in the forest header.
class ForestUserInfoSection extends StatelessWidget {
  final String username;

  const ForestUserInfoSection({required this.username, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      username,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        fontSize: 22,
        height: 1.25,
        letterSpacing: -0.5,
        color: Colors.white,
      ),
    );
  }
}
