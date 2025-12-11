# CONTEXT.md

This document contains comprehensive project information, including architecture, features, technical decisions, and issue resolutions.

---

## Project Overview

**Project Name:** Repo Arborist (blueberry_template)
**Description:** A Flutter application that visualizes GitHub repositories as living trees in a personal forest
**Concept:** Transform repository statistics (commits, PRs, activity) into interactive pixel-art trees with 11 plant types, 3 growth stages, and 4 activity tiers

**Key Features:**
- Dual authentication (GitHub Token / Public Username)
- Repository visualization as pixel-art plants
- Activity-based visual effects (glow, saturation, animations)
- Interactive garden view with parallax scrolling
- Repository detail screens with commit/PR timeline

---

## Project Structure

```
blueberry_template/
├── lib/
│   ├── core/                    # Global controllers, themes, services, widgets
│   │   ├── controllers/         # ThemeController
│   │   ├── services/            # CacheService, LocalCacheService, FirestoreCacheService
│   │   ├── theme/              # AppTheme, AppColors
│   │   └── widgets/            # Reusable UI components
│   ├── features/               # Feature-based modules
│   │   ├── github/             # Main feature: GitHub repository visualization
│   │   │   ├── controllers/    # GitHubAuthController, ForestController
│   │   │   ├── models/         # GithubUserModel, RepositoryStatsModel, PlantType
│   │   │   ├── repositories/   # GitHubRepository, GitHubUserRepository
│   │   │   ├── screens/        # Login, Forest, Garden, Detail screens
│   │   │   └── widgets/        # ForestLoadingWidget, etc.
│   │   ├── todo/               # Sample feature for reference
│   │   └── playground/         # UI component testing area
│   ├── gen/                    # Auto-generated code (flutter_gen)
│   ├── firebase_options.dart   # Firebase configuration
│   ├── setup.dart              # App initialization (Firebase, Hive, Firestore)
│   └── main.dart               # App entry point
├── assets/
│   ├── images/
│   │   ├── plants/             # 33 plant images (11 types × 3 stages)
│   │   └── etc/                # Backgrounds, effects, decorations
│   └── translations/           # ko.json, en.json
├── docs/                       # Project documentation
├── CONTEXT/                    # This file
└── pubspec.yaml               # Dependencies and configuration
```

---

## Architecture & Technical Stack

### State Management: Riverpod

**Key Controllers:**
- [ThemeController](../lib/core/controllers/theme_controller.dart) - Theme toggle (Light/Dark)
- [GitHubAuthController](../lib/features/github/controllers/github_auth_controller.dart) - Authentication state
- [ForestController](../lib/features/github/controllers/forest_controller.dart) - Repository statistics

**Pattern:** AsyncNotifierProvider with `AsyncValue.guard()` for error handling

### Backend & Caching

**Firebase Integration:**
- Firebase Core, Crashlytics (enabled)
- Firestore caching (optional, 10-second timeout)
- Fallback to Hive local cache

**Caching Strategy:**
- Primary: Hive local storage (key-value)
- Secondary: Firestore (optional remote cache)
- Cache duration: 24 hours for repository stats
- See [LocalCacheService](../lib/core/services/local_cache_service.dart:1), [FirestoreCacheService](../lib/core/services/firestore_cache_service.dart:1)

### Navigation Flow

```
GithubLoginScreen (initial)
    ↓ (on login)
ForestLoadingWidget (transition)
    ↓ (data loaded)
GardenOverviewScreen (main view - interactive garden with parallax)
    ↔ ForestScreen (grid view - framed repositories)
        ↓ (tap repository)
    RepositoryDetailScreen (stats, commits, PRs)
```

**Implementation:** Direct `MaterialPageRoute` navigation (no named routes)

---

## Key Features & Screens

### 1. GitHub Authentication ([GithubLoginScreen](../lib/features/github/screens/github_login_screen.dart:1))

**Two Auth Modes:**
- **Public Username:** View public repositories only (60 API calls/hour)
- **GitHub Token:** Access private repos + higher rate limit (5,000 calls/hour)

**Implementation:** [GitHubAuthController](../lib/features/github/controllers/github_auth_controller.dart:1)

### 2. Repository Visualization

