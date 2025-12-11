import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:repo_arborist/core/services/cache_service.dart';
import 'package:repo_arborist/core/services/firestore_cache_service.dart';
import 'package:repo_arborist/core/services/local_cache_service.dart';
import 'package:repo_arborist/features/github/models/commit_model.dart';
import 'package:repo_arborist/features/github/models/contributor_model.dart';
import 'package:repo_arborist/features/github/models/github_repo_model.dart';
import 'package:repo_arborist/features/github/models/github_repository_model.dart';
import 'package:repo_arborist/features/github/models/pull_request_model.dart';
import 'package:repo_arborist/features/github/models/repository_stats_model.dart';

/// GitHub Repository API와 통신하는 Repository
class GitHubRepository {
  /// GitHubRepository 생성자
  ///
  /// [cacheService] 캐시 서비스 (기본값: LocalCacheService)
  /// [useFirestore] Firestore 캐시 사용 여부 (기본값: false)
  GitHubRepository({
    CacheService<Map<String, dynamic>>? cacheService,
    bool useFirestore = false,
  }) : _cacheService =
           cacheService ??
           (useFirestore ? FirestoreCacheService() : LocalCacheService());

  static const _baseUrl = 'https://api.github.com';
  static const _timeout = Duration(seconds: 30); // HTTP 요청 타임아웃
  static const _cacheDuration = Duration(hours: 24); // 캐시 유효 시간

  final CacheService<Map<String, dynamic>> _cacheService;

  /// Safely get GitHub token from .env (returns null if not initialized)
  String? _getEnvToken() {
    try {
      return kDebugMode ? dotenv.env['GITHUB_TOKEN'] : null;
    } catch (e) {
      debugPrint('[GitHubRepository] .env not initialized: $e');
      return null;
    }
  }

  /// API 요청 헤더 생성 (token이 있으면 포함, 없으면 public API 사용)
  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
      'User-Agent': 'Flutter-GitHub-Forest-App',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// 특정 Repository 정보 가져오기 (인증 없이)
  ///
  /// [owner] Repository 소유자
  /// [repo] Repository 이름
  Future<GithubRepoModel> getRepo({
    required String owner,
    required String repo,
  }) async {
    final url = Uri.parse('$_baseUrl/repos/$owner/$repo');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load repository: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return GithubRepoModel.fromJson(data);
  }

