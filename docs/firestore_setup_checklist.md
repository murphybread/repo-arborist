# Firestore 설정 체크리스트

## ✅ Billing 활성화 후 확인사항

### 1. Billing Account 연결 확인

**링크**: https://console.cloud.google.com/billing?project=chickentone-a0f5c

```
☑️ Billing Account가 프로젝트에 연결됨
☑️ 상태: Active
☑️ 결제 방법: 카드 등록됨
```

### 2. Cloud Firestore API 활성화

**링크**: https://console.cloud.google.com/apis/library/firestore.googleapis.com?project=chickentone-a0f5c

```
☑️ Cloud Firestore API 상태: Enabled
```

만약 "Enable" 버튼이 보이면 클릭!

### 3. 권한 확인

**링크**: https://console.cloud.google.com/iam-admin/iam?project=chickentone-a0f5c

```
☑️ 본인 계정이 "Owner" 또는 "Editor" 권한 보유
```

### 4. 대기 시간

Billing 활성화 후:
```
⏰ 5-10분 대기 (시스템 전파 시간)
```

### 5. Firestore Database 생성

**링크**: https://console.firebase.google.com/project/chickentone-a0f5c/firestore

#### 설정값:
```
Database ID: githubjson (또는 (default))
Location: asia-northeast3 (Seoul)
Security rules: Start in test mode
```

#### 생성 후 확인:
```
☑️ "Data" 탭에서 빈 데이터베이스 확인
☑️ "Rules" 탭에서 보안 규칙 확인
☑️ "Usage" 탭에서 사용량 0 확인
```

## 🚨 문제 해결

### 에러: "Billing not enabled"

**해결 방법**:
1. 5-10분 더 대기
2. 브라우저 하드 리프레시 (Ctrl + F5)
3. 시크릿 모드로 재시도
4. 다른 브라우저 사용

### 에러: "Permission denied"

**해결 방법**:
1. IAM 권한 확인
2. 프로젝트 Owner인지 확인
3. Firebase 프로젝트 멤버인지 확인

### 에러: "API not enabled"

**해결 방법**:
1. Cloud Firestore API 활성화
2. Firebase Management API 활성화
   - https://console.cloud.google.com/apis/library/firebase.googleapis.com

## 📊 생성 완료 확인

### Firestore Console에서 확인

**Data 탭**:
```
┌────────────────────────────────────┐
│ Start collection                   │
│ Add your first collection          │
└────────────────────────────────────┘
```

### Firebase Console에서 확인

**좌측 메뉴**:
```
✅ Firestore Database (활성화됨)
   └─ Data
   └─ Rules
   └─ Indexes
   └─ Usage
```

## 🎯 다음 단계

### 1. Security Rules 설정 (선택)

**현재 (Test Mode)**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 12, 12);
    }
  }
}
```

**프로덕션 (인증 필수)**:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /cache/{userId}/{document} {
      allow read, write: if request.auth != null
        && request.auth.uid == userId;
    }
  }
}
```

### 2. 코드에서 Firestore 사용

**Controller 수정**:
```dart
// lib/features/github/controllers/forest_controller.dart
final _repository = GitHubRepository(useFirestore: true);
```

**또는 setup.dart 설정**:
```dart
// lib/setup.dart
static const enableFirestoreCache = true;
```

### 3. 테스트

**테스트 스크립트 실행**:
```bash
flutter run -d windows -t test_firestore_cache.dart
```

**Firebase Console에서 확인**:
1. Firestore Database → Data 탭
2. "cache" 컬렉션 생성 확인
3. 문서 데이터 확인

## 💰 예산 알림 설정 (권장)

**링크**: https://console.cloud.google.com/billing/015137-24AEE4-6DEE65/budgets

```
예산 이름: Firebase Monthly
금액: $1
알림: 50%, 90%, 100%
```

## 📝 완료!

모든 체크리스트가 완료되면:
```
✅ Billing 활성화
✅ Firestore Database 생성
✅ Security Rules 설정
✅ 코드 연동
✅ 테스트 완료
✅ 예산 알림 설정
```

이제 Firestore 캐시를 사용할 수 있습니다! 🎉
