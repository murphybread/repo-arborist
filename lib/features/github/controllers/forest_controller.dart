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
  final _repository = GitHubRepository();

  @override
  Future<List<RepositoryStatsModel>> build() async {
    // 초기 상태는 빈 리스트
    return [];
  }

  /// GitHub Token으로 모든 Repository 통계 가져오기
  Future<void> loadRepositoryStats(String token) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return _repository.getAllRepositoryStats(token: token);
    });
  }

  /// 새로고침
  Future<void> refresh(String token) async {
    await loadRepositoryStats(token);
  }
}
