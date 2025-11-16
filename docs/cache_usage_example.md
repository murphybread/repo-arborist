# Firestore 캐시 사용 가이드

Firestore를 활용한 클라우드 캐시 저장소 사용 방법을 설명합니다.

## 1. Firestore 캐시 활성화

### setup.dart에서 활성화

```dart
class AppSetup {
  static const enableFirebase = true;
  static const enableFirestoreCache = true;  // ← 이 값을 true로 변경
}
```

## 2. GitHubRepository에서 Firestore 캐시 사용

### 방법 1: 생성자에서 useFirestore 파라미터 사용

```dart
// Firestore 캐시 사용
final repository = GitHubRepository(useFirestore: true);

// 로컬 캐시 사용 (기본값)
final repository = GitHubRepository();
```

### 방법 2: FirestoreCacheService 직접 전달

```dart
final firestoreCache = FirestoreCacheService();
await firestoreCache.init();

final repository = GitHubRepository(cacheService: firestoreCache);
```

## 3. 사용 예시

### GitHub 사용자 데이터 Firestore에 캐싱

```dart
// Controller에서 사용
class GitHubController extends AsyncNotifier<List<RepositoryStatsModel>> {
  // Firestore 캐시를 사용하는 Repository 생성
  final _repository = GitHubRepository(useFirestore: true);

  @override
  Future<List<RepositoryStatsModel>> build() async {
    // 첫 번째 호출: API에서 가져와서 Firestore에 저장
    // 두 번째 호출: Firestore 캐시에서 가져옴
    return await _repository.getAllRepositoryStats(
      username: 'your-username',
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // forceRefresh: true로 캐시 무시하고 새로 가져오기
      return await _repository.getAllRepositoryStats(
        username: 'your-username',
        forceRefresh: true,
      );
    });
  }
}
```

## 4. Firestore vs 로컬 캐시 (Hive) 비교

| 기능 | Firestore 캐시 | 로컬 캐시 (Hive) |
|------|----------------|------------------|
| **저장 위치** | 클라우드 (Firebase) | 로컬 기기 |
| **동기화** | 여러 기기 간 동기화 가능 | 기기별로 독립적 |
| **오프라인 지원** | ✅ (자동 로컬 캐싱) | ✅ |
| **속도** | 중간 (네트워크 필요) | ⚡ 매우 빠름 |
| **비용** | 💰 Firebase 요금제에 따름 | 무료 |
| **용량 제한** | Firebase 무료: 1GB | 기기 저장소 한도 |
| **사용 예시** | 여러 기기에서 사용하는 사용자 데이터 | 임시 데이터, 캐시 |

## 5. Firestore 콘솔에서 확인하기

1. [Firebase Console](https://console.firebase.google.com) 접속
2. 프로젝트 선택 (`chickentone-a0f5c`)
3. Firestore Database 메뉴 선택
4. `cache` 컬렉션에서 저장된 데이터 확인

### 저장된 데이터 구조

```json
{
  "value": {
    "data": [
      {
        "repository": { ... },
        "totalCommits": 100,
        "totalMergedPRs": 20,
        ...
      }
    ]
  },
  "createdAt": "2025-01-12T10:30:00Z",
  "expiresAt": "2025-01-12T11:30:00Z"  // TTL: 1시간
}
```

## 6. 권장 사용 시나리오

### Firestore 캐시를 사용하세요 ✅

- 여러 기기에서 동일한 사용자 데이터 공유
- 팀원 간 데이터 공유
- 사용자 프로필, 설정 등 중요한 데이터
- 클라우드 백업이 필요한 데이터

### 로컬 캐시를 사용하세요 ✅

- 임시 데이터, API 응답 캐싱
- 빠른 속도가 필요한 경우
- Firebase 비용을 절약하고 싶은 경우
- 개인정보 보호가 중요한 경우 (로컬에만 저장)

## 7. 주의사항

### Firestore 보안 규칙 설정 필요

현재는 테스트 모드로 설정되어 있습니다. 프로덕션 환경에서는 보안 규칙을 설정해야 합니다:

```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 인증된 사용자만 자신의 캐시 접근 가능
    match /cache/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 캐시 키 충돌 방지

사용자별로 다른 캐시 키를 사용하세요:

```dart
// ❌ BAD: 모든 사용자가 같은 키 사용
final cacheKey = 'github_stats';

// ✅ GOOD: 사용자별 캐시 키
final cacheKey = 'github_stats_$username';
```

## 8. 캐시 삭제

```dart
final firestoreCache = FirestoreCacheService();
await firestoreCache.init();

// 특정 캐시 삭제
await firestoreCache.delete('github_stats_username');

// 모든 캐시 삭제
await firestoreCache.clear();
```
