import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/github/models/github_user_model.dart';
import 'package:template/features/github/repositories/github_user_repository.dart';

/// GitHub 인증 상태를 관리하는 Provider
final githubAuthProvider =
    AsyncNotifierProvider<GitHubAuthController, GithubUserModel?>(
  GitHubAuthController.new,
);

/// GitHub 인증을 관리하는 Controller
class GitHubAuthController extends AsyncNotifier<GithubUserModel?> {
  final _repository = GitHubUserRepository();

  @override
  Future<GithubUserModel?> build() async {
    // 초기 상태는 null (로그인하지 않음)
    return null;
  }

  /// GitHub Token으로 사용자 정보 가져오기
  Future<void> authenticateWithToken(String token) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return _repository.getAuthenticatedUser(token: token);
    });
  }

  /// 로그아웃
  void signOut() {
    state = const AsyncData(null);
  }
}
