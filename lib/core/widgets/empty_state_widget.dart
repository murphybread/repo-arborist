import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:repo_arborist/core/themes/app_colors.dart';
import 'package:repo_arborist/core/themes/app_typography.dart';

/// 빈 상태를 표시하는 위젯
class EmptyStateWidget extends StatelessWidget {
  /// EmptyStateWidget 생성자
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  /// 표시할 아이콘
  final IconData icon;

  /// 제목
  final String title;

  /// 설명 메시지
  final String message;

  /// 액션 버튼 레이블 (선택)
  final String? actionLabel;

  /// 액션 버튼 콜백 (선택)
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: colors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTypography.title.copyWith(
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTypography.body.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 저장소가 없을 때 표시하는 위젯
class EmptyRepositoriesWidget extends StatelessWidget {
  /// EmptyRepositoriesWidget 생성자
  const EmptyRepositoriesWidget({
    super.key,
    this.onRefresh,
  });

  /// 새로고침 콜백
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.forest_outlined,
      title: 'empty.repositories_title'.tr(),
      message: 'empty.repositories_message'.tr(),
      actionLabel: onRefresh != null ? 'common.refresh'.tr() : null,
      onAction: onRefresh,
    );
  }
}

/// 검색 결과가 없을 때 표시하는 위젯
class EmptySearchResultWidget extends StatelessWidget {
  /// EmptySearchResultWidget 생성자
  const EmptySearchResultWidget({
    super.key,
    required this.query,
  });

  /// 검색어
  final String query;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'empty.search_title'.tr(),
      message: 'empty.search_message'.tr(args: [query]),
    );
  }
}

/// 네트워크 연결 없음
class NoConnectionWidget extends StatelessWidget {
  /// NoConnectionWidget 생성자
  const NoConnectionWidget({
    super.key,
    required this.onRetry,
  });

  /// 재시도 콜백
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: 'empty.no_connection_title'.tr(),
      message: 'empty.no_connection_message'.tr(),
      actionLabel: 'common.retry'.tr(),
      onAction: onRetry,
    );
  }
}