**Plant Type System (11 families):**
- Mapped by programming language (see [PlantType enum](../lib/features/github/models/repository_stats_model.dart:370))
- Coffee (Java), Ginkgo (JavaScript), Snake Plant (Python), Fir (C/C++), Blossom (Swift), Bamboo (Go), Oak (C#/General), Maple (Ruby/HTML), Cactus (Shell/DevOps), Blueberry (Dart), Pine (Assembly)
- Each type has unique color palette and image path

**Growth Stages (3 levels):**
- **Sprout:** projectSizeScore < 50
- **Bloom:** 50 ≤ score < 150 (4 variants)
- **Tree:** score ≥ 150 (2 variants)
- Score calculation: `(commits × 1) + (PRs × 3)`

**Activity Tiers (4 levels):**
- **Fresh:** ≤7 days (saturation 1.0, glow 0.8, scale 1.05)
- **Warm:** 8-30 days (saturation 1.0, glow 0.3)
- **Cooling:** 31-180 days (saturation 0.7, no glow)
- **Dormant:** ≥181 days (saturation 0.5, scale 0.95)

**See:** [RepositoryStatsModel](../lib/features/github/models/repository_stats_model.dart:1) for full logic

### 3. Garden Overview ([GardenOverviewScreen](../lib/features/github/screens/garden_overview_screen.dart:1))

**Visual Features:**
- Parallax background (sky + ground tiles)
- Swaying tree animations
- InteractiveViewer (zoom/pan)
- Activity-based glow effects
- Hedge borders (pixel art aesthetic)

**Used Assets:**
- bg_cloud_sky.png (repeating sky)
- square_groudtile_dot.png (repeating ground)
- garden_border_hedge.png (top/bottom borders)
- plant_shadow.png, sprout_shadow.png
- sparkling_effect_sprite_dot.png (Warm tier)
- fresh_effect_sprite_dot.png (Fresh tier)

### 4. Forest Screen ([ForestScreen](../lib/features/github/screens/forest_screen.dart:1))

**Layout:**
- Single-column grid view
- Custom oak frame overlay per repository
- signpost_empty.png for repository names
- Logout functionality

### 5. Repository Detail ([RepositoryDetailScreen](../lib/features/github/screens/repository_detail_screen.dart:1))

**Information Displayed:**
- Repository statistics (commits, PRs, language)
- Recent commits timeline
- Recent merged PRs
- Top contributors
- Tree visualization with activity glow

---

## Core Models & Services

### Models

**[RepositoryStatsModel](../lib/features/github/models/repository_stats_model.dart:1)** (Most Complex)
- Aggregates repository data for visualization
- Computed properties: `projectSizeScore`, `treeStage`, `activityTier`, `plantType`, `variantIndex`
- Contains all visualization logic

**[GithubUserModel](../lib/features/github/models/github_user_model.dart:1)**
- User authentication data

**[GithubRepositoryModel](../lib/features/github/models/github_repository_model.dart:1)**
- Basic repository metadata

**[CommitModel](../lib/features/github/models/commit_model.dart:1)**, **[PullRequestModel](../lib/features/github/models/pull_request_model.dart:1)**
- Activity timeline data

### Services & Repositories

**[GitHubRepository](../lib/features/github/repositories/github_repository.dart:1)** (Core API Layer)
- Base URL: `https://api.github.com`
- Timeout: 30 seconds
- Cache duration: 24 hours
- Key methods: `getUserRepositories()`, `getRepositoryStats()`, `getAllRepositoryStats()`, `getRecentCommits()`, `getRecentMergedPRs()`
- Caching strategy: Try cache first (5s timeout) → fallback to API → save to cache

**[CacheService](../lib/core/services/cache_service.dart:1)** (Interface)
- Abstract interface for caching implementations
- Methods: get, set, delete, clear, getJson, setJson

**[LocalCacheService](../lib/core/services/local_cache_service.dart:1)** (Hive Implementation)
- Singleton pattern
- Boxes: cache_box (data), cache_meta_box (TTL metadata)

**[FirestoreCacheService](../lib/core/services/firestore_cache_service.dart:1)** (Firestore Implementation)
- Collection: cache_data
- 10-second timeout for offline handling

---

## Asset Management

**Asset Generation:** flutter_gen for type-safe access
**Generated Code:** [lib/gen/assets.gen.dart](../lib/gen/assets.gen.dart:1)
**Usage:** `Assets.images.plants.treeBlueberryDot.path`

**Plant Asset Naming Convention:**
```
{stage}_{plantType}_dot.png
Examples: sprout_blueberry_dot.png, flower_coffee_dot.png, tree_ginkgo_dot.png
```

**Image Formats:**
- PNG for pixel art (all plant and UI images)
- SVG for backup/legacy assets

**Flutter Rendering Settings:**
```dart
Image.asset(
  Assets.images.plants.sproutBlueberryDot.path,
  filterQuality: FilterQuality.none,  // Sharp pixel art rendering
)
```

---

## Configuration & Environment

**Flutter Version:** Managed by FVM (3.35.6)
**Material Design:** Material 3 enabled
**Localization:** easy_localization (Korean default, English fallback)
**Environment Variables:** .env file (GitHub token, etc.)

**Theme:**
- Light/Dark mode support (default: Dark)
- Custom AppColors ThemeExtension
- Teal accent color (#14B8A6)

**Code Quality:**
- pedantic_mono lint rules
- English-only comments (Public Repository standard)
- debugPrint() preferred over conditional print()

---

## Dependencies Summary

**Core:**
- flutter_riverpod: State management
- google_fonts: Typography
- easy_localization: i18n (ko/en)

**Firebase:**
- firebase_core, firebase_crashlytics, cloud_firestore

**Networking & Caching:**
- http: GitHub API client
- hive, hive_flutter: Local storage

**Assets:**
- flutter_svg: SVG rendering
- flutter_gen_runner: Asset code generation

---

## 🎨 이미지 투명 배경 처리 (PNG 투명도 문제)

### 문제 상황

- 도트 스타일 PNG 이미지를 추가했는데 배경이 투명하지 않고 **희끄무리한 회색/흰색 체크무늬 패턴**이 보임
- Flutter 앱에서 이미지 뒤에 투명 격자가 그대로 표시됨
- 앱 배경색과 이미지가 자연스럽게 블렌딩되지 않음

### 원인

1. PNG 파일이 **RGB 모드**로 저장되어 알파 채널(투명도)이 없음
2. **더 심각한 문제**: 이미지 제작 시 투명도 표시용 체크무늬가 **실제 픽셀로 포함되어 저장됨**
   - 이미지 편집 툴의 투명 배경 표시 격자가 실제 이미지 데이터에 포함됨
   - RGBA로 변환해도 체크무늬는 그대로 남아있음

```bash
# 문제 있는 파일
PNG image data, 1024 x 1024, 8-bit/color RGB, non-interlaced  # ❌ RGB (투명도 없음)

# RGBA로 변환해도 체크무늬는 여전히 보임
PNG image data, 1024 x 1024, 8-bit/color RGBA, non-interlaced  # ⚠️ 체크무늬 포함
```

### 해결 방법

**⚠️ 중요**: 단순 RGBA 변환만으로는 해결 안 됨! 체크무늬가 실제 픽셀로 포함되어 있어서 **밝은 배경색을 완전히 제거**해야 함.

#### 방법 1: Python + PIL/Numpy로 밝은 배경 완전 제거 (✅ 최종 해결책)

**필요 패키지:**

```bash
pip install pillow numpy
```

**스크립트: `clean_background.py`**

```python
import numpy as np
from PIL import Image
import sys
import codecs

# UTF-8 출력 설정 (Windows)
if sys.platform == 'win32':
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')

def remove_all_light_backgrounds(input_path, output_path, threshold=180):
    """밝은 배경색을 모두 투명하게 제거 (격자 완전 제거)"""
    try:
        # RGBA로 열기
        img = Image.open(input_path).convert("RGBA")
        data = np.array(img)

        # RGB 채널 분리
        r, g, b, a = data.T

        # 밝기 계산 (RGB 평균)
        brightness = (r.astype(float) + g.astype(float) + b.astype(float)) / 3

        # 밝기가 threshold 이상인 픽셀을 투명하게
        # (체크무늬의 흰색/회색 영역 제거)
        light_mask = brightness > threshold
        data[..., 3][light_mask.T] = 0

        # 저장
        result_img = Image.fromarray(data)
        result_img.save(output_path)
        print(f"✅ 저장: {output_path}")
        return True

    except Exception as e:
        print(f"❌ 에러: {e}")
        return False

if __name__ == "__main__":
    # 파일 처리
    files = [
        ('sprout_dot.png', 'sprout_dot_clean.png'),
        ('bloom_orange_dot.png', 'bloom_orange_dot_clean.png'),
        ('bloom_purple_dot.png', 'bloom_purple_dot_clean.png'),
    ]

    for input_file, output_file in files:
        print(f"처리: {input_file}")
        remove_all_light_backgrounds(input_file, output_file, threshold=180)
```

**실행:**

```bash
cd assets/images/trees
python clean_background.py

# 원본 백업 후 교체
mv sprout_dot.png sprout_dot_old.png
mv sprout_dot_clean.png sprout_dot.png
# 나머지 파일도 동일하게...
```

**핵심 원리:**

- 밝기(RGB 평균)가 180 이상인 모든 픽셀을 투명하게 처리
- 체크무늬의 흰색(`255, 255, 255`)과 회색(`204, 204, 204`) 영역이 모두 제거됨
- 색상이 있는 픽셀(나무, 흙)과 검은 외곽선만 남음

**threshold 값 조정:**

- `threshold=180`: 밝은 배경 제거 (기본값)
- `threshold=200`: 매우 밝은 색만 제거 (보수적)
- `threshold=150`: 중간 밝기까지 제거 (공격적, 색상 손실 주의)

---

#### 방법 2: ImageMagick으로 배경 투명하게 변환 (⚠️ 체크무늬 포함 시 불충분)

**ImageMagick 설치 확인:**

```bash
magick --version
# 또는
where magick
```

**흰색 배경을 투명하게 변환:**

```bash
cd assets/images/trees

# 단일 파일 변환
magick sprout_dot.png -fuzz 10% -transparent white sprout_dot_fixed.png

# 원본 교체
mv sprout_dot.png sprout_dot_backup.png
mv sprout_dot_fixed.png sprout_dot.png
```

**옵션 설명:**

- `-fuzz 10%`: 10% 오차 범위까지 흰색으로 인식 (안티앨리어싱 처리)
- `-transparent white`: 흰색을 투명하게 변환
- `white` 대신 다른 색상 지정 가능 (예: `#FFFFFF`, `gray`)

**여러 파일 일괄 변환:**

```bash
cd assets/images/trees

# 모든 _dot.png 파일 변환
for file in *_dot.png; do
  magick "$file" -fuzz 10% -transparent white "${file%.png}_fixed.png"
done

# 원본 백업 후 교체
for file in *_dot.png; do
  mv "$file" "${file%.png}_backup.png"
  mv "${file%.png}_fixed.png" "$file"
done
```

#### 변환 결과 확인

```bash
file sprout_dot.png
# 출력: PNG image data, 1024 x 1024, 8-bit/color RGBA, non-interlaced  ✅ RGBA
```

**시각적 확인:**

- 이미지를 열었을 때 체크무늬 패턴이 완전히 사라짐
- 나무/식물 픽셀과 검은 외곽선만 보임
- 배경이 완전히 투명함

**Flutter 앱에서 확인:**

- Hot Restart (`R`) 후 앱 배경색과 자연스럽게 블렌딩
- 체크무늬가 보이지 않음

---

### Flutter 코드에서 투명 PNG 최적 설정

도트 스타일 이미지(픽셀아트)는 안티앨리어싱을 끄는 것이 좋습니다:

```dart
Image.asset(
  'assets/images/trees/sprout_dot.png',
  fit: BoxFit.contain,
  filterQuality: FilterQuality.none,  // 픽셀아트 날카로운 표현
)
```

**`FilterQuality.none` 효과:**

- 안티앨리어싱 제거 → 픽셀이 날카롭게 표현
- 투명 배경이 깨끗하게 유지됨
- 도트/픽셀아트 특유의 느낌 유지

---

### 주의사항

1. **Hot Reload vs Hot Restart**

   - 이미지 파일 교체 후: **Hot Restart** (`R` 대문자) 필요
   - Hot Reload (`r`)로는 에셋 변경사항이 반영 안 됨

2. **원본 백업**

   - 변환 전 원본 파일을 `*_backup.png`로 백업 권장
   - 문제 발생 시 원복 가능

3. **투명도 색상 지정**
   - 흰색이 아닌 다른 배경: `-transparent gray`, `-transparent "#F0F0F0"` 등
   - 여러 색상 제거: 명령어 반복 실행

---

### 대안: 이미지 편집 도구 사용

ImageMagick이 없는 경우:

**온라인 도구:**

- [Remove.bg](https://www.remove.bg/) - AI 배경 제거
- [Online PNG Tools](https://onlinepngtools.com/create-transparent-png)

**오프라인 도구:**

- **Photoshop**: Magic Wand 도구로 배경 선택 → Delete
- **GIMP** (무료): Select by Color → Delete → Export as PNG
- **Aseprite** (픽셀아트 전용): 레이어 투명도 확인 후 재저장

---

## 적용 파일

**코드 수정:**

- `lib/features/github/screens/garden_overview_screen.dart` - `filterQuality: FilterQuality.none` 적용
- `lib/features/github/widgets/forest_loading_widget.dart` - `filterQuality: FilterQuality.none` 적용

**이미지 처리:**

- `assets/images/trees/sprout_dot.png` - 밝은 배경 완전 제거 (threshold=180)
- `assets/images/trees/bloom_orange_dot.png` - 밝은 배경 완전 제거
- `assets/images/trees/bloom_purple_dot.png` - 밝은 배경 완전 제거

**처리 스크립트:**

- `assets/images/trees/clean_background.py` - Python 배경 제거 스크립트

**백업 파일:**

- `*_old.png` - 체크무늬 포함 원본
- `*_v3.png` - 최종 투명 버전

---

## 📋 체크리스트

이미지에 체크무늬/투명 격자가 보이는 경우:

- [ ] 1. Python 환경 확인 (`python --version`)
- [ ] 2. PIL/Numpy 설치 (`pip install pillow numpy`)
- [ ] 3. `clean_background.py` 스크립트 실행
- [ ] 4. 변환된 이미지 시각 확인 (체크무늬 제거됨?)
- [ ] 5. 원본 백업 (`*_old.png`)
- [ ] 6. 파일 교체 (`mv *_clean.png *.png`)
- [ ] 7. Flutter Hot Restart (`R`) - Hot Reload (`r`)는 안 됨!
- [ ] 8. 앱에서 이미지 확인 (투명 배경 정상?)

---

**작성일**: 2025-11-21
**최종 수정**: 2025-11-21
**관련 이슈**: PNG 투명 배경 처리 (체크무늬 격자 제거)
**해결 방법**: Python PIL/Numpy로 밝기 기반 배경 제거 (threshold=180)

CURRENT ASSET USING STATE;

## Asset Usage Summary

### 1. Plant Images (assets/images/plants/)

All plant images are used dynamically through repository_stats_model.dart:370-449 via `PlantType.getImagePath()` method.

**Used in:**

- forest_screen.dart:562 - Forest view (grid layout)
- garden_overview_screen.dart:549 - Garden overview (wrap layout)
- forest_loading_widget.dart:332,347,362 - Loading animation examples

**Plant Types (11 types x 3 stages = 33 images):**

- **Sprout Stage:** bamboo, blossom, blueberry, cactus, coffee, fir, ginkgo, maple, oak, pine, snake_plant
- **Bloom Stage:** bamboo, blossom, blueberry, cactus, coffee, fir, ginkgo, maple, oak, pine, snake_plant
- **Tree Stage:** bamboo, blossom, blueberry, cactus, coffee, fir, ginkgo, maple, oak, pine, snake_plant

### 2. Background & Environment (assets/images/etc/)

| Asset                        | Usage                              | Location                            |
| ---------------------------- | ---------------------------------- | ----------------------------------- |
| **bg_cloud_sky.png**         | Sky background pattern (repeating) | garden_overview_screen.dart:88      |
| **square_groudtile_dot.png** | Ground tile pattern (repeating)    | garden_overview_screen.dart:104     |
| **garden_border_hedge.png**  | Top and bottom garden borders      | garden_overview_screen.dart:131,180 |

### 3. Effects & Decorations (assets/images/etc/)

| Asset                               | Usage                                     | Location                            |
| ----------------------------------- | ----------------------------------------- | ----------------------------------- |
| **plant_shadow.png**                | Shadow for tree & bloom levels            | garden_overview_screen.dart:407,420 |
| **sprout_shadow.png**               | Shadow for sprout level                   | garden_overview_screen.dart:434     |
| **sparkling_effect_sprite_dot.png** | Sparkling effect for "Warm" activity tier | garden_overview_screen.dart:491     |
| **fresh_effect_sprite_dot.png**     | Fresh effect for "Fresh" activity tier    | garden_overview_screen.dart:504     |
| **signpost_empty.png**              | Repository name signpost                  | forest_screen.dart:477              |

### 4. Unused Assets

**Not currently used in code:**

- assets/images/etc/b_16-bit_pixel_art_sea.png
- assets/images/etc/bg_sky_gradient.png
- assets/images/etc/plant_neglected_overlay_sprite.png
- assets/images/etc/sprout_shadow_ver.png
- assets/images/etc/square_groudtile_dot_before.png
- assets/images/etc/square_groudtile_dot_ver1-5.png (5 variants)
- All files in assets/images/backup/ folder

### 5. Other Assets

| Asset                    | Type        | Usage                                                                             |
| ------------------------ | ----------- | --------------------------------------------------------------------------------- |
| **blueberry.svg**        | SVG icon    | Generated in assets.gen.dart (available but not currently used in active screens) |
| **translations/en.json** | Translation | App localization                                                                  |
| **translations/ko.json** | Translation | App localization                                                                  |

## Summary by Screen

**GardenOverviewScreen:**

- 8 assets (backgrounds, borders, shadows, effects)
- 33 plant images (via PlantType.getImagePath)

**ForestScreen:**

- 1 asset (signpost)
- 33 plant images (via PlantType.getImagePath)

**ForestLoadingWidget:**

- 3 plant images (hardcoded examples for loading animation)
