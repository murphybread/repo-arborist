import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_arborist/core/services/secure_storage_service.dart';

/// GitHub PAT state model
class GitHubPATState {
  /// Constructor
  const GitHubPATState({
    required this.isRegistered,
    this.token,
    this.username,
  });

  /// Whether PAT is registered
  final bool isRegistered;

  /// GitHub PAT token
  final String? token;

  /// GitHub username
  final String? username;

  /// Copy with method
  GitHubPATState copyWith({
    bool? isRegistered,
    String? token,
    String? username,
  }) {
    return GitHubPATState(
      isRegistered: isRegistered ?? this.isRegistered,
      token: token ?? this.token,
      username: username ?? this.username,
    );
  }
}

/// GitHub PAT controller provider
final githubPATProvider = NotifierProvider<GitHubPATController, GitHubPATState>(
  GitHubPATController.new,
);

/// GitHub PAT controller
class GitHubPATController extends Notifier<GitHubPATState> {
  final SecureStorageService _storage = SecureStorageService.instance;

  @override
  GitHubPATState build() {
    // Load PAT asynchronously
    _loadPAT();
    return const GitHubPATState(isRegistered: false);
  }

  /// Load PAT from secure storage
  Future<void> _loadPAT() async {
    try {
      final token = await _storage.getGithubPAT();
      final username = await _storage.getGithubUsername();

      if (token != null && token.isNotEmpty) {
        state = GitHubPATState(
          isRegistered: true,
          token: token,
          username: username,
        );
        debugPrint('[PAT Controller] PAT loaded successfully');
        debugPrint('[PAT Controller] Username: $username');
      } else {
        debugPrint('[PAT Controller] No PAT found');
      }
    } on Exception catch (e) {
      debugPrint('[PAT Controller] Failed to load PAT: $e');
    }
  }

  /// Register new PAT
  Future<bool> registerPAT(String token, {String? username}) async {
    try {
      debugPrint('[PAT Controller] Registering new PAT...');

      // Save PAT
      await _storage.saveGithubPAT(token);

      // Save username if provided
      if (username != null && username.isNotEmpty) {
        await _storage.saveGithubUsername(username);
      }

      // Update state
      state = GitHubPATState(
        isRegistered: true,
        token: token,
        username: username,
      );

      debugPrint('[PAT Controller] PAT registered successfully');
      return true;
    } on Exception catch (e) {
      debugPrint('[PAT Controller] Failed to register PAT: $e');
      return false;
    }
  }

  /// Delete PAT (logout)
  Future<bool> deletePAT() async {
    try {
      debugPrint('[PAT Controller] Deleting PAT...');

      await _storage.clearAllGithubData();

      state = const GitHubPATState(isRegistered: false);

      debugPrint('[PAT Controller] PAT deleted successfully');
      return true;
    } on Exception catch (e) {
      debugPrint('[PAT Controller] Failed to delete PAT: $e');
      return false;
    }
  }

  /// Reload PAT from storage
  Future<void> reload() async {
    await _loadPAT();
  }

  /// Check if PAT is registered
  bool get isRegistered => state.isRegistered;

  /// Get current token
  String? get token => state.token;

  /// Get current username
  String? get username => state.username;
}
