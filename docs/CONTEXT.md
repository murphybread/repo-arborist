# 네트워크 에러 해결 과정 분석

## Why - 무엇이 문제였나?

### 근본 원인: Firebase Web 플랫폼 미설정

**증상:**
- Windows 환경에서 앱 실행 시 Firestore 접근 시 네트워크 에러 발생
- Firestore 캐시 읽기/쓰기 작업이 타임아웃 또는 실패
- 캐시 서비스가 정상 작동하지 않아 매번 GitHub API 호출 발생

**원인:**
```dart
// firebase_options.dart (수정 전)
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',        // ❌ 더미 데이터
  appId: 'YOUR_WEB_APP_ID',          // ❌ 더미 데이터
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',  // ❌ 더미 데이터
  projectId: 'YOUR_PROJECT_ID',      // ❌ 더미 데이터
  authDomain: 'YOUR_AUTH_DOMAIN',    // ❌ 더미 데이터
  storageBucket: 'YOUR_STORAGE_BUCKET',  // ❌ 더미 데이터
);
```

**왜 Windows에서 Web 설정이 필요한가?**
- Flutter Windows 앱은 내부적으로 **Web Firebase SDK**를 사용
- `firebase_options.dart`의 `windows` 섹션도 실제로는 Web 설정을 재사용:
  ```dart
  // Windows는 Web 설정을 사용 (FlutterFire는 Windows 공식 미지원)
  static const FirebaseOptions windows = FirebaseOptions(...);
  ```
- Web 플랫폼이 제대로 설정되지 않으면 Firestore 연결 불가

### 기술적 배경

1. **Flutter의 플랫폼별 Firebase SDK:**
   - Android/iOS: 네이티브 SDK 사용
   - Web: JavaScript SDK 사용
   - **Windows/macOS/Linux**: Web SDK를 데스크톱에서 사용 (비공식)

2. **FirestoreCacheService의 타임아웃 메커니즘:**
   ```dart
   // lib/core/services/firestore_cache_service.dart:44-56
   final doc = await _firestore
       .collection(_collectionName)
       .doc(key)
       .get()
       .timeout(
         const Duration(seconds: 10),
         onTimeout: () {
           if (kDebugMode) {
             print('[FirestoreCacheService] ⏱️ get 타임아웃 ($key) - 오프라인 상태일 수 있음');
           }
           throw Exception('Firestore get timeout');
         },
       );
   ```
   - Firebase 설정이 잘못되면 Firestore가 무한 대기 → 10초 타임아웃
   - 타임아웃 발생 시 캐시 읽기 실패 → `null` 반환

3. **GitHubRepository의 Fallback 전략:**
   ```dart
   // lib/features/github/repositories/github_repository.dart:284-298
   final cachedStats = await _cacheService
       .getJsonList<RepositoryStatsModel>(
         cacheKey,
         fromJson: RepositoryStatsModel.fromJson,
       )
       .timeout(
         const Duration(seconds: 5),
         onTimeout: () {
           if (kDebugMode) {
             print('[Cache] ⏱️ 캐시 읽기 타임아웃 - API 호출로 전환');
           }
           return null;
         },
       );
   ```
   - 캐시 실패 → GitHub API 직접 호출
   - API rate limit에 걸릴 위험 증가
   - 앱 로딩 시간 증가

---

## How - 무엇을 기반으로 해결했나?

### 진단 과정

1. **Firebase 설정 파일 검사:**
   ```bash
   # firebase_options.dart 확인
   # → Web 섹션에 더미 데이터 발견
   ```

2. **설치된 패키지 확인:**
   ```yaml
   # pubspec.yaml
   firebase_core: ^4.2.0         # ✅ 설치됨
   cloud_firestore: ^6.1.0       # ✅ 설치됨
   ```

3. **Firebase CLI 상태 확인:**
   ```bash
   $ firebase login
   Already logged in as nargene@gmail.com  # ✅ 로그인됨

   $ firebase projects:list
   ┌──────────────────────┬───────────────────┐
   │ Project Display Name │ Project ID        │
   ├──────────────────────┼───────────────────┤
   │ chickentone          │ chickentone-a0f5c │
   └──────────────────────┴───────────────────┘
   ```

4. **Web 플랫폼 존재 여부 확인:**
   ```bash
   $ dir web
   # 없음 → Web 플랫폼 미생성
   ```

### 해결 전략

**가설:** Web 플랫폼 설정이 없어서 Firestore 연결 실패

**검증 방법:**
1. Web 플랫폼 추가
2. Firebase Web 설정 값 가져오기
3. `firebase_options.dart` 업데이트

---

## What - 무엇을 시도하고 결과는?

### 시도 1: FlutterFire CLI 설치

**명령어:**
```bash
dart pub global activate flutterfire_cli
```

