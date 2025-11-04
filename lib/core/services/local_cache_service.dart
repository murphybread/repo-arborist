import 'package:hive_flutter/hive_flutter.dart';
import 'package:template/core/services/cache_service.dart';

/// 로컬 캐싱 서비스 (Hive 기반)
///
/// JSON 직렬화 가능한 데이터를 로컬에 캐싱합니다.
class LocalCacheService implements CacheService<Map<String, dynamic>> {
  static const _boxName = 'cache_box';
  static const _metaBoxName = 'cache_meta_box';

  Box? _cacheBox;
  Box? _metaBox;

  /// Hive 초기화 및 Box 열기
  Future<void> init() async {
    if (_cacheBox != null && _metaBox != null) {
      return; // 이미 초기화됨
    }

    await Hive.initFlutter();
    _cacheBox = await Hive.openBox(_boxName);
    _metaBox = await Hive.openBox(_metaBoxName);
  }

  /// Box가 열려있는지 확인하고 없으면 초기화
  Future<void> _ensureInitialized() async {
    if (_cacheBox == null || _metaBox == null) {
      await init();
    }
  }

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    await _ensureInitialized();

    // 만료 확인
    if (await isExpired(key)) {
      await delete(key);
      return null;
    }

    final data = _cacheBox!.get(key);
    if (data == null) {
      return null;
    }

    // Hive는 Map<dynamic, dynamic>으로 저장하므로 변환 필요
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  @override
  Future<void> set(
    String key,
    Map<String, dynamic> value, {
    Duration? ttl,
  }) async {
    await _ensureInitialized();

    // 데이터 저장
    await _cacheBox!.put(key, value);

    // TTL이 있으면 만료 시간 저장
    if (ttl != null) {
      final expiresAt = DateTime.now().add(ttl).millisecondsSinceEpoch;
      await _metaBox!.put('${key}_expires_at', expiresAt);
    } else {
      // TTL이 없으면 만료 시간 삭제
      await _metaBox!.delete('${key}_expires_at');
    }
  }

  @override
  Future<void> delete(String key) async {
    await _ensureInitialized();

    await _cacheBox!.delete(key);
    await _metaBox!.delete('${key}_expires_at');
  }

  @override
  Future<void> clear() async {
    await _ensureInitialized();

    await _cacheBox!.clear();
    await _metaBox!.clear();
  }

  @override
  Future<bool> isExpired(String key) async {
    await _ensureInitialized();

    final expiresAt = _metaBox!.get('${key}_expires_at');
    if (expiresAt == null) {
      // TTL이 설정되지 않은 경우 만료되지 않음
      return false;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    return now > expiresAt;
  }

  /// JSON으로 인코딩하여 저장
  ///
  /// [key] 캐시 키
  /// [data] 저장할 객체 (toJson() 메서드 필요)
  /// [ttl] Time To Live
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
  Future<void> setJsonList<T>(
    String key,
    List<T> dataList, {
    Duration? ttl,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    final jsonList = dataList.map(toJson).toList();
    await set(
      key,
      {'data': jsonList},
      ttl: ttl,
    );
  }

  /// JSON 리스트에서 디코딩하여 가져오기
  ///
  /// [key] 캐시 키
  /// [fromJson] JSON에서 객체로 변환하는 함수
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
