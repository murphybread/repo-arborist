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

## 📱 화면 구조

### GitHub 기능

| 화면              | 설명                              | 경로                                                    |
| ----------------- | --------------------------------- | ------------------------------------------------------- |
| Login             | GitHub 토큰 입력 화면 (앱 시작점) | `features/github/screens/github_login_screen.dart`      |
| Forest            | 여러 저장소를 정원으로 표시       | `features/github/screens/forest_screen.dart`            |
| Garden Overview   | 단일 저장소의 상세 정원 뷰        | `features/github/screens/garden_overview_screen.dart`   |
| Repository Detail | 저장소 통계 및 상세 정보          | `features/github/screens/repository_detail_screen.dart` |

### Encyclopedia (식물 도감)

| 화면                | 설명                       | 경로                                                            |
| ------------------- | -------------------------- | --------------------------------------------------------------- |
| Encyclopedia Grid   | 11가지 식물 종류 그리드 뷰 | `features/encyclopedia/screens/encyclopedia_grid_screen.dart`   |
| Encyclopedia Detail | 개별 식물 종류 상세 정보   | `features/encyclopedia/screens/encyclopedia_detail_screen.dart` |

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
│   └── settings/            # App settings
│       └── screens/         # Settings screen
└── gen/                     # Generated code (flutter_gen)
```

### 기타

| 화면    | 설명                | 경로                                           |
| ------- | ------------------- | ---------------------------------------------- |
| Contact | 피드백 및 문의 양식 | `features/contact/screens/contact_screen.dart` |

**Navigation Flow**:

```
Login → Garden Overview → Forest → Repository Detail
         ↓                 ↓        ↓
         └─────────────────┴────────┴─→ Encyclopedia Grid → Encyclopedia Detail
                                                ↓
                                             Contact
```

## 🔧 주요 기술 스택

**상태 관리**: flutter_riverpod (AsyncNotifier 패턴)
**UI**: google_fonts, flutter_svg, easy_localization
**네트워크**: http (GitHub API), url_launcher (browser integration)
**백엔드**: Firebase (Core, Crashlytics, Firestore)
**스토리지**: hive (local cache), flutter_secure_storage (tokens)
**개발 도구**: flutter_gen_runner, flutter_dotenv, pedantic_mono

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

## 🧑‍💻 개발 가이드

### 파일 네이밍 컨벤션

| 타입         | 패턴                        | 예시                                               |
| ------------ | --------------------------- | -------------------------------------------------- |
| Screens      | `{feature}_screen.dart`     | `login_screen.dart`, `garden_screen.dart`          |
| Widgets      | `{description}_widget.dart` | `plant_card_widget.dart`, `stat_badge_widget.dart` |
| Controllers  | `{feature}_controller.dart` | `auth_controller.dart`, `forest_controller.dart`   |
| Models       | `{entity}_model.dart`       | `repository_model.dart`, `plant_stats_model.dart`  |
| Repositories | `{feature}_repository.dart` | `github_repository.dart`, `cache_repository.dart`  |
| Services     | `{function}_service.dart`   | `cache_service.dart`, `storage_service.dart`       |

### 커밋 메시지 컨벤션

```
<type>: <subject>

[optional body]
```

**Types**:

- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `docs`: 문서 수정
- `refactor`: 코드 리팩토링 (기능 변경 없음)
- `style`: 코드 포맷팅, 세미콜론 누락 등 (로직 변경 없음)
- `test`: 테스트 코드 추가/수정
- `chore`: 빌드 프로세스, 패키지 매니저 설정 등

**Examples**:

```bash
feat: Add plant growth animation to garden screen
fix: Resolve crash when loading repositories with no commits
docs: Update README with Firebase setup instructions
refactor: Extract plant rendering logic to separate widget
```

### PR 가이드라인

**PR 제목**: `[Type] Brief description`

- 예: `[Feat] Add plant encyclopedia feature`
- 예: `[Fix] Resolve token refresh issue`

**PR 설명 템플릿**:

```markdown
## 변경 사항

- 주요 변경 내용을 bullet point로 작성

## 스크린샷 (UI 변경 시)

- Before/After 스크린샷 첨부

## 테스트

- [ ] 로컬 테스트 완료
- [ ] 빌드 에러 없음
- [ ] Lint 경고 없음

## 관련 이슈

- Closes #이슈번호 (있는 경우)
```

### 코드 스타일

- **로깅**: `debugPrint()` 사용 (안드로이드 로그 잘림 방지)
- **리소스 참조**: `flutter_gen` 생성 변수 사용 (`Assets.images.plants.blueberry` 등)
- **주석**: 영어로 작성, 코드만 보고 이해 가능하도록 간결하게
- **Linting**: `pedantic_mono` 규칙 준수

## ⚠️ 보안 참고사항

이 프로젝트는 개인 토이 프로젝트입니다.

- **Firebase 설정**: `google-services.json`은 프로젝트 설정이 포함되어 `.gitignore`에 포함 필수
  - API 키 자체는 공개 가능하지만 ([Firebase 문서](https://firebase.google.com/docs/projects/api-keys)), 설정 파일 전체는 공개 금지
  - 이유: 프로젝트 구조 노출, quota 남용 가능성, Security Rules 우회 시도
  - 환경별(dev/prod) 설정 분리 권장
- **GitHub Token**:
  - 일반 사용: 앱 내에서 PAT 입력 → `flutter_secure_storage`에 암호화 저장
  - 개발 환경 (선택): `.env` 파일에 `GITHUB_TOKEN` 설정 (Debug 모드만 자동 로드)
  - `.env` 파일은 절대 커밋 금지

## 라이센스

MIT
