import 'package:flutter/material.dart';
import 'package:repo_arborist/features/github/models/github_repository_model.dart';
import 'package:repo_arborist/gen/assets.gen.dart';

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

  /// 커밋당 점수
  static const commitScore = 1;

  /// PR당 점수
  static const prScore = 3;

  /// JSON에서 모델로 변환
  factory RepositoryStatsModel.fromJson(Map<String, dynamic> json) {
    return RepositoryStatsModel(
      repository: GithubRepositoryModel.fromJson(
        json['repository'] as Map<String, dynamic>,
      ),
      totalCommits: json['total_commits'] as int,
      totalMergedPRs: json['total_merged_prs'] as int,
      lastCommitDate: json['last_commit_date'] != null
          ? DateTime.parse(json['last_commit_date'] as String)
          : null,
      lastMergedPRDate: json['last_merged_pr_date'] != null
          ? DateTime.parse(json['last_merged_pr_date'] as String)
          : null,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'repository': repository.toJson(),
      'total_commits': totalCommits,
      'total_merged_prs': totalMergedPRs,
      'last_commit_date': lastCommitDate?.toIso8601String(),
      'last_merged_pr_date': lastMergedPRDate?.toIso8601String(),
    };
  }

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
  /// score = (total_commits * commitScore) + (total_merged_prs * prScore)
  int get projectSizeScore =>
      (totalCommits * commitScore) + (totalMergedPRs * prScore);

  /// 나무 단계 결정
  ///
  /// - score < 100: Sprout (새싹)
  /// - 100 <= score < 300: Bloom (꽃)
  /// - 300 <= score: Tree (나무)
  TreeStage get treeStage {
    if (projectSizeScore < 100) {
      return TreeStage.sprout;
    } else if (projectSizeScore < 300) {
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

  /// 방치 모드 여부 (6개월 이상)
  bool get isNeglected => daysSinceLastActivity >= 180;

  /// 심각한 방치 모드 여부 (1년 이상)
  bool get isSeverelyNeglected => daysSinceLastActivity >= 365;

  /// 저장소 언어에 따른 식물 종류 반환
  PlantType get plantType {
    // 언어가 없는 경우 참나무 (General)
    final language = repository.language?.toLowerCase();
    if (language == null || language.isEmpty) {
      return PlantType.oak;
    }

    // 언어별 매핑
    return PlantType.fromLanguage(language);
  }

  /// 선인장 모드 여부 (하위 호환성, deprecated)
  @Deprecated('Use isNeglected or isSeverelyNeglected instead')
  bool get isCactusMode => isSeverelyNeglected;
}

/// 식물 종류 (10대 가문)
enum PlantType {
  /// ☕ 커피 가문 - Java, Kotlin, JVM
  coffee,

  /// 🌻 은행 가문 - JavaScript, TypeScript, Web
  ginkgo,

  /// 🐍 뱀식물 가문 - Python, AI, Data
  snakePlant,

  /// 🌲 전나무 가문 - C, C++, Rust, System
  fir,

  /// 🌸 벚꽃 가문 - Flutter, Swift, Mobile
  blossom,

  /// 🎋 대나무 가문 - Go, Node.js
  bamboo,

  /// 🌳 참나무 가문 - C#, General, Others
  oak,

  /// 🍁 단풍 가문 - Ruby, HTML
  maple,

  /// 🌵 선인장 가문 - Shell, Config, DevOps
  cactus,

  /// 🫐 블루베리 가문 - Dart, Flutter
  blueberry,

  /// ✂️ 소나무 가문 - Assembly, Embedded
  pine;

  /// 언어 이름으로 식물 타입 결정
  static PlantType fromLanguage(String language) {
    final lang = language.toLowerCase();

    // ☕ Coffee - Java, Kotlin, JVM
    if (lang == 'java' ||
        lang == 'kotlin' ||
        lang == 'scala' ||
        lang.contains('jvm')) {
      return PlantType.coffee;
    }

    // 🌻 Ginkgo - JavaScript, TypeScript, Web
    if (lang.contains('javascript') ||
        lang.contains('typescript') ||
        lang == 'js' ||
        lang == 'ts') {
      return PlantType.ginkgo;
    }

    // 🐍 Snake Plant - Python, AI, Data
    if (lang.contains('python') || lang == 'py' || lang == 'jupyter notebook') {
      return PlantType.snakePlant;
    }

    // 🌲 Fir - C, C++, Rust, System
    if (lang == 'c' ||
        lang == 'c++' ||
        lang == 'cpp' ||
        lang == 'rust' ||
        lang.contains('objective')) {
      return PlantType.fir;
    }

    // 🫐 Blueberry - Dart, Flutter
    if (lang == 'dart' || lang.contains('flutter')) {
      return PlantType.blueberry;
    }

    // 🌸 Blossom - Swift, Mobile
    if (lang == 'swift' || lang == 'kotlin') {
      return PlantType.blossom;
    }

    // 🎋 Bamboo - Go, Node.js
    if (lang == 'go' || lang == 'golang' || lang.contains('node')) {
      return PlantType.bamboo;
    }

    // 🌳 Oak - C#, General, Others
    if (lang == 'c#' || lang == 'csharp' || lang == 'php' || lang == 'perl') {
      return PlantType.oak;
    }

    // 🍁 Maple - Ruby, HTML
    if (lang == 'ruby' ||
        lang == 'html' ||
        lang == 'css' ||
        lang == 'scss' ||
        lang == 'sass') {
      return PlantType.maple;
    }

    // 🌵 Cactus - Shell, Config, DevOps
    if (lang.contains('shell') ||
        lang == 'bash' ||
        lang == 'sh' ||
        lang == 'dockerfile' ||
        lang == 'makefile' ||
        lang == 'yaml' ||
        lang == 'json') {
      return PlantType.cactus;
    }

    // ✂️ Pine - Assembly, Embedded
    if (lang.contains('assembly') ||
        lang == 'asm' ||
        lang.contains('embedded') ||
        lang == 'verilog' ||
        lang == 'vhdl') {
      return PlantType.pine;
    }

    // 기타 언어는 참나무 (General)
    return PlantType.oak;
  }

  /// 식물 이름 (파일명 prefix)
  String get fileName {
    switch (this) {
      case PlantType.coffee:
        return 'coffee';
      case PlantType.ginkgo:
        return 'ginkgo';
      case PlantType.snakePlant:
        return 'snake_plant';
      case PlantType.fir:
        return 'fir';
      case PlantType.blossom:
        return 'blossom';
      case PlantType.bamboo:
        return 'bamboo';
      case PlantType.oak:
        return 'oak';
      case PlantType.maple:
        return 'maple';
      case PlantType.cactus:
        return 'cactus';
      case PlantType.blueberry:
        return 'blueberry';
      case PlantType.pine:
        return 'pine';
    }
  }

  /// 가문별 대표 색상 (테두리, 글로우)
  Color get primaryColor {
    switch (this) {
      case PlantType.coffee:
        return const Color(0xFF8B4513); // 커피 브라운
      case PlantType.ginkgo:
        return const Color(0xFFFDE047); // 은행 노란색 (JS 로고)
      case PlantType.snakePlant:
        return const Color(0xFF84CC16); // 뱀식물 라임 그린
      case PlantType.fir:
        return const Color(0xFF065F46); // 전나무 짙은 초록
      case PlantType.blossom:
        return const Color(0xFFF472B6); // 벚꽃 핑크
      case PlantType.bamboo:
        return const Color(0xFF86EFAC); // 대나무 연두
      case PlantType.oak:
        return const Color(0xFF78716C); // 참나무 갈색
      case PlantType.maple:
        return const Color(0xFFF87171); // 단풍 빨강
      case PlantType.cactus:
        return const Color(0xFF86A17A); // 선인장 초록
      case PlantType.blueberry:
        return const Color(0xFF6366F1); // 블루베리 인디고
      case PlantType.pine:
        return const Color(0xFF14532D); // 소나무 진한 초록
    }
  }

  /// 가문별 보조 색상 (그라데이션)
  Color get secondaryColor {
    switch (this) {
      case PlantType.coffee:
        return const Color(0xFF22C55E); // 커피 잎 초록
      case PlantType.ginkgo:
        return const Color(0xFFFBBF24); // 은행 골드
      case PlantType.snakePlant:
        return const Color(0xFFFDE047); // 뱀식물 노란 테두리
      case PlantType.fir:
        return const Color(0xFF064E3B); // 전나무 어두운 초록
      case PlantType.blossom:
        return const Color(0xFFFBCFE8); // 벚꽃 연분홍
      case PlantType.bamboo:
        return const Color(0xFF4ADE80); // 대나무 밝은 초록
      case PlantType.oak:
        return const Color(0xFF22C55E); // 참나무 잎 초록
      case PlantType.maple:
        return const Color(0xFFFB923C); // 단풍 주황
      case PlantType.cactus:
        return const Color(0xFFFDE047); // 선인장 노란 가시
      case PlantType.blueberry:
        return const Color(0xFFA5B4FC); // 블루베리 연보라
      case PlantType.pine:
        return const Color(0xFF166534); // 소나무 초록
    }
  }

  /// Get image asset path for specific growth stage using flutter_gen
  String getImagePath(TreeStage stage) {
    switch (stage) {
      case TreeStage.sprout:
        switch (this) {
          case PlantType.bamboo:
            return Assets.images.plants.sproutBambooDot.path;
          case PlantType.blossom:
            return Assets.images.plants.sproutBlossomDot.path;
          case PlantType.blueberry:
            return Assets.images.plants.sproutBlueberryDot.path;
          case PlantType.cactus:
            return Assets.images.plants.sproutCactusDot.path;
          case PlantType.coffee:
            return Assets.images.plants.sproutCoffeeDot.path;
          case PlantType.fir:
            return Assets.images.plants.sproutFirDot.path;
          case PlantType.ginkgo:
            return Assets.images.plants.sproutGinkgoDot.path;
          case PlantType.maple:
            return Assets.images.plants.sproutMapleDot.path;
          case PlantType.oak:
            return Assets.images.plants.sproutOakDot.path;
          case PlantType.pine:
            return Assets.images.plants.sproutPineDot.path;
          case PlantType.snakePlant:
            return Assets.images.plants.sproutSnakePlantDot.path;
        }
      case TreeStage.bloom:
        switch (this) {
          case PlantType.bamboo:
            return Assets.images.plants.flowerBambooDot.path;
          case PlantType.blossom:
            return Assets.images.plants.flowerBlossomDot.path;
          case PlantType.blueberry:
            return Assets.images.plants.flowerBlueberryDot.path;
          case PlantType.cactus:
            return Assets.images.plants.flowerCactusDot.path;
          case PlantType.coffee:
            return Assets.images.plants.flowerCoffeeDot.path;
          case PlantType.fir:
            return Assets.images.plants.flowerFirDot.path;
          case PlantType.ginkgo:
            return Assets.images.plants.flowerGinkgoDot.path;
          case PlantType.maple:
            return Assets.images.plants.flowerMapleDot.path;
          case PlantType.oak:
            return Assets.images.plants.flowerOakDot.path;
          case PlantType.pine:
            return Assets.images.plants.flowerPineDot.path;
          case PlantType.snakePlant:
            return Assets.images.plants.flowerSnakePlantDot.path;
        }
      case TreeStage.tree:
        switch (this) {
          case PlantType.bamboo:
            return Assets.images.plants.treeBambooDot.path;
          case PlantType.blossom:
            return Assets.images.plants.treeBlossomDot.path;
          case PlantType.blueberry:
            return Assets.images.plants.treeBlueberryDot.path;
          case PlantType.cactus:
            return Assets.images.plants.treeCactusDot.path;
          case PlantType.coffee:
            return Assets.images.plants.treeCoffeeDot.path;
          case PlantType.fir:
            return Assets.images.plants.treeFirDot.path;
          case PlantType.ginkgo:
            return Assets.images.plants.treeGinkgoDot.path;
          case PlantType.maple:
            return Assets.images.plants.treeMapleDot.path;
          case PlantType.oak:
            return Assets.images.plants.treeOakDot.path;
          case PlantType.pine:
            return Assets.images.plants.treePineDot.path;
          case PlantType.snakePlant:
            return Assets.images.plants.treeSnakePlantDot.path;
        }
    }
  }
}

/// 나무 성장 단계
enum TreeStage {
  /// 새싹 (score < 100)
  sprout(variantCount: 1),

  /// 꽃 (100 <= score < 300)
  bloom(variantCount: 4),

  /// 나무 (300 <= score)
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
