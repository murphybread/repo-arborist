# 🎯 릴리즈 필수 기능 목록

> **현재 상태:** 개발 중 (v1.0.0+1)
> **Package Name:** com.blueberry.repoarborist
> **마지막 업데이트:** 2025-12-03

---

## 📱 현재 구현된 화면

- ✅ **GithubLoginScreen** - GitHub 로그인 (Username 입력)
- ✅ **ForestScreen** - 저장소 목록 (숲 뷰)
- ✅ **GardenOverviewScreen** - 정원 개요
- ✅ **RepositoryDetailScreen** - 저장소 상세 정보

---

## 🔴 필수 기능 (지금 릴리즈한다면 반드시 추가)

### 1. 에러 처리 및 예외 상황 대응

#### 1.1 네트워크 에러 처리
**현재 상태:** 에러 발생 시 처리 미비
**필요 작업:**

```dart
// ✅ 추가 필요
- [ ] 인터넷 연결 끊김 감지
- [ ] API Rate Limit 초과 안내 (GitHub: 60회/시간 → 5000회/시간)
- [ ] 타임아웃 처리 (30초 이상 응답 없을 시)
- [ ] 재시도 버튼
```

**추가 위치:**
- `lib/features/github/repositories/github_repository.dart`
- `lib/features/github/widgets/forest_loading_widget.dart`

**구현 예시:**
```dart
// 에러 다이얼로그
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('error_title'.tr()),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('common.close'.tr()),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _retry();
          },
          child: Text('common.retry'.tr()),
        ),
      ],
    ),
  );
}
```

---

#### 1.2 GitHub API 에러 처리
**필요 작업:**

```dart
- [ ] 404 Not Found (사용자/저장소 없음)
- [ ] 403 Forbidden (권한 없음)
- [ ] 401 Unauthorized (토큰 만료/잘못됨)
- [ ] 500 Server Error (GitHub 서버 문제)
```

**사용자 친화적 메시지:**
- ❌ "Failed to load repository: 404"
- ✅ "존재하지 않는 사용자입니다. 사용자명을 확인해주세요."

---

#### 1.3 빈 데이터 처리
**현재 문제:** 저장소가 없는 사용자 처리 미비

```dart
- [ ] 저장소 0개인 경우 안내 화면
- [ ] Public 저장소만 없는 경우 안내
- [ ] 최근 활동이 없는 저장소 처리
```

**Empty State UI 추가 필요:**
```dart
// lib/features/github/widgets/empty_forest_widget.dart (신규)
class EmptyForestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forest, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('아직 저장소가 없습니다', style: AppTypography.title),
          SizedBox(height: 8),
          Text('GitHub에서 프로젝트를 만들어보세요!'),
        ],
      ),
    );
  }
}
```

---

### 2. 설정 화면 추가 (필수)

#### 2.1 설정 화면 구조
**파일 위치:** `lib/features/settings/screens/settings_screen.dart` (신규)

**필요 항목:**
```dart
- [ ] 개인정보 처리방침 링크 (Google Play 필수!)
- [ ] 서비스 이용약관 링크
- [ ] 오픈소스 라이선스
- [ ] 앱 버전 정보
- [ ] 개발자 정보 / 문의하기
- [ ] 로그아웃 버튼
- [ ] 계정 삭제 (선택)
```

**구현 예시:**
```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: ListView(
        children: [
          // 다크 모드 (이미 구현됨)
          SwitchListTile(
            title: Text('settings.dark_mode'.tr()),
            value: ref.watch(themeControllerProvider) == ThemeMode.dark,
            onChanged: (value) => ref.read(themeControllerProvider.notifier).toggleTheme(),
          ),

          Divider(),

          // 개인정보 처리방침 (필수!)
          ListTile(
            title: Text('settings.privacy_policy'.tr()),
            trailing: Icon(Icons.open_in_new),
            onTap: () => _launchUrl('https://yoursite.com/privacy'),
          ),

          // 서비스 이용약관
          ListTile(
            title: Text('settings.terms_of_service'.tr()),
            trailing: Icon(Icons.open_in_new),
            onTap: () => _launchUrl('https://yoursite.com/terms'),
          ),

          // 오픈소스 라이선스
          ListTile(
            title: Text('settings.licenses'.tr()),
            onTap: () => showLicensePage(context: context),
          ),

          Divider(),

          // 앱 정보
          ListTile(
            title: Text('settings.app_version'.tr()),
            subtitle: Text('1.0.0 (Build 1)'),
          ),

          // 로그아웃
          ListTile(
            title: Text('settings.logout'.tr()),
            textColor: Colors.red,
            onTap: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }
}
```

