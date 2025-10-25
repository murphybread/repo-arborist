import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:template/features/github/models/github_repository_model.dart';
import 'package:template/features/github/models/repository_stats_model.dart';

/// GitHub Repository API와 통신하는 Repository
class GitHubRepository {
  static const _baseUrl = 'https://api.github.com';

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

  /// Repository의 총 커밋 수 가져오기
  ///
  /// [token] GitHub Personal Access Token
  /// [owner] Repository 소유자
  /// [repo] Repository 이름
  Future<int> getRepositoryCommitCount({
    required String token,
    required String owner,
    required String repo,
  }) async {
    // GitHub API는 페이지네이션을 사용하므로, Link 헤더를 확인해야 합니다
    // 간단하게 하기 위해 첫 페이지만 가져오고 contributor stats를 사용합니다
    final url = Uri.parse('$_baseUrl/repos/$owner/$repo/stats/contributors');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );

    if (response.statusCode == 202) {
      // GitHub이 통계를 계산 중입니다. 잠시 후 다시 시도해야 합니다
      // 여기서는 0을 반환합니다
      return 0;
    }

    if (response.statusCode != 200) {
      // 에러가 발생하면 0을 반환합니다 (빈 레포일 수 있음)
      return 0;
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    var totalCommits = 0;
    for (final contributor in data) {
      totalCommits += contributor['total'] as int;
    }
    return totalCommits;
  }

  /// Repository의 머지된 PR 수 가져오기
  ///
  /// [token] GitHub Personal Access Token
  /// [owner] Repository 소유자
  /// [repo] Repository 이름
  Future<int> getRepositoryMergedPRCount({
    required String token,
    required String owner,
    required String repo,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/search/issues?q=repo:$owner/$repo+type:pr+is:merged&per_page=1',
    );
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );

    if (response.statusCode != 200) {
      // 에러가 발생하면 0을 반환합니다
      return 0;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['total_count'] as int;
  }

  /// Repository의 통계 정보 가져오기
  ///
  /// [token] GitHub Personal Access Token
  /// [repository] Repository 기본 정보
  Future<RepositoryStatsModel> getRepositoryStats({
    required String token,
    required GithubRepositoryModel repository,
  }) async {
    // full_name을 owner/repo로 분리
    final parts = repository.fullName.split('/');
    if (parts.length != 2) {
      throw Exception('Invalid repository full name: ${repository.fullName}');
    }
    final owner = parts[0];
    final repo = parts[1];

    // 병렬로 커밋 수와 PR 수 가져오기
    final results = await Future.wait([
      getRepositoryCommitCount(token: token, owner: owner, repo: repo),
      getRepositoryMergedPRCount(token: token, owner: owner, repo: repo),
    ]);

    return RepositoryStatsModel(
      repository: repository,
      totalCommits: results[0],
      totalMergedPRs: results[1],
    );
  }

  /// 모든 Repository의 통계 정보 가져오기
  ///
  /// [token] GitHub Personal Access Token
  Future<List<RepositoryStatsModel>> getAllRepositoryStats({
    required String token,
  }) async {
    final repositories = await getUserRepositories(token: token);

    // 병렬로 모든 레포의 통계 가져오기
    final statsFutures = repositories.map((repo) {
      return getRepositoryStats(token: token, repository: repo);
    }).toList();

    return Future.wait(statsFutures);
  }
}
