# 🚀 Google Play 릴리즈 체크리스트

> **현재 상태:** 개발 중 (v1.0.0+1)
> **마지막 업데이트:** 2025-12-03

---

## ✅ 완료된 작업

- [x] AndroidManifest.xml에 INTERNET 권한 추가
- [x] 앱 이름 변경 (blueberry_template → Repo Arborist)
- [x] Package 이름 변경 (template → repo_arborist)
- [x] print() → debugPrint() 전환 (CLAUDE.md 가이드 준수)
- [x] BuildContext async 안전성 수정

---

## 📝 기능 개발 완료 후 해야 할 일

### 1단계: 앱 기본 설정 (필수) ⚠️

#### 1.1 앱 서명 (Keystore) 생성
**중요도:** 🔴 필수
**타이밍:** 첫 릴리즈 전

```bash
# Keystore 생성 (한 번만 실행)
keytool -genkey -v -keystore ~/repo-arborist-upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# ⚠️ 주의: 비밀번호와 keystore 파일은 안전하게 보관!
# 분실 시 앱 업데이트 불가능
```

**android/key.properties 생성:**
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/path/to/repo-arborist-upload-keystore.jks
```

**android/app/build.gradle 수정 필요** (아직 생성 안 됨)

---

#### 1.2 Package Name (Application ID) 변경
**중요도:** 🔴 필수
**타이밍:** 첫 릴리즈 전

**현재:** 미설정 (기본값 사용 중)
**변경 필요:** `com.blueberry.repoarborist`

**수정 위치:**
- `android/app/build.gradle`의 `applicationId`
- `AndroidManifest.xml`의 `package` 속성

**참고:** 한 번 릴리즈하면 변경 불가!

---

#### 1.3 앱 아이콘 교체
**중요도:** 🟡 권장
**타이밍:** 첫 릴리즈 전

**현재:** Flutter 기본 아이콘 사용 중

**작업 방법:**
```bash
# flutter_launcher_icons 패키지 추가
fvm flutter pub add flutter_launcher_icons --dev
```

**pubspec.yaml 설정:**
```yaml
flutter_launcher_icons:
  android: true
  ios: false  # iOS 지원 안 함
  image_path: "assets/icon/app_icon.png"  # 1024x1024 PNG
  adaptive_icon_background: "#2E7D32"  # 초록색 배경
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

**생성 명령:**
```bash
fvm flutter pub run flutter_launcher_icons
```

---

#### 1.4 개인정보 처리방침 작성
**중요도:** 🔴 필수
**타이밍:** 첫 릴리즈 전

**수집하는 정보:**
- GitHub 사용자명
- 저장소 목록 (public)
- 커밋/PR 통계

**필요 작업:**
1. 개인정보 처리방침 문서 작성 (한글/영문)
2. 웹사이트에 호스팅 (GitHub Pages, Notion 등)
3. 앱 내 "설정 > 개인정보 처리방침" 링크 추가
4. Google Play Console에 URL 등록

**템플릿:** https://www.privacy.go.kr/a3sc/per/inf/perInfStep01.do

---

### 2단계: 코드 품질 개선 (권장) 🟡

#### 2.1 GitHub Token 보안 개선
**현재 문제:** `.env` 파일에 토큰 저장 (디컴파일 시 유출 위험)

**권장 해결책:**
- OAuth 인증으로 전환
- 사용자가 직접 로그인하도록 변경
- 또는 백엔드 서버에서 토큰 관리

---

#### 2.2 테스트 커버리지 향상
**현재:** 테스트 미비

**권장 작업:**
```bash
# 테스트 실행
flutter test --coverage

# 목표: 최소 60% 이상
```

**우선순위 테스트:**
- GitHub API 연동 (repository, user)
- 시각화 로직 (TreeVisualProperties 계산)
- 캐싱 로직 (Hive, Firestore)

---

#### 2.3 다국어 지원 완성
**현재:** 한국어 중심, 영어 번역 미완성

**작업:**
- `assets/translations/en.json` 번역 완료
- 모든 하드코딩 문자열 `.tr()` 적용 확인

---

#### 2.4 ProGuard/R8 난독화 설정
**타이밍:** 첫 릴리즈 전

**android/app/build.gradle 추가:**
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

**android/app/proguard-rules.pro 생성:**
```proguard
# Flutter 기본
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Hive
-keep class * extends io.flutter.app.FlutterActivity
-keep class io.flutter.** { *; }
```

---

### 3단계: 릴리즈 빌드 테스트 🧪

#### 3.1 릴리즈 빌드 생성 및 테스트
```bash
# APK 빌드
flutter build apk --release

# AAB 빌드 (Google Play 권장)
flutter build appbundle --release

# 빌드 크기 분석
flutter build apk --release --analyze-size
```

**테스트 항목:**
- [ ] 앱 설치 및 실행
- [ ] GitHub 로그인
- [ ] 저장소 목록 로드
- [ ] 나무 시각화 정상 동작
- [ ] 다크 모드 전환
- [ ] 언어 전환 (한/영)
- [ ] Firebase Crashlytics 동작 확인

---

#### 3.2 성능 프로파일링
```bash
flutter run --profile
# DevTools에서 성능 측정
```