**필요 패키지:**
```bash
fvm flutter pub add url_launcher  # 외부 링크 열기
```

---

#### 2.2 개인정보 처리방침 페이지 호스팅
**⚠️ Google Play 필수 요구사항!**

**옵션 1: GitHub Pages (무료, 추천)**
```bash
# 프로젝트 루트에 docs/ 폴더 생성
mkdir docs
echo "# 개인정보 처리방침" > docs/privacy.md

# GitHub에서 Settings > Pages > Source: docs/ 설정
# URL: https://yourname.github.io/repo-arborist/privacy
```

**옵션 2: Notion (가장 쉬움)**
- Notion에서 페이지 작성
- 우측 상단 "공유" > "웹에 게시"
- URL 복사

**옵션 3: Google Sites (무료)**
- sites.google.com에서 생성

**최소 포함 내용:**
```markdown
# 개인정보 처리방침

## 1. 수집하는 정보
- GitHub 사용자명
- Public 저장소 목록
- 저장소 통계 (커밋, PR, 이슈 수)

## 2. 정보 사용 목적
- 저장소 시각화 서비스 제공
- 앱 성능 개선 (Firebase Crashlytics)

## 3. 정보 보관 기간
- 로그아웃 시 즉시 삭제
- 로컬 캐시: 앱 삭제 시 자동 삭제

## 4. 제3자 제공
- GitHub API를 통한 공개 정보만 수집
- 제3자에게 정보 제공하지 않음

## 5. 연락처
- 이메일: your@email.com
- GitHub: https://github.com/yourname/repo-arborist
```

---

### 3. 사용자 가이드 / 온보딩

#### 3.1 첫 실행 시 튜토리얼
**파일 위치:** `lib/features/onboarding/screens/onboarding_screen.dart` (신규)

**필요 화면:**
```dart
- [ ] 화면 1: "GitHub 저장소를 나무로!" (앱 소개)
- [ ] 화면 2: "활동량에 따라 성장" (기능 설명)
- [ ] 화면 3: "나만의 코드 숲 만들기" (시작하기 버튼)
```

**구현 패키지:**
```bash
fvm flutter pub add introduction_screen  # 온보딩 UI 라이브러리
```

---

#### 3.2 GitHub Token 안내 개선
**현재 문제:** Token이 뭔지, 어떻게 발급하는지 안내 부족

**추가 필요:**
```dart
// lib/features/github/screens/github_login_screen.dart
// "Token이 뭔가요?" 버튼 추가

void _showTokenGuide(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('GitHub Token 발급 방법'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. GitHub.com 로그인'),
            Text('2. Settings > Developer settings'),
            Text('3. Personal access tokens > Tokens (classic)'),
            Text('4. Generate new token'),
            Text('5. 권한: public_repo 선택'),
            SizedBox(height: 16),
            Text('💡 Token을 사용하면 시간당 5,000회까지 조회 가능합니다!'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // GitHub Token 발급 페이지로 이동
            _launchUrl('https://github.com/settings/tokens');
          },
          child: Text('발급하러 가기'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('닫기'),
        ),
      ],
    ),
  );
}
```

---

### 4. 로딩 상태 개선

#### 4.1 스켈레톤 로딩
**현재:** CircularProgressIndicator만 사용

