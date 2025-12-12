import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data like GitHub PAT
///
/// Uses platform-specific secure storage:
/// - Android: Android Keystore
/// - iOS: iOS Keychain
/// - macOS: macOS Keychain
/// - Windows: Windows Credential Manager
/// - Linux: Secret Service API
class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService _instance = SecureStorageService._();

  /// Get singleton instance
  static SecureStorageService get instance => _instance;

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Storage keys
  static const _keyGithubPAT = 'github_pat';
  static const _keyGithubUsername = 'github_username';

  /// Save GitHub PAT (encrypted)
  Future<void> saveGithubPAT(String token) async {
    try {
      await _storage.write(key: _keyGithubPAT, value: token);
      debugPrint('[SecureStorage] GitHub PAT saved successfully');
    } catch (e) {
      debugPrint('[SecureStorage] Failed to save PAT: $e');
      rethrow;
    }
  }

  /// Get GitHub PAT (decrypted)
  Future<String?> getGithubPAT() async {
    try {
      final token = await _storage.read(key: _keyGithubPAT);
      if (token != null) {
        debugPrint('[SecureStorage] GitHub PAT retrieved successfully');
      } else {
        debugPrint('[SecureStorage] No PAT found');
      }
      return token;
    } catch (e) {
      debugPrint('[SecureStorage] Failed to retrieve PAT: $e');
      return null;
    }
  }

  /// Delete GitHub PAT
  Future<void> deleteGithubPAT() async {
    try {
      await _storage.delete(key: _keyGithubPAT);
      debugPrint('[SecureStorage] GitHub PAT deleted successfully');
    } catch (e) {
      debugPrint('[SecureStorage] Failed to delete PAT: $e');
      rethrow;
    }
  }

  /// Check if PAT exists
  Future<bool> hasPAT() async {
    final token = await getGithubPAT();
    return token != null && token.isNotEmpty;
  }

  /// Save GitHub username
  Future<void> saveGithubUsername(String username) async {
    try {
      await _storage.write(key: _keyGithubUsername, value: username);
      debugPrint('[SecureStorage] GitHub username saved: $username');
    } catch (e) {
      debugPrint('[SecureStorage] Failed to save username: $e');
      rethrow;
    }
  }

  /// Get GitHub username
  Future<String?> getGithubUsername() async {
    try {
      return await _storage.read(key: _keyGithubUsername);
    } catch (e) {
      debugPrint('[SecureStorage] Failed to retrieve username: $e');
      return null;
    }
  }

  /// Delete GitHub username
  Future<void> deleteGithubUsername() async {
    try {
      await _storage.delete(key: _keyGithubUsername);
      debugPrint('[SecureStorage] GitHub username deleted');
    } catch (e) {
      debugPrint('[SecureStorage] Failed to delete username: $e');
      rethrow;
    }
  }

  /// Clear all GitHub data (PAT + username)
  Future<void> clearAllGithubData() async {
    try {
      await Future.wait([
        deleteGithubPAT(),
        deleteGithubUsername(),
      ]);
      debugPrint('[SecureStorage] All GitHub data cleared');
    } catch (e) {
      debugPrint('[SecureStorage] Failed to clear GitHub data: $e');
      rethrow;
    }
  }

  /// Get all stored data (for debugging only)
  Future<Map<String, String>> getAllData() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      debugPrint('[SecureStorage] Failed to read all data: $e');
      return {};
    }
  }
}