  /// 사용자의 모든 Repository 가져오기
  ///
  /// [token] GitHub Personal Access Token
  Future<List<GithubRepositoryModel>> getUserRepositories({
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/user/repos?per_page=100');
    final response = await http
        .get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load repositories: ${response.statusCode} - ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map(
          (json) =>
              GithubRepositoryModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Username으로 공개 Repository 가져오기
  ///
  /// [username] GitHub username
  /// [token] GitHub Personal Access Token (선택 사항, 있으면 5,000회/시간 제한 적용)
  Future<List<GithubRepositoryModel>> getPublicRepositoriesByUsername({
    required String username,
    String? token,
  }) async {
    // Production: Do not use fallback token for security reasons
    // Development: Load from .env for testing only
    final effectiveToken = token ?? _getEnvToken();

    debugPrint(
      '🟡 [getPublicRepos] 토큰: ${effectiveToken != null ? "사용 (${effectiveToken.substring(0, 10)}...)" : "미사용"}',
    );

    final url = Uri.parse('$_baseUrl/users/$username/repos?per_page=100');
    final response = await http
        .get(
          url,
          headers: _getHeaders(token: effectiveToken),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load repositories: ${response.statusCode} - ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map(
          (json) =>
              GithubRepositoryModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Repository의 총 커밋 수 가져오기
  ///
  /// [token] GitHub Personal Access Token (nullable)
  /// [owner] Repository 소유자
  /// [repo] Repository 이름
  Future<int> getRepositoryCommitCount({
    String? token,
    required String owner,
    required String repo,
  }) async {
    // Production: Do not use fallback token for security reasons
    final effectiveToken = token ?? _getEnvToken();

    // /commits API를 사용해서 커밋 수 가져오기
    // per_page=1로 설정하고 Link 헤더에서 마지막 페이지 번호를 확인합니다
    debugPrint('[GitHub API] Fetching commits for $owner/$repo');

    final url = Uri.parse('$_baseUrl/repos/$owner/$repo/commits?per_page=1');
    final response = await http
        .get(
          url,
          headers: _getHeaders(token: effectiveToken),
        )
        .timeout(_timeout);

    if (response.statusCode == 409) {
      // 빈 레포지토리
      debugPrint('[GitHub API] Empty repository for $owner/$repo');
      return 0;
    }

    if (response.statusCode != 200) {
      // 에러가 발생하면 0을 반환합니다
      debugPrint(
        '[GitHub API] Error ${response.statusCode} for $owner/$repo, returning 0',
      );
      return 0;
    }

    // Link 헤더에서 마지막 페이지 번호를 추출합니다
    final linkHeader = response.headers['link'];
    if (linkHeader == null || !linkHeader.contains('rel="last"')) {
      // Link 헤더가 없으면 커밋이 1개 이하
      final data = jsonDecode(response.body) as List<dynamic>;
      final count = data.isEmpty ? 0 : 1;
      debugPrint('[GitHub API] $owner/$repo has $count commit(s) (no pagination)');
      return count;
    }

    // Link 헤더에서 마지막 페이지 번호 파싱
    // 예: <https://api.github.com/repos/owner/repo/commits?per_page=1&page=3500>; rel="last"
    final lastPageMatch = RegExp(
      r'page=(\d+)>; rel="last"',
    ).firstMatch(linkHeader);
    if (lastPageMatch != null) {
      final totalCommits = int.parse(lastPageMatch.group(1)!);
      debugPrint('[GitHub API] $owner/$repo has $totalCommits total commits');
      return totalCommits;
    }

    // 파싱 실패 시 1을 반환 (최소 1개는 있음)
    debugPrint(
      '[GitHub API] Failed to parse Link header for $owner/$repo, returning 1',
    );
    return 1;
  }

  /// Repository의 머지된 PR 수 가져오기
  ///
  /// [token] GitHub Personal Access Token (nullable)
  /// [owner] Repository 소유자
  /// [repo] Repository 이름
  Future<int> getRepositoryMergedPRCount({
    String? token,
    required String owner,
    required String repo,
  }) async {
    // .env에서 토큰 자동 로드
    final effectiveToken = token ?? _getEnvToken();

    final url = Uri.parse(
      '$_baseUrl/search/issues?q=repo:$owner/$repo+type:pr+is:merged&per_page=1',
    );
    debugPrint('[GitHub API] Fetching merged PRs for $owner/$repo');
    final response = await http
        .get(
          url,
          headers: _getHeaders(token: effectiveToken),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      // 에러가 발생하면 0을 반환합니다
      debugPrint(
        '[GitHub API] Error ${response.statusCode} for $owner/$repo PRs, returning 0',
      );
      return 0;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final count = data['total_count'] as int;
    debugPrint('[GitHub API] $owner/$repo has $count merged PRs');
    return count;
  }

  /// Repository의 통계 정보 가져오기
  ///
  /// [token] GitHub Personal Access Token (nullable, 없으면 public API 사용)
  /// [repository] Repository 기본 정보
  Future<RepositoryStatsModel> getRepositoryStats({
    String? token,
    required GithubRepositoryModel repository,
  }) async {
    // full_name을 owner/repo로 분리
    final parts = repository.fullName.split('/');
    if (parts.length != 2) {
      throw Exception('Invalid repository full name: ${repository.fullName}');
    }
    final owner = parts[0];
    final repo = parts[1];

    // 병렬로 커밋 수, PR 수, 최근 PR만 가져오기
    // pushed_at을 사용하여 최근 커밋 날짜는 별도 API 호출 불필요
    final results = await Future.wait([
      getRepositoryCommitCount(token: token, owner: owner, repo: repo),
      getRepositoryMergedPRCount(token: token, owner: owner, repo: repo),
      getRecentMergedPRs(token: token, owner: owner, repo: repo, limit: 1),
    ]);

    final totalCommits = results[0] as int;
    final totalMergedPRs = results[1] as int;
    final recentPRs = results[2] as List<PullRequestModel>;

    return RepositoryStatsModel(
      repository: repository,
      totalCommits: totalCommits,
      totalMergedPRs: totalMergedPRs,
      lastCommitDate: repository.pushedAt, // pushed_at 활용
      lastMergedPRDate: recentPRs.isNotEmpty ? recentPRs.first.mergedAt : null,
    );
  }

  /// 모든 Repository의 통계 정보 가져오기
  ///
  /// [token] GitHub Personal Access Token (null인 경우 username 사용)
  /// [username] GitHub username (token이 null일 때 public repos만 조회)
  /// [forceRefresh] 캐시 무시하고 강제로 새로 가져오기
  Future<List<RepositoryStatsModel>> getAllRepositoryStats({
    String? token,
    String? username,
    bool forceRefresh = false,
  }) async {
    // .env에서 토큰 가져오기 (token 파라미터가 없을 때만)
    final effectiveToken = token ?? _getEnvToken();

    debugPrint('═══════════════════════════════════════');
    debugPrint('🔑 [GitHub API] 토큰 체크');
    debugPrint('   - 파라미터 token: ${token != null ? "있음" : "없음"}');
    debugPrint(
      '   - .env GITHUB_TOKEN: ${_getEnvToken() != null ? "있음 (Debug only)" : "없음"}',
    );
    debugPrint(
      '   - 최종 사용 토큰: ${effectiveToken != null ? '사용 (${effectiveToken.substring(0, 10)}...)' : '미사용'}',
    );
    debugPrint('═══════════════════════════════════════');

    // 캐시 키 생성
    final cacheKey = 'github_stats_${username ?? 'user'}';

    // 캐시 확인 (forceRefresh가 false일 때만)
    if (!forceRefresh) {
      try {
        // 5초 타임아웃 - Firestore가 응답 안 하면 빠르게 API로 전환
        final cachedStats = await _cacheService
            .getJsonList<RepositoryStatsModel>(
              cacheKey,
              fromJson: RepositoryStatsModel.fromJson,
            )
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                debugPrint('[Cache] ⏱️ 캐시 읽기 타임아웃 - API 호출로 전환');
                return null;
              },
            );

        if (cachedStats != null) {
          debugPrint('[Cache] ✅ 캐시에서 ${cachedStats.length}개 레포 통계 로드');
          return cachedStats;
        }
      } on Exception catch (e) {
        debugPrint('[Cache] ❌ 캐시 읽기 실패: $e - API 호출로 전환');
        // 캐시 실패해도 계속 진행
      }
    }

    // 캐시가 없거나 forceRefresh인 경우 API 호출
    debugPrint('[API] GitHub API에서 레포 통계 가져오는 중...');

    // username이 있으면 해당 사용자의 public repos 조회 (token이 있으면 함께 전달)
    // username이 없고 token만 있으면 내 repos 조회
    final List<GithubRepositoryModel> repositories;
    if (username != null) {
      // username이 있으면 해당 사용자의 public repos 조회
      // token이 있으면 5,000회/시간, 없으면 60회/시간
      repositories = await getPublicRepositoriesByUsername(
        username: username,
        token: effectiveToken,
      );
    } else if (effectiveToken != null) {
      // username이 없고 token만 있으면 내 repos 조회
      repositories = await getUserRepositories(token: effectiveToken);
    } else {
      throw Exception('Either token or username must be provided');
    }

    debugPrint('[GitHub API] 가져온 레포지토리 목록: ${repositories.length}개');

    // 병렬로 모든 레포의 통계 가져오기
    // token이 null이면 public API로 조회 (rate limit 주의)
    final statsFutures = repositories.map((repo) {
      return getRepositoryStats(token: effectiveToken, repository: repo);
    }).toList();

    final stats = await Future.wait(statsFutures);

    // 캐시에 저장
    debugPrint('[Cache] 🔵 캐시 저장 시작...');
    debugPrint('   - cacheKey: $cacheKey');
    debugPrint('   - stats.length: ${stats.length}');
    debugPrint('   - ttl: $_cacheDuration');
    debugPrint('   - cache service: ${_cacheService.runtimeType}');

    try {
      await _cacheService.setJsonList<RepositoryStatsModel>(
        cacheKey,
        stats,
        ttl: _cacheDuration,
        toJson: (stat) => stat.toJson(),
      );

      debugPrint('[Cache] ✅ ${stats.length}개 레포 통계를 캐시에 저장 완료');
    } on Exception catch (e, stack) {
      debugPrint('[Cache] ❌ 캐시 저장 실패: $e');
      debugPrint('Stack trace: $stack');
      // 캐시 저장 실패해도 데이터는 반환
    }

    return stats;
  }

  /// Repository의 최근 커밋 가져오기
  ///
  /// [token] GitHub Personal Access Token (nullable)
  /// [owner] Repository 소유자
  /// [repo] Repository 이름
  /// [limit] 가져올 커밋 개수 (기본값: 3)
  Future<List<CommitModel>> getRecentCommits({
    String? token,
    required String owner,
    required String repo,
    int limit = 3,
  }) async {
    // .env에서 토큰 자동 로드
    final effectiveToken = token ?? _getEnvToken();

    final url = Uri.parse(
      '$_baseUrl/repos/$owner/$repo/commits?per_page=$limit',
    );
    final response = await http
        .get(
          url,
          headers: _getHeaders(token: effectiveToken),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      // 에러 발생 시 빈 리스트 반환
      return [];
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((json) => CommitModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Repository의 최근 머지된 PR 가져오기
  ///
  /// [token] GitHub Personal Access Token (nullable)
  /// [owner] Repository 소유자
  /// [repo] Repository 이름
  /// [limit] 가져올 PR 개수 (기본값: 3)
  Future<List<PullRequestModel>> getRecentMergedPRs({
    String? token,
    required String owner,
    required String repo,
    int limit = 3,
  }) async {
    // .env에서 토큰 자동 로드
    final effectiveToken = token ?? _getEnvToken();

    final url = Uri.parse(
      '$_baseUrl/repos/$owner/$repo/pulls?state=closed&sort=updated&direction=desc&per_page=$limit',
    );
    final response = await http
        .get(
          url,
          headers: _getHeaders(token: effectiveToken),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      // 에러 발생 시 빈 리스트 반환
      return [];
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    // merged_at이 null이 아닌 것만 필터링 (실제로 머지된 PR만)
    return data
        .map((json) => PullRequestModel.fromJson(json as Map<String, dynamic>))
        .where((pr) => pr.mergedAt != null)
        .toList();
  }

  /// Repository의 컨트리뷰터 목록 가져오기
  ///
  /// [token] GitHub Personal Access Token (nullable)
  /// [owner] Repository 소유자
  /// [repo] Repository 이름
  /// [limit] 가져올 컨트리뷰터 수 (기본값: 30, 최대 100)
  Future<List<ContributorModel>> getContributors({
    String? token,
    required String owner,
    required String repo,
    int limit = 30,
  }) async {
    // .env에서 토큰 자동 로드
    final effectiveToken = token ?? _getEnvToken();

    // limit는 최대 100으로 제한
    final perPage = limit > 100 ? 100 : limit;

    final url = Uri.parse(
      '$_baseUrl/repos/$owner/$repo/contributors?per_page=$perPage',
    );
    debugPrint('[GitHub API] Fetching contributors for $owner/$repo');

    final response = await http
        .get(
          url,
          headers: _getHeaders(token: effectiveToken),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      // 에러 발생 시 빈 리스트 반환
      debugPrint(
        '[GitHub API] Error ${response.statusCode} for $owner/$repo contributors, returning empty list',
      );
      return [];
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    final contributors = data
        .map((json) => ContributorModel.fromJson(json as Map<String, dynamic>))
        .toList();

    debugPrint('[GitHub API] $owner/$repo has ${contributors.length} contributors');
    return contributors;
  }
}
