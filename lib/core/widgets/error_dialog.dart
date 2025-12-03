import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:repo_arborist/core/themes/app_colors.dart';
import 'package:repo_arborist/core/themes/app_typography.dart';

/// 에러 다이얼로그를 표시하는 유틸리티 함수
class ErrorDialog {
  /// 기본 에러 다이얼로그 표시
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTypography.title.copyWith(
            color: context.colors.error,
          ),
        ),
        content: Text(
          message,
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.close'.tr()),
          ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text('common.retry'.tr()),
            ),
        ],
      ),
    );
  }

  /// 네트워크 에러 다이얼로그
  static Future<void> showNetworkError({
    required BuildContext context,
    VoidCallback? onRetry,
  }) {
    return show(
      context: context,
      title: 'error.network_title'.tr(),
      message: 'error.network_message'.tr(),
      onRetry: onRetry,
    );
  }

  /// API 에러 다이얼로그
  static Future<void> showApiError({
    required BuildContext context,
    required int statusCode,
    VoidCallback? onRetry,
  }) {
    final message = switch (statusCode) {
      404 => 'error.not_found'.tr(),
      403 => 'error.forbidden'.tr(),
      401 => 'error.unauthorized'.tr(),
      429 => 'error.rate_limit'.tr(),
      _ => 'error.server_error'.tr(args: [statusCode.toString()]),
    };

    return show(
      context: context,
      title: 'error.api_title'.tr(),
      message: message,
      onRetry: statusCode != 404 ? onRetry : null,
    );
  }

  /// GitHub 사용자를 찾을 수 없음
  static Future<void> showUserNotFound({
    required BuildContext context,
    required String username,
  }) {
    return show(
      context: context,
      title: 'error.user_not_found_title'.tr(),
      message: 'error.user_not_found_message'.tr(args: [username]),
    );
  }

  /// Rate Limit 초과 에러
  static Future<void> showRateLimitError({
    required BuildContext context,
  }) {
    return show(
      context: context,
      title: 'error.rate_limit_title'.tr(),
      message: 'error.rate_limit_message'.tr(),
    );
  }

  /// 타임아웃 에러
  static Future<void> showTimeoutError({
    required BuildContext context,
    VoidCallback? onRetry,
  }) {
    return show(
      context: context,
      title: 'error.timeout_title'.tr(),
      message: 'error.timeout_message'.tr(),
      onRetry: onRetry,
    );
  }
}