**개선:**
```dart
- [ ] Shimmer 효과로 스켈레톤 UI
- [ ] 예상 로딩 시간 표시
- [ ] 로딩 중 메시지 ("저장소 불러오는 중...")
```

**패키지:**
```bash
fvm flutter pub add shimmer  # 스켈레톤 UI
```

---

#### 4.2 진행률 표시
**대용량 데이터 로딩 시:**
```dart
- [ ] "저장소 12/45 로딩 중..." 같은 진행률
- [ ] 취소 버튼 추가
```

---

### 5. 앱 크래시 방지

#### 5.1 예외 처리 강화
**전역 에러 핸들러 추가:**

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 전역 에러 핸들러
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Firebase Crashlytics에 전송
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // Async 에러 핸들러
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(MyApp());
}
```

---

#### 5.2 Null Safety 검증
```bash
# 모든 null 관련 경고 확인
flutter analyze | grep -E "(null|Null)"
```

**중요 체크포인트:**
- API 응답 null 체크
- 리스트 인덱스 범위 체크
- 파일/캐시 접근 시 존재 여부 확인

---

### 6. UX 개선 (중요도 높음)

#### 6.1 Pull-to-Refresh
**추가 위치:** ForestScreen, GardenOverviewScreen

```dart
RefreshIndicator(
  onRefresh: () async {
    await ref.read(forestProvider.notifier).refresh(forceRefresh: true);
  },
  child: ListView(...),
)
```

---

#### 6.2 검색 기능
**ForestScreen에 추가:**
```dart
- [ ] 저장소 이름으로 검색
- [ ] 필터링 (언어별, 활동별)
- [ ] 정렬 (이름순, 최근 활동순, 크기순)
```

---

#### 6.3 상세 정보 툴팁
**나무 클릭 시:**
```dart
- [ ] "이 나무는 최근 30일간 활동이 없어 잠들어 있습니다"
- [ ] "빛나는 나무는 최근 3일 이내 커밋이 있습니다"
- [ ] 성장 단계 설명 (새싹 → 꽃 → 나무)
```

---

### 7. 번역 완성

#### 7.1 영어 번역
**현재:** `assets/translations/en.json` 미완성

**필수 번역 키:**
```json
{
  "common": {
    "retry": "Retry",
    "close": "Close",
    "cancel": "Cancel",
    "ok": "OK"
  },
  "error": {
    "network": "Network connection failed",
    "not_found": "User not found",
    "rate_limit": "API rate limit exceeded"
  },
  "settings": {
    "title": "Settings",
    "dark_mode": "Dark Mode",
    "privacy_policy": "Privacy Policy",
    "logout": "Logout"
  }
}
```

---

#### 7.2 하드코딩 문자열 제거
```bash
# 하드코딩된 문자열 찾기
grep -rn "Text('" lib/ | grep -v ".tr()"

# 모두 .tr()로 변환 필요
```

---

### 8. 성능 최적화

#### 8.1 이미지 최적화
**현재 문제:** SVG 파일 다수, 메모리 사용량 증가 가능

```dart
- [ ] 자주 사용하는 이미지 캐싱
- [ ] 큰 이미지 lazy loading
- [ ] SVG → PNG 변환 (필요시)
```

---

#### 8.2 리스트 최적화
**저장소 100개 이상인 경우:**
```dart
- [ ] ListView.builder → LazyLoad
- [ ] 페이지네이션 (20개씩 로드)
- [ ] 무한 스크롤
```

---

### 9. 보안 강화

#### 9.1 GitHub Token 저장 방식
**현재:** `.env` 파일 (보안 취약)

**개선 옵션:**
1. **flutter_secure_storage** 사용 (추천)
```bash
fvm flutter pub add flutter_secure_storage
```

2. **OAuth 전환** (가장 안전)
```bash
fvm flutter pub add oauth2
```

---

#### 9.2 민감 정보 로그 제거
```dart
// ❌ 금지
debugPrint('Token: $token');

