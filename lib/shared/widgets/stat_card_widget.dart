import 'package:flutter/material.dart';

/// Reusable statistics card widget for displaying label-value pairs.
///
/// Commonly used for metrics display such as commit counts, PR counts, etc.
class StatCardWidget extends StatelessWidget {
  /// Creates a stat card widget.
  ///
  /// [label] and [value] are required.
  /// [formula] is optional and displayed below the value.
  const StatCardWidget({
    required this.label,
    required this.value,
    this.formula,
    this.width,
    this.backgroundColor = const Color(0xFF1E293B),
    this.borderColor = const Color(0x1AFFFFFF),
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(17),
    super.key,
  });

  /// Label text displayed at the top (e.g., "Total commits")
  final String label;

  /// Main value text displayed prominently (e.g., "123")
  final String value;

  /// Optional formula or description text (e.g., "commits + PRs × 5")
  final String? formula;

  /// Card width. If null, uses auto-calculated width based on screen size.
  final double? width;

  /// Background color of the card
  final Color backgroundColor;

  /// Border color of the card
  final Color borderColor;

  /// Border radius of the card corners
  final double borderRadius;

  /// Internal padding of the card
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    // Calculate card width if not provided (for 3-column layout)
    final cardWidth = width ?? _calculateDefaultWidth(context);

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(borderRadius),
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
      padding: padding,
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

  /// Calculate default width for 3-column grid layout.
  double _calculateDefaultWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // padding 16*2 + gap 16*2 = 64
    return (screenWidth - 64) / 3;
  }
}
