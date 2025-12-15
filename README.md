# Repo Arborist 🌳

GitHub 저장소를 살아있는 정원으로 시각화하는 Flutter 앱

저장소를 프로그래밍 언어별 식물로 표현합니다. 활동량, 나이, 최근 작업에 따라 식물이 성장하고 변화합니다.

## ✨ 주요 기능

### 🌱 11가지 식물 종류 (프로그래밍 언어별)

- **Blueberry** - Dart, Flutter
- **Coffee** - Java, Kotlin, Scala
- **Ginkgo** - JavaScript, TypeScript
- **SnakePlant** - Python, Jupyter Notebook
- **Fir** - C, C++, Rust, Objective-C
- **Blossom** - Swift, SwiftUI
- **Bamboo** - Go
- **Oak** - C#, PHP, Perl
- **Maple** - Ruby, HTML, CSS
- **Cactus** - Shell, Bash, Docker
- **Pine** - Assembly, VHDL, Embedded

### 📊 성장 시스템

**3단계 성장**:

- **Sprout (새싹)**: 100점 미만
- **Bloom (꽃)**: 100-299점
- **Tree (나무)**: 300점 이상

**점수 계산**:

- 커밋 1개 = 1점
- 머지된 PR 1개 = 3점

### 🎨 활동 기반 효과

**4단계 활동 티어**:

- **Fresh** (7일 이내): 발광 효과, 크기 +5%
- **Warm** (8-30일): 반짝임 효과
- **Cooling** (31-180일): 채도 70%
- **Dormant** (180일 초과): 채도 50%, 크기 -5%, 세피아 톤

**시각적 특징**:

- 인터랙티브 정원 뷰 (줌/팬 가능)
- 각 식물별 개별 애니메이션
- 5년 이상 저장소는 세피아 효과
- 픽셀 아트 스타일

### 🔐 GitHub 인증

- **Public 모드**: 토큰 없이 공개 저장소 조회 (IP당 1시간에 약 20개 제한)
- **Token 모드**: Private 저장소 포함 + API 제한 완화 (시간당 1,000개 요청 )

## ⚙️ Setup (설정)

- **[Flutter 환경 설정](docs/setup/FLUTTER_SETUP.md)** - Flutter 개발 환경 구축
  - [Windows](docs/setup/FLUTTER_SETUP_WINDOWS.md) | [macOS](docs/setup/FLUTTER_SETUP_MACOS.md) | [FVM](docs/setup/FLUTTER_SETUP_FVM.md) | [문제 해결](docs/setup/FLUTTER_TROUBLESHOOTING.md)

## 🚀 시작하기

### Prerequisites

- Flutter 3.35.6 (FVM 사용 권장)
- Dart 3.6.0+

### Installation

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

## 🏗️ 프로젝트 구조

```
lib/
├── core/                    # Core utilities
│   ├── controllers/         # Global state (theme)
│   ├── services/            # Cache, storage services
│   ├── themes/              # Colors, typography
│   └── widgets/             # Reusable widgets
├── features/                # Feature modules
│   ├── github/              # Main feature - GitHub visualization
│   │   ├── controllers/     # Auth, forest, PAT state
│   │   ├── models/          # Repository, stats models
│   │   ├── repositories/    # GitHub API integration
│   │   ├── screens/         # Login, garden, forest, detail
│   │   └── widgets/         # Plant widgets, UI components
│   ├── encyclopedia/        # Plant encyclopedia
│   │   ├── models/          # Plant type, info models
│   │   └── screens/         # Grid, detail screens
│   ├── contact/             # Feedback form
│   │   ├── controllers/     # Contact form state
│   │   ├── models/          # Message model
│   │   └── screens/         # Contact screen
│   ├── settings/            # App settings
│   │   └── screens/         # Settings screen
│   └── playground/          # Experimental features
│       ├── screens/         # Test screens
│       └── widgets/         # Test widgets
└── gen/                     # Generated code (flutter_gen)
```

## 🔧 주요 기술 스택

**상태 관리**: flutter_riverpod (AsyncNotifier 패턴)
**UI**: google_fonts, flutter_svg, easy_localization
**백엔드**: Firebase (Core, Crashlytics, Firestore)
**스토리지**: hive (local cache), flutter_secure_storage (tokens)
**개발 도구**: flutter_gen_runner (asset generation), pedantic_mono (linting)

## 📚 문서

### Architecture

- [프로젝트 구조](docs/architecture/project-structure.md) - 폴더 구조와 모듈화 전략
- [컨트롤러](docs/architecture/controllers.md) - Riverpod 상태 관리
- [레포지토리](docs/architecture/repositories.md) - Repository 패턴
- [에러 핸들링](docs/architecture/error-handling.md) - 에러 처리

### Features

- [다국어화](docs/features/localization.md) - easy_localization 사용법
- [테마](docs/features/theming.md) - 색상, 타이포그래피

### Setup (추가 설정)

- [Firebase 설정](docs/setup/FIREBASE_SETUP.md) - Crashlytics & Firestore
- [Claude Code MCP](docs/setup/CLAUDE_CODE_MCP_SETUP.md) - Figma 연동

## ⚠️ 보안 참고사항

이 프로젝트는 개인 토이 프로젝트입니다.

- **Firebase API 키**: `google-services.json`의 API 키는 공개 가능합니다 ([Firebase 공식 문서](https://firebase.google.com/docs/projects/api-keys) 참고)
  - 실제 보안은 Firebase Security Rules로 관리됩니다
  - 프로덕션 앱 배포 시 Security Rules 강화 필요
- **GitHub Token**: `.env` 파일은 `.gitignore`에 포함되어 있으며 절대 커밋되지 않습니다
  - `.env.example` 파일을 복사하여 개인 토큰 설정

## 라이센스

MIT
