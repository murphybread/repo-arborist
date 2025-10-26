import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:template/features/github/models/github_user_model.dart';

/// GitHub User API와 통신하는 Repository
class GitHubUserRepository {
  static const _baseUrl = 'https://api.github.com';

  /// 인증된 사용자 정보 가져오기
  ///
  /// [token] GitHub Personal Access Token
  Future<GithubUserModel> getAuthenticatedUser({
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/user');
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
        'Failed to load user: ${response.statusCode} - ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return GithubUserModel.fromJson(data);
  }

  /// Username으로 공개 사용자 정보 가져오기
  ///
  /// [username] GitHub username (토큰 불필요, 공개 정보만 조회)
  Future<GithubUserModel> getUserByUsername({
    required String username,
  }) async {
    final url = Uri.parse('$_baseUrl/users/$username');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'User-Agent': 'Flutter-GitHub-Forest-App',
      },
    );

    if (response.statusCode == 403) {
      // Rate Limit 체크
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['message']?.toString().contains('rate limit') ?? false) {
        throw Exception(
          'GitHub API rate limit exceeded. Please wait a few minutes or use a GitHub token for higher limits.',
        );
      }
    }

    if (response.statusCode == 404) {
      throw Exception('User "$username" not found');
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load user: ${response.statusCode} - ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return GithubUserModel.fromJson(data);
  }
}