**체크 포인트:**
- 앱 시작 속도 (3초 이내)
- 메모리 사용량 (100MB 이내)
- 프레임 드롭 없음 (60fps 유지)

---

### 4단계: Google Play Console 준비 📱

#### 4.1 스토어 자료 준비

**필수 자료:**
- [ ] 앱 아이콘 (512x512 PNG)
- [ ] 홍보 이미지 (1024x500 PNG)
- [ ] 스크린샷 (최소 2장, 권장 8장)
  - 5.5인치: 1080 x 1920
  - 7인치 태블릿: 1200 x 1920
- [ ] 짧은 설명 (80자 이내)
- [ ] 전체 설명 (4000자 이내)

**짧은 설명 (예시):**
```
GitHub 저장소를 살아있는 나무로 시각화하세요. 당신만의 코드 숲을 만들어보세요!
```

**카테고리:** 도구 또는 생산성

---

#### 4.2 앱 콘텐츠 등급
**질문지 작성 필요:**
- 폭력성: 없음
- 성적 콘텐츠: 없음
- 언어: 없음

**예상 등급:** 만 3세 이상 (EVERYONE)

---

#### 4.3 대상 국가
**권장:**
- 한국 (주 타겟)
- 미국, 영국 (영어 지원)

---

### 5단계: 릴리즈 전 최종 체크 ✔️

#### 5.1 버전 관리
**pubspec.yaml:**
```yaml
version: 1.0.0+1  # 현재
# 다음 업데이트 시:
# version: 1.0.1+2  (버그 수정)
# version: 1.1.0+3  (기능 추가)
```

---

#### 5.2 코드 품질 체크
```bash
# 린트 체크
flutter analyze --no-fatal-infos

# 포맷 체크
dart format . --set-exit-if-changed

# 테스트 실행
flutter test
```

---

#### 5.3 보안 체크
**민감 정보 확인:**
- [ ] `.env` 파일이 `.gitignore`에 포함되어 있는가?
- [ ] `google-services.json`이 `.gitignore`에 포함되어 있는가?
- [ ] `key.properties`가 `.gitignore`에 포함되어 있는가?
- [ ] GitHub Token이 코드에 하드코딩되어 있지 않은가?

---

#### 5.4 릴리즈 노트 작성
**첫 릴리즈 예시:**
```markdown
# v1.0.0 - 첫 번째 릴리즈

## 주요 기능
- GitHub 저장소 시각화 (나무로 표현)
- 저장소 활동 기반 시각 효과
- 다크 모드 지원
- 한국어/영어 지원

## 알려진 제한사항
- Public 저장소만 지원
- GitHub Personal Access Token 필요
```

---

## 📚 참고 자료

### 공식 문서
- [Flutter 앱 배포 가이드](https://docs.flutter.dev/deployment/android)
- [Google Play Console](https://play.google.com/console)
- [Android 앱 서명](https://developer.android.com/studio/publish/app-signing)

### 내부 문서
- [CLAUDE.md](../CLAUDE.md) - 프로젝트 개발 가이드
- [CONCEPT.md](./CONCEPT.md) - RepoMon 10대 가문 도감

---

## 🎯 우선순위 요약

### 🔴 필수 (릴리즈 전 반드시 완료)
1. 앱 서명 (Keystore) 생성
2. Package Name (Application ID) 변경
3. 개인정보 처리방침 작성 및 호스팅
4. 앱 아이콘 교체
5. 릴리즈 빌드 테스트

### 🟡 권장 (품질 향상)
1. GitHub Token 보안 개선 (OAuth)
2. 테스트 커버리지 향상
3. 다국어 지원 완성
4. ProGuard/R8 난독화
5. 성능 프로파일링

### 🟢 선택 (출시 후 고려)
1. 내부 테스트 트랙 활용
2. 베타 테스트 진행
3. 사용자 피드백 수집
4. A/B 테스트

---

## 📅 예상 일정

**기능 개발 완료 후 (D-Day 기준):**
- **D-7일:** 필수 항목 1-3 완료 (서명, Package ID, 개인정보)
- **D-5일:** 필수 항목 4-5 완료 (아이콘, 테스트)
- **D-3일:** 스토어 자료 준비 완료
- **D-1일:** 내부 테스트 진행
- **D-Day:** 프로덕션 릴리즈

**예상 소요 시간:** 약 2-3주 (기능 개발 제외)

---

## 🆘 트러블슈팅

### Q: Keystore 비밀번호를 잊어버렸어요
**A:** 새 keystore를 만들어야 하며, 기존 앱은 업데이트 불가. 처음부터 다시 릴리즈해야 함.

### Q: 앱이 설치는 되는데 실행이 안 돼요
**A:**
1. AndroidManifest.xml에 INTERNET 권한 확인
2. ProGuard 규칙 확인
3. Firebase 설정 확인 (google-services.json)

### Q: 빌드 크기가 너무 커요 (100MB 초과)
**A:**
1. `flutter build apk --split-per-abi` 사용
2. 사용하지 않는 이미지 제거
3. flutter_gen으로 최적화

---

**마지막 업데이트:** 2025-12-03
**작성자:** Claude Code
**문의:** GitHub Issues