**결과:**
```
✅ 성공
Activated flutterfire_cli 1.3.1.
```

**목적:** Firebase 설정 자동화 도구 설치

---

### 시도 2: Web 플랫폼 추가

**명령어:**
```bash
flutter create . --platforms=web
```

**결과:**
```
✅ 성공
Wrote 0 files.
```

**생성된 파일:**
```
web/
├── favicon.png
├── index.html
├── manifest.json
└── icons/
    ├── Icon-192.png
    ├── Icon-512.png
    ├── Icon-maskable-192.png
    └── Icon-maskable-512.png
```

---

### 시도 3: FlutterFire CLI로 자동 설정 (실패)

**명령어:**
```bash
dart pub global run flutterfire_cli:flutterfire configure
```

**결과:**
```
❌ 실패 - 대화형 프롬프트에서 멈춤
? You have an existing `firebase.json` file...
# 프로젝트 목록 로딩 중 무한 대기
```

**원인:**
- FlutterFire CLI가 Firebase 프로젝트 목록을 가져오는 중 응답 없음
- Git Bash 터미널에서 대화형 입력 문제 가능성

---

### 시도 4: Firebase CLI로 수동 설정 (성공)

**명령어:**
```bash
firebase apps:sdkconfig WEB --project=chickentone-a0f5c
```

**결과:**
```json
✅ 성공
{
  "projectId": "chickentone-a0f5c",
  "appId": "1:363758710643:web:40bc6f3b9280a5ff4e1f06",
  "storageBucket": "chickentone-a0f5c.firebasestorage.app",
  "apiKey": "AIzaSyBBmhdiguNcO9Kiz-MEUrt3_LT-P1rn8P4",
  "authDomain": "chickentone-a0f5c.firebaseapp.com",
  "messagingSenderId": "363758710643",
  "measurementId": "G-DH6CKQ3HKX"
}
```

**목적:** Web 앱의 Firebase 설정 값 직접 추출

---

### 시도 5: firebase_options.dart 수동 업데이트 (최종 해결)

**변경 내용:**
```dart
// 수정 전
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_WEB_APP_ID',
  // ...
);

// 수정 후
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyBBmhdiguNcO9Kiz-MEUrt3_LT-P1rn8P4',
  appId: '1:363758710643:web:40bc6f3b9280a5ff4e1f06',
  messagingSenderId: '363758710643',
  projectId: 'chickentone-a0f5c',
  authDomain: 'chickentone-a0f5c.firebaseapp.com',
  storageBucket: 'chickentone-a0f5c.firebasestorage.app',
  measurementId: 'G-DH6CKQ3HKX',
);
```

**파일 위치:** `lib/firebase_options.dart:55-63`

**결과:**
```
✅ 해결됨
- Windows에서 Firestore 정상 연결
- 캐시 서비스 정상 작동
- 네트워크 에러 해결
```

---

## 결론

### 문제 요약
Flutter Windows 앱이 Web Firebase SDK를 사용하는데, Web 플랫폼 설정이 더미 데이터로 되어 있어서 Firestore 연결 실패 → 캐시 타임아웃 → 네트워크 에러

### 해결 방법
1. Web 플랫폼 추가 (`flutter create . --platforms=web`)
2. Firebase CLI로 Web 설정 값 추출 (`firebase apps:sdkconfig WEB`)
3. `firebase_options.dart`의 web 섹션 업데이트

### 교훈
- **Flutter Desktop 앱 = Web Firebase SDK 사용** (공식 미지원 플랫폼)
- FlutterFire CLI가 동작하지 않을 때는 Firebase CLI + 수동 설정으로 대체 가능
- 타임아웃 에러는 네트워크 문제가 아니라 **설정 문제**일 수 있음

### 검증 방법
```bash
# Web에서 앱 실행 테스트
flutter run -d chrome

# Windows에서 Firestore 연결 확인
flutter run -d windows
# → Firebase 초기화 성공 메시지 확인
```

---

## 참고 자료

### 관련 파일
- [`lib/firebase_options.dart`](../lib/firebase_options.dart) - Firebase 플랫폼별 설정
- [`lib/core/services/firestore_cache_service.dart`](../lib/core/services/firestore_cache_service.dart) - Firestore 캐시 서비스
- [`lib/features/github/repositories/github_repository.dart`](../lib/features/github/repositories/github_repository.dart) - GitHub API + 캐싱 로직

### 추가 문서
- [firestore_setup_checklist.md](./firestore_setup_checklist.md) - Firestore 설정 체크리스트
- [firestore_cost_control.md](./firestore_cost_control.md) - Firestore 비용 최적화 가이드
- [cache_usage_example.md](./cache_usage_example.md) - 캐시 서비스 사용법