// ✅ 허용
debugPrint('Token exists: ${token != null}');
```

---

### 10. 접근성 (Accessibility)

#### 10.1 Semantics 추가
```dart
Semantics(
  label: '저장소: ${repo.name}',
  hint: '탭하여 상세정보 보기',
  child: TreeWidget(repo: repo),
)
```

---

#### 10.2 폰트 크기 대응
```dart
- [ ] 시스템 폰트 크기 설정 대응
- [ ] 텍스트 overflow 처리
- [ ] 최소 터치 영역 44x44
```

---

## 🎯 우선순위 정리

### 🔴 **최우선 (릴리즈 불가능)**

1. **설정 화면 + 개인정보 처리방침** (Google Play 필수!)
2. **네트워크 에러 처리**
3. **빈 데이터 처리 (Empty State)**
4. **전역 에러 핸들러**
5. **영어 번역 완성**

**예상 작업 시간:** 3-5일

---

### 🟡 **중요 (품질 보장)**

6. **GitHub Token 안내 개선**
7. **로딩 상태 개선 (Shimmer)**
8. **Pull-to-Refresh**
9. **첫 실행 온보딩**
10. **검색 및 필터링**

**예상 작업 시간:** 5-7일

---

### 🟢 **추가 개선 (출시 후 가능)**

11. **Token 보안 강화 (Secure Storage)**
12. **성능 최적화 (페이지네이션)**
13. **접근성 개선**
14. **상세 툴팁 추가**

**예상 작업 시간:** 7-10일

---

## 📅 개발 로드맵

### Week 1: 필수 기능 (🔴)
- Day 1-2: 설정 화면 + 개인정보 처리방침
- Day 3: 에러 처리 (네트워크, API)
- Day 4: Empty State + 전역 에러 핸들러
- Day 5: 영어 번역 + 테스트

### Week 2: 중요 기능 (🟡)
- Day 1: Token 안내 + 온보딩
- Day 2-3: 로딩 개선 + Pull-to-Refresh
- Day 4-5: 검색 및 필터링

### Week 3: 테스트 & 출시 준비
- Day 1-2: QA 테스트
- Day 3-4: 버그 수정
- Day 5: 스토어 자료 준비

---

## 📊 릴리즈 준비도 체크

### 현재 상태: **30%**

```
✅ 완료 (30%)
├─ 핵심 UI (4개 화면)
├─ GitHub API 연동
├─ 다크 모드
└─ 다국어 기반 구축

❌ 필요 (70%)
├─ 에러 처리 (20%)
├─ 설정 화면 (15%)
├─ 번역 완성 (10%)
├─ UX 개선 (15%)
└─ 보안 강화 (10%)
```

---

## 🆘 최소 릴리즈 버전 (MVP)

**만약 1주일 내로 릴리즈해야 한다면:**

```dart
✅ 반드시 포함:
1. 설정 화면 (개인정보 처리방침 링크)
2. 네트워크 에러 다이얼로그
3. 저장소 없을 때 Empty State
4. 영어 번역 핵심 문구

⏸️ 미룰 수 있음:
- 온보딩 (나중에 추가 가능)
- 검색 기능
- 고급 필터링
- Token 보안 강화
```

**예상 작업 시간:** 2-3일 (집중 개발)

---

## 📞 질문 체크리스트

릴리즈 전 스스로에게 물어보기:

- [ ] 인터넷이 끊겼을 때 앱이 죽지 않는가?
- [ ] GitHub 사용자가 없을 때 적절한 안내가 나오는가?
- [ ] 저장소가 0개인 사용자도 사용 가능한가?
- [ ] 개인정보 처리방침 링크가 있는가? (필수!)
- [ ] 영어 사용자도 앱을 이해할 수 있는가?
- [ ] 다크 모드에서 모든 화면이 정상인가?
- [ ] 큰 화면(태블릿)에서도 정상인가?
- [ ] 로딩이 30초 이상 걸릴 때 타임아웃이 있는가?

---

**마지막 업데이트:** 2025-12-03
**Package Name:** com.blueberry.repoarborist
**작성자:** Claude Code
