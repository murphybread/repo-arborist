import 'package:template/features/github/models/github_repository_model.dart';

/// Repository 통계 정보를 포함한 모델
class RepositoryStatsModel {
  /// RepositoryStatsModel 생성자
  const RepositoryStatsModel({
    required this.repository,
    required this.totalCommits,
    required this.totalMergedPRs,
  });

  /// Repository 기본 정보
  final GithubRepositoryModel repository;

  /// 총 커밋 수
  final int totalCommits;

  /// 총 머지된 PR 수
  final int totalMergedPRs;

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
