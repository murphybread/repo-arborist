import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template/features/github/models/repository_stats_model.dart';
import 'package:template/features/github/repositories/github_repository.dart';

/// Forest 데이터를 관리하는 Provider
final forestProvider =
    AsyncNotifierProvider<ForestController, List<RepositoryStatsModel>>(
      ForestController.new,
    );

/// Forest Controller - Repository 통계를 관리
class ForestController extends AsyncNotifier<List<RepositoryStatsModel>> {
  // ✅ Firestore 캐시 사용 중 (클라우드 저장)
  // 로컬 캐시로 변경하려면: GitHubRepository() 또는 GitHubRepository(useFirestore: false)
  final _repository = GitHubRepository(useFirestore: true);

  @override
  Future<List<RepositoryStatsModel>> build() async {
    // 초기 상태는 빈 리스트
    return [];
  }

  /// GitHub Token 또는 Username으로 모든 Repository 통계 가져오기
  /// [token]이 있으면 private repos 포함, 없으면 [username]의 public repos만 조회
  /// [forceRefresh] 캐시 무시하고 강제로 새로 가져오기
  Future<void> loadRepositoryStats({
    String? token,
    String? username,
    bool forceRefresh = false,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return _repository.getAllRepositoryStats(
        token: token,
        username: username,
        forceRefresh: forceRefresh,
      );
    });
  }

  /// 새로고침 (강제로 캐시 무시)
  Future<void> refresh({String? token, String? username}) async {
    await loadRepositoryStats(
      token: token,
      username: username,
      forceRefresh: true,
    );
  }
}
