# Firestore 비용 제어 가이드

## 📊 Blaze Plan 무료 한도

### 매일 제공되는 무료 할당량

| 항목 | 무료 한도 | 초과 시 비용 |
|------|-----------|-------------|
| 저장 용량 | 1 GB | $0.18/GB/월 |
| 문서 읽기 | 50,000회/일 | $0.06/10만회 |
| 문서 쓰기 | 20,000회/일 | $0.18/10만회 |
| 문서 삭제 | 20,000회/일 | $0.02/10만회 |
| 네트워크 전송 | 10 GB/월 | $0.12/GB |

## 🛡️ Security Rules로 제한하기

### 1. 읽기/쓰기 횟수 제한

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /cache/{userId}/{document} {
      // 인증된 사용자만 접근
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // 문서 크기 제한 (1MB)
      allow write: if request.resource.size() < 1024 * 1024;
    }
  }
}
```

### 2. 사용자별 문서 개수 제한

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /cache/{userId}/{document} {
      // 사용자당 최대 100개 문서
      allow create: if request.auth.uid == userId
        && getAfter(/databases/$(database)/documents/cache/$(userId)).size() <= 100;
    }
  }
}
```

### 3. 시간당 요청 제한 (간단 버전)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 메타데이터 저장
    match /rate_limit/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    match /cache/{userId}/{document} {
      allow read: if request.auth.uid == userId
        && get(/databases/$(database)/documents/rate_limit/$(userId)).data.hourlyReads < 1000;
    }
  }
}
```

## 💰 예산 알림 설정

### Firebase Console 예산 설정

1. **Firebase Console 접속**
   - https://console.firebase.google.com/project/chickentone-a0f5c

2. **프로젝트 설정 → Billing**
   - "예산 및 알림" 클릭

3. **예산 생성**
   ```
   예산 이름: Firebase Monthly Budget
   금액: $1 (또는 원하는 금액)
   알림 임계값: 50%, 90%, 100%
   알림 이메일: 본인 이메일
   ```

### Google Cloud Console 예산 (고급)

1. **Google Cloud Console 접속**
   - https://console.cloud.google.com/billing/budgets

2. **예산 만들기**
   - 프로젝트: `chickentone-a0f5c`
   - 금액: $1
   - 임계값: 50%, 90%, 100%

3. **Cloud Functions로 자동 중단 (선택)**
   ```javascript
   // Cloud Function으로 예산 초과 시 Firestore 비활성화
   exports.stopBilling = functions.pubsub
     .topic('billing')
     .onPublish((message) => {
       // 예산 초과 시 Firestore 규칙 변경
       // (모든 접근 차단)
     });
   ```

## 📈 사용량 모니터링

### Firebase Console에서 확인

**경로**: Firestore Database → Usage 탭

```
실시간 모니터링:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 읽기: 1,234 / 50,000 (2.5%)
✍️ 쓰기: 89 / 20,000 (0.4%)
💾 저장: 45 MB / 1 GB (4.5%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 💡 비용 절약 팁

### 1. 캐시 TTL 늘리기

```dart
// 현재: 1시간
static const _cacheDuration = Duration(hours: 1);

// 절약: 24시간
static const _cacheDuration = Duration(hours: 24);
```

### 2. 로컬 캐시 우선 사용

```dart
// Firestore는 백업용으로만 사용
final _localCache = LocalCacheService();
final _firestoreCache = FirestoreCacheService();

Future<Data?> getData(String key) async {
  // 1. 로컬 캐시 확인
  var data = await _localCache.get(key);
  if (data != null) return data;

  // 2. Firestore 확인 (백업)
  data = await _firestoreCache.get(key);
  if (data != null) {
    // 로컬에 저장
    await _localCache.set(key, data);
  }

  return data;
}
```

### 3. 불필요한 읽기/쓰기 최소화

```dart
// ❌ BAD: 매번 Firestore 조회
for (var i = 0; i < 100; i++) {
  final data = await firestore.collection('cache').doc('key_$i').get();
}

// ✅ GOOD: 한 번에 조회
final snapshot = await firestore.collection('cache').get();
```

## 🚨 예산 초과 시 대응

### 자동 알림 받으면:

1. **사용량 확인**
   - Firebase Console → Usage 탭
   - 어떤 작업이 많은지 확인

2. **Security Rules 강화**
   - 읽기/쓰기 제한 추가
   - 문서 크기 제한

3. **캐시 전략 변경**
   - TTL 늘리기
   - 로컬 캐시 우선 사용

4. **긴급 대응**
   - Firestore 비활성화
   - 로컬 캐시만 사용

## 📌 권장 설정 (개인 프로젝트)

```
예산: $1/월
알림: 50%, 90%, 100%
Security Rules: 사용자 인증 필수
캐시 TTL: 24시간
백업: 로컬 캐시 우선
```

이 설정으로 거의 무료로 사용 가능합니다!
