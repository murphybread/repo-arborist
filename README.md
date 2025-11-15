# Repo Arborist 🌳

GitHub 저장소를 살아있는 숲으로 시각화하는 Flutter 앱

당신의 GitHub 저장소를 아름다운 나무로 표현합니다. 각 저장소는 활동량, 나이, 크기에 따라 다른 모습의 나무로 성장합니다.

## ✨ 주요 기능

### 🌲 나무 시각화
- **성장 단계**: 저장소 활동량에 따라 새싹 → 꽃 → 나무로 성장
- **다양한 변종**: 노란색, 파란색, 주황색, 분홍색 꽃과 초록색, 빨간색 나무
- **선인장 모드**: 365일 이상 활동이 없는 저장소는 선인장으로 변신

### 📊 저장소 통계
- 총 커밋 수
- 병합된 Pull Request 수
- 프로젝트 점수 (커밋 + PR × 5)
- 최근 활동 내역 (커밋 & PR)

### 🎨 시각적 특징
- **활동 티어**: 최근 활동에 따른 빛 효과 (Fresh/Warm/Cooling/Dormant)
- **나이 효과**: 오래된 저장소는 세피아 톤 적용
- **인터랙티브 정원**: 확대/축소, 드래그로 숲 탐험
- **자연스러운 애니메이션**: 각 나무가 개별적으로 흔들림

### 🔐 GitHub 인증
- **Public 모드**: 공개 저장소만 보기 (토큰 불필요)
- **Token 모드**: Private 저장소 포함 + API 제한 완화 (시간당 5,000회)

## ⚙️ Setup (설정)

- **[Flutter 환경 설정](docs/setup/FLUTTER_SETUP.md)** - Flutter 개발 환경 구축
  - [Windows](docs/setup/FLUTTER_SETUP_WINDOWS.md) | [macOS](docs/setup/FLUTTER_SETUP_MACOS.md) | [FVM](docs/setup/FLUTTER_SETUP_FVM.md) | [문제 해결](docs/setup/FLUTTER_TROUBLESHOOTING.md)

## 시작하기

### FVM 사용 (권장)

이 프로젝트는 FVM으로 Flutter 버전을 관리합니다 (v3.35.6).

```bash
# FVM 설치 (처음 한 번만)
dart pub global activate fvm

# 프로젝트 Flutter 버전 설치
fvm install

# 의존성 설치
fvm flutter pub get

# 앱 실행
fvm flutter run
```

## Flutter 유용한 커맨드

```bash
# 패키지 추가
fvm flutter pub add package_name

# 코드 포맷팅
fvm dart format .

# 빌드 캐시 삭제
fvm flutter clean

# 빌드
fvm flutter build apk                        # Android APK 빌드
fvm flutter build appbundle                  # Android App Bundle 빌드
```

## Git 유용한 커맨드

```bash
# 직전 커밋 취소 (변경사항은 staged 상태로 유지)
git reset --soft HEAD~1

# 강제 푸시 (주의: 협업 시 사용 금지)
git push --force

```

## 폴더 구조

```
lib/
├── core/
│   ├── controllers/    # 전역 컨트롤러 (테마)
│   └── themes/         # 테마 설정 (AppColors, AppTypography)
└── features/           # 기능별 모듈
    └── github/         # GitHub 저장소 시각화
        ├── controllers/    # 상태 관리 (인증, 숲 데이터)
        ├── models/         # 데이터 모델 (저장소, 나무)
        ├── repositories/   # GitHub API 연동
        ├── screens/        # 화면 (로그인, 정원, 숲, 상세)
        └── widgets/        # 나무 위젯 및 UI 컴포넌트
```

## 주요 패키지

- `flutter_riverpod: ^3.0.3` - 상태 관리
- `easy_localization: ^3.0.8` - 다국어 지원
- `google_fonts: ^6.3.2` - 폰트
- `http: ^1.2.2` - GitHub API 클라이언트
- `hive: ^2.2.3` - 로컬 캐싱 (API 호출 최소화)
- `flutter_svg: ^2.0.16` - SVG 나무 이미지 렌더링
- `firebase_core: ^4.2.0` - Firebase 코어
- `firebase_crashlytics: ^5.0.3` - 크래시 리포팅
- `pedantic_mono: ^1.34.0` - 린트 규칙

## 📚 문서

- **[프로젝트 구조](docs/architecture/project-structure.md)** - 폴더 구조와 모듈화 전략
- **[스크린 & 위젯](docs/architecture/screens.md)** - 화면과 위젯 작성 가이드
- **[컨트롤러](docs/architecture/controllers.md)** - Riverpod 상태 관리 (Notifier, AsyncNotifier)
- **[레포지토리](docs/architecture/repositories.md)** - Repository 레이어 사용 가이드
- **[다국어화](docs/features/localization.md)** - easy_localization 사용법
- **[테마](docs/features/theming.md)** - 색상, 타이포그래피, 테마 전환
- **[에러 핸들링](docs/architecture/error-handling.md)** - 에러 처리와 Crashlytics

---

## 🔧 추가 설정 (선택사항)

- **[Firebase 설정](docs/setup/FIREBASE_SETUP.md)** - Firebase & Crashlytics 설정
- **[Claude Code MCP 설정](docs/setup/CLAUDE_CODE_MCP_SETUP.md)** - Figma 연동 설정

## ⚠️ 보안 참고사항

이 프로젝트는 개인 토이 프로젝트입니다.

- **Firebase API 키**: `google-services.json`의 API 키는 공개 가능합니다 ([Firebase 공식 문서](https://firebase.google.com/docs/projects/api-keys) 참고)
  - 실제 보안은 Firebase Security Rules로 관리됩니다
  - 프로덕션 앱 배포 시 Security Rules 강화 필요
- **GitHub Token**: `.env` 파일은 `.gitignore`에 포함되어 있으며 절대 커밋되지 않습니다
  - `.env.example` 파일을 복사하여 개인 토큰 설정

## 라이센스

MIT
