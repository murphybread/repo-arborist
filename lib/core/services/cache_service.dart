/// 캐싱 서비스 인터페이스
///
/// 로컬 캐싱과 Firebase 캐싱을 동일한 인터페이스로 사용 가능
abstract class CacheService<T> {
  /// 캐시에서 데이터 가져오기
  ///
  /// [key] 캐시 키
  /// 캐시가 없거나 만료된 경우 null 반환
  Future<T?> get(String key);

  /// 캐시에 데이터 저장
  ///
  /// [key] 캐시 키
  /// [value] 저장할 데이터
  /// [ttl] Time To Live (캐시 유효 시간, 선택 사항)
  Future<void> set(String key, T value, {Duration? ttl});

  /// 특정 키의 캐시 삭제
  ///
  /// [key] 삭제할 캐시 키
  Future<void> delete(String key);

  /// 모든 캐시 삭제
  Future<void> clear();

  /// 캐시가 만료되었는지 확인
  ///
  /// [key] 확인할 캐시 키
  /// 만료되었거나 없으면 true 반환
  Future<bool> isExpired(String key);

  /// JSON으로 인코딩하여 저장
  ///
  /// [key] 캐시 키
  /// [data] 저장할 객체 (toJson() 메서드 필요)
  /// [ttl] Time To Live
  Future<void> setJson<TData>(
    String key,
    TData data, {
    Duration? ttl,
    required Map<String, dynamic> Function(TData) toJson,
  });

  /// JSON에서 디코딩하여 가져오기
  ///
  /// [key] 캐시 키
  /// [fromJson] JSON에서 객체로 변환하는 함수
  Future<TData?> getJson<TData>(
    String key, {
    required TData Function(Map<String, dynamic>) fromJson,
  });

  /// JSON 리스트로 인코딩하여 저장
  ///
  /// [key] 캐시 키
  /// [dataList] 저장할 객체 리스트
  /// [ttl] Time To Live
  Future<void> setJsonList<TData>(
    String key,
    List<TData> dataList, {
    Duration? ttl,
    required Map<String, dynamic> Function(TData) toJson,
  });

  /// JSON 리스트에서 디코딩하여 가져오기
  ///
  /// [key] 캐시 키
  /// [fromJson] JSON에서 객체로 변환하는 함수
  Future<List<TData>?> getJsonList<TData>(
    String key, {
    required TData Function(Map<String, dynamic>) fromJson,
  });
}
