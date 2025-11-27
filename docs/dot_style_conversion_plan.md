# 🎮 Repo Arborist 도트 스타일 전환 계획서

> **목표**: 프로젝트의 모든 비주얼 에셋을 도트(픽셀아트) 스타일로 전환하여 레트로 감성 강화

---

## 📋 1. 교체할 이미지 에셋 목록

### 🌱 A. 나무 - 새싹 단계 (Sprout) - 2개
| 파일명 | 경로 | 크기 | 우선순위 |
|--------|------|------|----------|
| `sprout.svg` | `assets/images/trees/` | 87x100px | ⭐⭐⭐ 필수 |
| `cactus_sprout.svg` | `assets/images/trees/` | 87x100px | ⭐⭐ 중요 |

**사용 위치**:
- [forest_screen.dart:613](../lib/features/github/screens/forest_screen.dart#L613)
- [garden_overview_screen.dart:592](../lib/features/github/screens/garden_overview_screen.dart#L592)
- [forest_loading_widget.dart:322](../lib/features/github/widgets/forest_loading_widget.dart#L322)

---

### 🌸 B. 나무 - 꽃 단계 (Bloom) - 6개
| 파일명 | 경로 | 크기 | 색상 | 우선순위 |
|--------|------|------|------|----------|
| `bloom_yellow.svg` | `assets/images/trees/` | 80x80px | 노랑 | ⭐⭐⭐ 필수 |
| `bloom_blue.svg` | `assets/images/trees/` | 80x80px | 파랑 | ⭐⭐⭐ 필수 |
| `bloom_orange.svg` | `assets/images/trees/` | 80x80px | 주황 | ⭐⭐⭐ 필수 |
| `bloom_pink.svg` | `assets/images/trees/` | 80x80px | 분홍 | ⭐⭐⭐ 필수 |
| `bloom_purple.svg` | `assets/images/trees/` | 80x80px | 보라 | ⭐⭐ 중요 |
| `cactus_bloom.svg` | `assets/images/trees/` | 80x80px | 선인장 | ⭐⭐ 중요 |

**사용 위치**:
- [forest_screen.dart:616](../lib/features/github/screens/forest_screen.dart#L616)
- [garden_overview_screen.dart:595-598](../lib/features/github/screens/garden_overview_screen.dart#L595-L598)
- [forest_loading_widget.dart:336](../lib/features/github/widgets/forest_loading_widget.dart#L336)

---

### 🌳 C. 나무 - 성장 완료 단계 (Tree) - 4개
| 파일명 | 경로 | 크기 | 포맷 | 우선순위 |
|--------|------|------|------|----------|
| `maple.png` | `assets/images/trees/` | 87x100px | PNG | ⭐⭐⭐ 필수 |
| `tree_green.svg` | `assets/images/trees/` | 87x100px | SVG | ⭐ 선택 (미사용) |
| `tree_red.svg` | `assets/images/trees/` | 87x100px | SVG | ⭐ 선택 (미사용) |
| `cactus_tree.svg` | `assets/images/trees/` | 87x100px | SVG | ⭐⭐ 중요 |

**사용 위치**:
- [forest_screen.dart:619](../lib/features/github/screens/forest_screen.dart#L619) - `maple.png`
- [garden_overview_screen.dart:603](../lib/features/github/screens/garden_overview_screen.dart#L603) - `maple.png`
- [forest_loading_widget.dart:350](../lib/features/github/widgets/forest_loading_widget.dart#L350) - `maple.png`

**⚠️ 참고**: `tree_green.svg`, `tree_red.svg`는 코드에서 사용되지 않음. 향후 확장용으로 제작 가능.

---

### ✨ D. 효과 이미지 - 1개
| 파일명 | 경로 | 크기 | 용도 | 우선순위 |
|--------|------|------|------|----------|
| `tree_glow-56586a.png` | `assets/images/playground/` | 312px | 빛 효과 | ⭐⭐⭐ 필수 |

**사용 위치**:
- [playground_screen.dart:61](../lib/features/playground/screens/playground_screen.dart#L61)

---

### 🏞️ E. 배경/필드 에셋 - 신규 제작

#### E-1. 땅 텍스처 (신규)
| 파일명 | 경로 | 크기 | 용도 | 우선순위 |
|--------|------|------|------|----------|
| `ground_texture_dot.png` | `assets/images/backgrounds/` | 64x64px (타일용) | 반복 배경 | ⭐⭐⭐ 필수 |

**사용 위치**:
- [garden_overview_screen.dart:146-150](../lib/features/github/screens/garden_overview_screen.dart#L146-L150) - 현재 단색 `#5D4E37`

**제작 가이드**:
- 64x64px 도트 타일 패턴
- 기본 색상: 진한 갈색 `#5D4E37`
- 반복 배치 가능하도록 심리스(seamless) 디자인

#### E-2. 땅바닥 원형 그림자 (선택 - 코드 수정)
**현재 방식**: RadialGradient로 동적 생성 (5가지 색상)
**도트 방식**:
- 옵션 A: 5개 PNG 파일 (나이별)
- 옵션 B: CustomPainter로 도트 패턴 그리기 (추천)

**나이별 색상**:
```
< 1년: #8B7355  // 밝은 갈색/연두
1-2년: #7A6F5D  // 중간 밝은 갈색
2-3년: #6B5D4F  // 중간 갈색
3-5년: #5D4E37  // 어두운 갈색
5년+:  #4A3C28  // 매우 어두운 갈색
```

---

## 📊 2. 에셋 제작 우선순위 정리

### ⭐⭐⭐ 최우선 (Phase 1) - 8개
```
1. sprout.svg              → sprout_dot.png/svg
2. bloom_yellow.svg        → bloom_yellow_dot.png/svg
3. bloom_blue.svg          → bloom_blue_dot.png/svg
4. bloom_orange.svg        → bloom_orange_dot.png/svg
5. bloom_pink.svg          → bloom_pink_dot.png/svg
6. maple.png               → maple_dot.png
7. tree_glow-56586a.png    → tree_glow_dot.png
8. ground_texture_dot.png  → (신규 제작)
```

### ⭐⭐ 중요 (Phase 2) - 4개
```
9.  cactus_sprout.svg      → cactus_sprout_dot.png/svg
10. cactus_bloom.svg       → cactus_bloom_dot.png/svg
11. cactus_tree.svg        → cactus_tree_dot.png/svg
12. bloom_purple.svg       → bloom_purple_dot.png/svg
```

### ⭐ 선택 (Phase 3) - 2개
```
13. tree_green.svg         → tree_green_dot.png/svg (미사용)
14. tree_red.svg           → tree_red_dot.png/svg (미사용)
```

**총 제작 필요**: 최소 8개 (Phase 1) ~ 최대 14개 (전체)

---

## 🛠️ 3. 코드 수정 사항

### 3-1. 이미지 경로 업데이트

**수정할 파일 목록**:
1. `lib/features/github/screens/forest_screen.dart`
2. `lib/features/github/screens/garden_overview_screen.dart`
3. `lib/features/github/widgets/forest_loading_widget.dart`
4. `lib/features/github/screens/repository_detail_screen.dart`
5. `lib/features/playground/screens/playground_screen.dart`

**변경 예시**:
```dart
// 변경 전
'assets/images/trees/sprout.svg'

// 변경 후
'assets/images/trees/sprout_dot.png'  // 또는 .svg
```

### 3-2. 배경 텍스처 적용 (garden_overview_screen.dart)

**변경 전** (단색 배경):
```dart
Container(
  decoration: const BoxDecoration(
    color: Color(0xFF5D4E37), // 진한 갈색 (흙 느낌)
  ),
),
```

**변경 후** (도트 텍스처):
```dart
Container(
  decoration: const BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/backgrounds/ground_texture_dot.png'),
      repeat: ImageRepeat.repeat,
    ),
  ),
),
```

### 3-3. pubspec.yaml 업데이트

```yaml
flutter:
  assets:
    # 기존
    - assets/images/trees/
    - assets/images/playground/

    # 신규 추가
    - assets/images/backgrounds/
```

---

## 🎨 4. 디자인 가이드라인

### 픽셀아트 스타일 규칙
- **해상도**: 원본 크기 유지 (SVG → PNG 변환)
- **픽셀 크기**: 4x4px 또는 8x8px 그리드 권장
- **색상**: 기존 색상 팔레트 유지 (노랑, 파랑, 주황, 분홍, 보라)
- **안티앨리어싱**: 사용하지 않음 (Sharp Edge)
- **외곽선**: 1-2px 검은 테두리 권장

### 나무 단계별 특징
```
새싹 (Sprout):
- 작고 귀여운 모습
- 2-3개 잎
- 얇은 줄기

꽃 (Bloom):
- 중간 크기
- 꽃잎 5-8개
- 색상별 다양성

나무 (Tree):
- 가장 큰 크기
- 나뭇가지와 잎 풍성
- 단풍나무 느낌 (maple)
```

### 선인장 시리즈 특징
```
- 둥근 선인장 몸통
- 작은 가시 표현
- 꽃 단계에서 상단에 꽃 추가
```

---

## 📝 5. 작업 체크리스트

### Phase 1: 핵심 에셋 제작 (8개)
- [ ] `sprout_dot.png` 제작
- [ ] `bloom_yellow_dot.png` 제작
- [ ] `bloom_blue_dot.png` 제작
- [ ] `bloom_orange_dot.png` 제작
- [ ] `bloom_pink_dot.png` 제작
- [ ] `maple_dot.png` 제작
- [ ] `tree_glow_dot.png` 제작
- [ ] `ground_texture_dot.png` 제작 (신규)

### Phase 2: 코드 수정
- [ ] `forest_screen.dart` 경로 업데이트
- [ ] `garden_overview_screen.dart` 경로 업데이트
- [ ] `forest_loading_widget.dart` 경로 업데이트
- [ ] `repository_detail_screen.dart` 경로 업데이트
- [ ] `playground_screen.dart` 경로 업데이트
- [ ] 배경 텍스처 코드 적용
- [ ] `pubspec.yaml` 에셋 등록

### Phase 3: 테스트
- [ ] 각 화면 이미지 로드 확인
- [ ] 배경 타일링 확인
- [ ] 애니메이션 동작 확인
- [ ] 다양한 화면 크기 테스트

### Phase 4: 선택 에셋 (4개)
- [ ] `cactus_sprout_dot.png` 제작
- [ ] `cactus_bloom_dot.png` 제작
- [ ] `cactus_tree_dot.png` 제작
- [ ] `bloom_purple_dot.png` 제작

---

## 🗂️ 6. 파일 구조

### 변경 전
```
assets/
├── images/
│   ├── trees/
│   │   ├── sprout.svg
│   │   ├── bloom_*.svg (6개)
│   │   ├── maple.png
│   │   ├── tree_*.svg (3개)
│   │   └── cactus_*.svg (3개)
│   └── playground/
│       └── tree_glow-56586a.png
```

### 변경 후
```
assets/
├── images/
│   ├── trees/
│   │   ├── sprout_dot.png
│   │   ├── bloom_*_dot.png (6개)
│   │   ├── maple_dot.png
│   │   ├── tree_*_dot.png (3개)
│   │   └── cactus_*_dot.png (3개)
│   ├── playground/
│   │   └── tree_glow_dot.png
│   └── backgrounds/          # 신규
│       └── ground_texture_dot.png
```

---

## 🎯 7. 예상 효과

### 시각적 변화
- ✅ 레트로/픽셀아트 감성 강화
- ✅ 일관된 비주얼 스타일
- ✅ 개발자 친화적 분위기 (GitHub 타겟층)

### 기술적 이점
- ✅ PNG 최적화로 파일 크기 감소 가능
- ✅ 도트 스타일로 스케일링 시 품질 저하 최소화
- ✅ 타일링 배경으로 메모리 효율 향상

---

## 📌 8. 참고사항

### SVG vs PNG 선택
- **PNG 권장**: 픽셀아트는 래스터 기반이므로 PNG가 더 적합
- **크기**: 원본과 동일하게 유지 (87x100px, 80x80px 등)
- **포맷**: 24비트 PNG (투명도 포함)

### 기존 파일 유지
- 원본 SVG/PNG 파일은 삭제하지 말고 백업
- `_old` 폴더에 보관하거나 Git 히스토리 활용

### 네이밍 규칙
- `*_dot.png` 또는 `*_pixel.png`
- 일관성 있게 `_dot` 사용 권장

---

## 🚀 9. 시작 가이드

### 1단계: 에셋 제작
1. 픽셀아트 툴 준비 (Aseprite, Piskel, Photoshop 등)
2. Phase 1 에셋 8개 제작
3. `assets/images/` 하위 폴더에 배치

### 2단계: 코드 수정
```bash
# 파일 내 경로 일괄 변경 (예시)
# forest_screen.dart, garden_overview_screen.dart 등 수정
```

### 3단계: 테스트
```bash
fvm flutter run
```

### 4단계: 최종 확인
- [ ] 모든 화면 정상 작동
- [ ] 이미지 깨짐 없음
- [ ] 배경 타일링 자연스러움

---

**작성일**: 2025-11-20
**버전**: 1.0
**담당**: Repo Arborist Team
