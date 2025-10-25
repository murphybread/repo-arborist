import 'package:template/features/github/models/github_repository_model.dart';

/// Repository 통계 정보를 포함한 모델
class RepositoryStatsModel {
  /// RepositoryStatsModel 생성자
  const RepositoryStatsModel({
    required this.repository,
    required this.totalCommits,
    required this.totalMergedPRs,
    this.lastCommitDate,
    this.lastMergedPRDate,
  });

  /// Repository 기본 정보
  final GithubRepositoryModel repository;

  /// 총 커밋 수
  final int totalCommits;

  /// 총 머지된 PR 수
  final int totalMergedPRs;

  /// 마지막 커밋 날짜
  final DateTime? lastCommitDate;

  /// 마지막 머지된 PR 날짜
  final DateTime? lastMergedPRDate;

  /// 프로젝트 규모 점수 계산
  ///
  /// score = total_commits + (total_merged_prs * 5)
  int get projectSizeScore => totalCommits + (totalMergedPRs * 5);

  /// 나무 단계 결정
  ///
  /// - score < 50: Sprout (새싹)
  /// - 50 <= score < 150: Bloom (꽃)
  /// - 150 <= score: Tree (나무)
  TreeStage get treeStage {
    if (projectSizeScore < 50) {
      return TreeStage.sprout;
    } else if (projectSizeScore < 150) {
      return TreeStage.bloom;
    } else {
      return TreeStage.tree;
    }
  }

  /// 색상 변주 인덱스 계산 (레포 이름 기반 해시)
  int get variantIndex {
    final variantCount = treeStage.variantCount;
    var sum = 0;
    for (final code in repository.name.codeUnits) {
      sum = (sum + code) % 100000;
    }
    return sum % variantCount;
  }

  /// 마지막 활동 날짜 계산
  ///
  /// 마지막 커밋 또는 마지막 머지된 PR 중 더 최신 것을 반환
  DateTime? get lastActivityDate {
    if (lastCommitDate == null && lastMergedPRDate == null) {
      return null;
    }
    if (lastCommitDate == null) return lastMergedPRDate;
    if (lastMergedPRDate == null) return lastCommitDate;

    return lastCommitDate!.isAfter(lastMergedPRDate!)
        ? lastCommitDate
        : lastMergedPRDate;
  }

  /// 마지막 활동 이후 경과 일수
  int get daysSinceLastActivity {
    final lastActivity = lastActivityDate;
    if (lastActivity == null) {
      // 활동 정보가 없으면 repository 생성일 기준
      return DateTime.now().difference(repository.createdAt).inDays;
    }
    return DateTime.now().difference(lastActivity).inDays;
  }

  /// 활동 티어 계산
  ///
  /// - Tier A (Fresh): 7일 이내
  /// - Tier B (Warm): 8~30일
  /// - Tier C (Cooling): 31~180일
  /// - Tier D (Dormant): 181일 이상
  ActivityTier get activityTier {
    final days = daysSinceLastActivity;

    if (days <= 7) {
      return ActivityTier.fresh;
    } else if (days <= 30) {
      return ActivityTier.warm;
    } else if (days <= 180) {
      return ActivityTier.cooling;
    } else {
      return ActivityTier.dormant;
    }
  }

  /// 선인장 모드 여부 (1년 이상 방치)
  bool get isCactusMode => daysSinceLastActivity >= 365;
}

/// 나무 성장 단계
enum TreeStage {
  /// 새싹 (score < 50)
  sprout(variantCount: 1),

  /// 꽃 (50 <= score < 150)
  bloom(variantCount: 4),

  /// 나무 (150 <= score)
  tree(variantCount: 2);

  const TreeStage({required this.variantCount});

  /// 이 단계의 색상 변주 개수
  final int variantCount;
}

/// 활동 티어 (최근성)
enum ActivityTier {
  /// Tier A: 신선함 (7일 이내)
  /// 강한 글로우, 높은 채도, 스케일 +5%
  fresh(
    saturationMultiplier: 1.0,
    glowIntensity: 0.8,
    scaleMultiplier: 1.05,
  ),

  /// Tier B: 따뜻함 (8~30일)
  /// 약한 글로우, 기본 채도, 기본 스케일
  warm(
    saturationMultiplier: 1.0,
    glowIntensity: 0.3,
    scaleMultiplier: 1.0,
  ),

  /// Tier C: 식어감 (31~180일)
  /// 글로우 없음, 채도 70%, 기본 스케일
  cooling(
    saturationMultiplier: 0.7,
    glowIntensity: 0.0,
    scaleMultiplier: 1.0,
  ),

  /// Tier D: 휴면 (181일 이상)
  /// 글로우 없음, 채도 50%, 스케일 -5%
  dormant(
    saturationMultiplier: 0.5,
    glowIntensity: 0.0,
    scaleMultiplier: 0.95,
  );

  const ActivityTier({
    required this.saturationMultiplier,
    required this.glowIntensity,
    required this.scaleMultiplier,
  });

  /// 채도 배율 (0.0 ~ 1.0)
  final double saturationMultiplier;

  /// 글로우 강도 (0.0 ~ 1.0)
  final double glowIntensity;

  /// 크기 배율
  final double scaleMultiplier;
}
