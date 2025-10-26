import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:template/features/github/models/commit_model.dart';
import 'package:template/features/github/models/github_repo_model.dart';
import 'package:template/features/github/models/github_repository_model.dart';
import 'package:template/features/github/models/pull_request_model.dart';
import 'package:template/features/github/models/repository_stats_model.dart';

/// GitHub Repository API와 통신하는 Repository
class GitHubRepository {
  static const _baseUrl = 'https://api.github.com';

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
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load repositories: ${response.statusCode} - ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((json) => GithubRepositoryModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Username으로 공개 Repository 가져오기
  ///
  /// [username] GitHub username (토큰 불필요, 공개 레포만 조회)
  Future<List<GithubRepositoryModel>> getPublicRepositoriesByUsername({
    required String username,
  }) async {
    final url = Uri.parse('$_baseUrl/users/$username/repos?per_page=100');
    final response = await http.get(
      url,
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load repositories: ${response.statusCode} - ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((json) => GithubRepositoryModel.fromJson(json as Map<String, dynamic>))
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
    // /commits API를 사용해서 커밋 수 가져오기
    // per_page=1로 설정하고 Link 헤더에서 마지막 페이지 번호를 확인합니다
    print('[GitHub API] Fetching commits for $owner/$repo');

    final url = Uri.parse('$_baseUrl/repos/$owner/$repo/commits?per_page=1');
    final response = await http.get(
      url,
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 409) {
      // 빈 레포지토리
      print('[GitHub API] Empty repository for $owner/$repo');
      return 0;
    }

    if (response.statusCode != 200) {
      // 에러가 발생하면 0을 반환합니다
      print('[GitHub API] Error ${response.statusCode} for $owner/$repo, returning 0');
      return 0;
    }

    // Link 헤더에서 마지막 페이지 번호를 추출합니다
    final linkHeader = response.headers['link'];
    if (linkHeader == null || !linkHeader.contains('rel="last"')) {
      // Link 헤더가 없으면 커밋이 1개 이하
      final data = jsonDecode(response.body) as List<dynamic>;
      final count = data.isEmpty ? 0 : 1;
      print('[GitHub API] $owner/$repo has $count commit(s) (no pagination)');
      return count;
    }

    // Link 헤더에서 마지막 페이지 번호 파싱
    // 예: <https://api.github.com/repos/owner/repo/commits?per_page=1&page=3500>; rel="last"
    final lastPageMatch = RegExp(r'page=(\d+)>; rel="last"').firstMatch(linkHeader);
    if (lastPageMatch != null) {
      final totalCommits = int.parse(lastPageMatch.group(1)!);
      print('[GitHub API] $owner/$repo has $totalCommits total commits');
      return totalCommits;
    }

    // 파싱 실패 시 1을 반환 (최소 1개는 있음)
    print('[GitHub API] Failed to parse Link header for $owner/$repo, returning 1');
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
    final url = Uri.parse(
      '$_baseUrl/search/issues?q=repo:$owner/$repo+type:pr+is:merged&per_page=1',
    );
    print('[GitHub API] Fetching merged PRs for $owner/$repo');
    final response = await http.get(
      url,
      headers: _getHeaders(token: token),
    );

    if (response.statusCode != 200) {
      // 에러가 발생하면 0을 반환합니다
      print('[GitHub API] Error ${response.statusCode} for $owner/$repo PRs, returning 0');
      return 0;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final count = data['total_count'] as int;
    print('[GitHub API] $owner/$repo has $count merged PRs');
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

    // 병렬로 커밋 수, PR 수, 최근 활동 가져오기
    final results = await Future.wait([
      getRepositoryCommitCount(token: token, owner: owner, repo: repo),
      getRepositoryMergedPRCount(token: token, owner: owner, repo: repo),
      getRecentCommits(token: token, owner: owner, repo: repo, limit: 1),
      getRecentMergedPRs(token: token, owner: owner, repo: repo, limit: 1),
    ]);

    final totalCommits = results[0] as int;
    final totalMergedPRs = results[1] as int;
    final recentCommits = results[2] as List<CommitModel>;
    final recentPRs = results[3] as List<PullRequestModel>;

    return RepositoryStatsModel(
      repository: repository,
      totalCommits: totalCommits,
      totalMergedPRs: totalMergedPRs,
      lastCommitDate: recentCommits.isNotEmpty ? recentCommits.first.date : null,
      lastMergedPRDate: recentPRs.isNotEmpty ? recentPRs.first.mergedAt : null,
    );
  }

  /// 모든 Repository의 통계 정보 가져오기
  ///
  /// [token] GitHub Personal Access Token (null인 경우 username 사용)
  /// [username] GitHub username (token이 null일 때 public repos만 조회)
  Future<List<RepositoryStatsModel>> getAllRepositoryStats({
    String? token,
    String? username,
  }) async {
    // token이 있으면 token 사용, 없으면 username 사용
    final List<GithubRepositoryModel> repositories;
    if (token != null) {
      repositories = await getUserRepositories(token: token);
    } else if (username != null) {
      repositories = await getPublicRepositoriesByUsername(username: username);
    } else {
      throw Exception('Either token or username must be provided');
    }

    // 병렬로 모든 레포의 통계 가져오기
    // token이 null이면 public API로 조회 (rate limit 주의)
    final statsFutures = repositories.map((repo) {
      return getRepositoryStats(token: token, repository: repo);
    }).toList();

    return Future.wait(statsFutures);
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
    final url = Uri.parse('$_baseUrl/repos/$owner/$repo/commits?per_page=$limit');
    final response = await http.get(
      url,
      headers: _getHeaders(token: token),
    );

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
    final url = Uri.parse(
      '$_baseUrl/repos/$owner/$repo/pulls?state=closed&sort=updated&direction=desc&per_page=$limit',
    );
    final response = await http.get(
      url,
      headers: _getHeaders(token: token),
    );

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
}
