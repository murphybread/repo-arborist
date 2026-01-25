import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    required this.error,
    this.title = 'Error loading data',
    this.onRetry,
    this.retryLabel,
    this.iconSize = 48,
    this.iconColor = const Color(0xFFEF4444),
    this.titleColor = const Color(0xFF1E293B),
    this.errorTextColor = const Color(0xFF64748B),
    this.padding = const EdgeInsets.all(32),
    this.buttonColor = const Color(0xFF14B8A6),
    super.key,
  });

  final Object error;

  final String title; // 기본값: 'Error loading data'
  final VoidCallback? onRetry; // null이면 버튼 숨김
  final String? retryLabel; // 기본값: 'Retry'
  final double iconSize; // 기본값: 48
  final Color iconColor; // 기본값: Color(0xFFEF4444) (빨강)
  final Color titleColor; // 기본값: Color(0xFF1E293B) (어두운 회색)
  final Color errorTextColor; // 기본값: Color(0xFF64748B) (중간 회색)
  final EdgeInsets padding; // 기본값: EdgeInsets.all(32)
  final Color buttonColor; // 기본값: Color(0xFF14B8A6) (teal)

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: iconSize, color: iconColor),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: errorTextColor,
              ),
            ),
            // Conditional button: only shown when onRetry is provided
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(retryLabel ?? 'Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
