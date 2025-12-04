import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:repo_arborist/core/services/cache_service.dart';

/// Firestore 기반 캐싱 서비스
///
/// JSON 직렬화 가능한 데이터를 Firestore에 캐싱합니다.
/// 로컬 캐시(Hive)와 달리 클라우드 저장소에 데이터를 보관하여
/// 여러 기기 간 동기화가 가능합니다.
class FirestoreCacheService implements CacheService<Map<String, dynamic>> {
  /// 싱글톤 인스턴스
  factory FirestoreCacheService() {
    return _instance;
  }

  FirestoreCacheService._internal();

  static final _instance = FirestoreCacheService._internal();

  /// Firestore 인스턴스 (Database ID: githubjson)
  FirebaseFirestore? _firestore;

  /// 캐시 컬렉션 이름
  static const String _collectionName = 'cache';

  /// Firestore 초기화 및 오프라인 지속성 설정
  Future<void> init() async {
    if (_firestore != null) {
      return; // 이미 초기화됨
    }

    try {
      _firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'githubjson',
      );

      // Windows/Desktop에서는 오프라인 지속성 비활성화
      // (mobile에서만 제대로 동작)
      _firestore!.settings = const Settings(
        persistenceEnabled: false,
      );

      debugPrint('[FirestoreCacheService] 초기화 완료 (오프라인 지속성: 비활성화)');
    } on Exception catch (e) {
      debugPrint('[FirestoreCacheService] 초기화 실패: $e');
      rethrow;
    }
  }

  /// Firestore가 초기화되었는지 확인
  Future<void> _ensureInitialized() async {
    if (_firestore == null) {
      await init();
    }
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    await _ensureInitialized();

    try {
      // 10초 타임아웃 설정
      final doc = await _firestore!
          .collection(_collectionName)
          .doc(key)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint(
                '[FirestoreCacheService] ⏱️ get 타임아웃 ($key) - 오프라인 상태일 수 있음',
              );
              throw Exception('Firestore get timeout');
            },
          );

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      if (data == null) {
        return null;
      }

      // 만료 확인 (문서를 이미 가져온 후에 체크)
      final expiresAt = data['expiresAt'] as Timestamp?;
      if (expiresAt != null) {
        final now = DateTime.now();
        if (now.isAfter(expiresAt.toDate())) {
          debugPrint('[FirestoreCacheService] ⏰ 캐시 만료됨 ($key) - 삭제 후 null 반환');
          // 백그라운드에서 삭제 (await 하지 않음 - fire-and-forget)
          delete(key).ignore();
          return null;
        }
      }

      // 'value' 필드에 실제 데이터가 저장되어 있음
      return data['value'] as Map<String, dynamic>?;
    } on Exception catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('unavailable') ||
          errorMessage.contains('offline') ||
          errorMessage.contains('timeout')) {
        debugPrint('[FirestoreCacheService] ⚠️ 오프라인/타임아웃 - 캐시 읽기 건너뜀');
      } else {
        debugPrint('[FirestoreCacheService] get 실패 ($key): $e');
      }
      return null;
    }
  }

  @override
  Future<void> set(
    String key,
    Map<String, dynamic> value, {
    Duration? ttl,
  }) async {
    await _ensureInitialized();

    try {
      final data = <String, dynamic>{
        'value': value,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // TTL이 있으면 만료 시간 저장
      if (ttl != null) {
        final expiresAt = DateTime.now().add(ttl);
        data['expiresAt'] = Timestamp.fromDate(expiresAt);
      }

      // 10초 타임아웃 설정
      await _firestore!
          .collection(_collectionName)
          .doc(key)
          .set(data)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint(
                '[FirestoreCacheService] ⏱️ set 타임아웃 ($key) - 오프라인 상태일 수 있음',
              );
              throw Exception('Firestore set timeout');
            },
          );

      debugPrint('[FirestoreCacheService] 캐시 저장: $key (TTL: $ttl)');
    } on Exception catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('unavailable') ||
          errorMessage.contains('offline') ||
          errorMessage.contains('timeout')) {
        debugPrint('[FirestoreCacheService] ⚠️ 오프라인/타임아웃 - 캐시 저장 건너뜀');
      } else {
        debugPrint('[FirestoreCacheService] set 실패 ($key): $e');
      }
      // 오프라인이어도 예외를 던지지 않음 (앱 계속 동작)
    }
  }

  @override
  Future<void> delete(String key) async {
    await _ensureInitialized();

    try {
      await _firestore!.collection(_collectionName).doc(key).delete();

      debugPrint('[FirestoreCacheService] 캐시 삭제: $key');
    } on Exception catch (e) {
      debugPrint('[FirestoreCacheService] delete 실패 ($key): $e');
    }
  }

  @override
  Future<void> clear() async {
    await _ensureInitialized();

    try {
      final batch = _firestore!.batch();
      final snapshot = await _firestore!.collection(_collectionName).get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      debugPrint('[FirestoreCacheService] 모든 캐시 삭제 (${snapshot.docs.length}개)');
    } on Exception catch (e) {
      debugPrint('[FirestoreCacheService] clear 실패: $e');
    }
  }

  @override
  Future<bool> isExpired(String key) async {
    await _ensureInitialized();

    try {
      // 10초 타임아웃 설정
      final doc = await _firestore!
          .collection(_collectionName)
          .doc(key)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint(
                '[FirestoreCacheService] ⏱️ isExpired 타임아웃 ($key) - 오프라인 상태일 수 있음',
              );
              throw Exception('Firestore isExpired timeout');
            },
          );

      if (!doc.exists) {
        return true;
      }

      final data = doc.data();
      if (data == null) {
        return true;
      }

      final expiresAt = data['expiresAt'] as Timestamp?;
      if (expiresAt == null) {
        // TTL이 설정되지 않은 경우 만료되지 않음
        return false;
      }

      final now = DateTime.now();
      return now.isAfter(expiresAt.toDate());
    } on Exception catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('unavailable') ||
          errorMessage.contains('offline')) {
        debugPrint('[FirestoreCacheService] ⚠️ 오프라인 상태 - 캐시를 만료된 것으로 처리');
      } else {
        debugPrint('[FirestoreCacheService] isExpired 실패 ($key): $e');
      }
      return true;
    }
  }

  /// JSON으로 인코딩하여 저장
  ///
  /// [key] 캐시 키
  /// [data] 저장할 객체 (toJson() 메서드 필요)
  /// [ttl] Time To Live
  @override
  Future<void> setJson<T>(
    String key,
    T data, {
    Duration? ttl,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    final json = toJson(data);
    await set(key, json, ttl: ttl);
  }

  /// JSON에서 디코딩하여 가져오기
  ///
  /// [key] 캐시 키
  /// [fromJson] JSON에서 객체로 변환하는 함수
  @override
  Future<T?> getJson<T>(
    String key, {
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final json = await get(key);
    if (json == null) {
      return null;
    }

    return fromJson(json);
  }

  /// JSON 리스트로 인코딩하여 저장
  ///
  /// [key] 캐시 키
  /// [dataList] 저장할 객체 리스트
  /// [ttl] Time To Live
  @override
  Future<void> setJsonList<T>(
    String key,
    List<T> dataList, {
    Duration? ttl,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    try {
      debugPrint('[FirestoreCacheService] 🔵 setJsonList 시작');
      debugPrint('   - key: $key');
      debugPrint('   - dataList.length: ${dataList.length}');
      debugPrint('   - ttl: $ttl');

      final jsonList = dataList.map(toJson).toList();

      debugPrint('[FirestoreCacheService] 🔵 JSON 변환 완료 (${jsonList.length}개)');

      await set(
        key,
        {'data': jsonList},
        ttl: ttl,
      );

      debugPrint('[FirestoreCacheService] ✅ setJsonList 완료');
    } on Exception catch (e, stack) {
      debugPrint('[FirestoreCacheService] ❌ setJsonList 실패: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  /// JSON 리스트에서 디코딩하여 가져오기
  ///
  /// [key] 캐시 키
  /// [fromJson] JSON에서 객체로 변환하는 함수
  @override
  Future<List<T>?> getJsonList<T>(
    String key, {
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final json = await get(key);
    if (json == null) {
      return null;
    }

    final dataList = json['data'] as List<dynamic>?;
    if (dataList == null) {
      return null;
    }

    return dataList
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
