# ForestScreen 위젯 구조

ForestScreen에서 추출한 위젯들을 담고 있는 디렉토리입니다.

## 파일 목록

| 파일명 | 역할 |
|--------|------|
| `forest_header.dart` | 헤더 컨테이너 (사용자 정보 + 액션 버튼 묶음) |
| `forest_user_info_section.dart` | 사용자명 표시 |
| `forest_update_time_text.dart` | 마지막 업데이트 시간 표시 |
| `forest_sort_button.dart` | 레포지토리 정렬 팝업 메뉴 |
| `forest_logout_button.dart` | 로그아웃 버튼 (확인 다이얼로그 포함) |
| `forest_garden_button.dart` | 가든 화면 이동 버튼 |
| `forest_empty_state.dart` | 레포지토리 없음 상태 표시 |
| `forest_error_state.dart` | 에러 상태 표시 |
| `forest_loading_widget.dart` | 로딩 상태 표시 |
| `encyclopedia_button.dart` | 백과사전 이동 버튼 |
| `repo_count_badge.dart` | 레포지토리 개수 뱃지 |
| `repository_card.dart` | 레포지토리 카드 (그리드 아이템) |

**관련 파일** (다른 디렉토리):
- `lib/features/contact/widgets/contact_button.dart` - 연락처 버튼

## 위젯 트리 구조

```
ForestScreen
└── Scaffold
    └── Container (배경)
        └── SafeArea
            └── AsyncValue.when
                └── Column
                    ├── ForestHeader
                    │   ├── ForestUserInfoSection
                    │   ├── ForestUpdateTimeText
                    │   ├── ForestSortButton
                    │   ├── EncyclopediaButton
                    │   ├── ForestLogoutButton
                    │   ├── ForestGardenButton
                    │   └── RepoCountBadge
                    │
                    ├── ContactButton
                    │
                    └── GridView (레포지토리 목록)
                        ├── RepositoryCard
                        ├── RepositoryCard
                        └── ...
```

## 리팩토링 전후 비교

### Before (단일 파일 832줄)

```dart
class ForestScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Column(
            children: [
              // 헤더 코드 100줄 이상
              Container(
                child: Row(
                  children: [
                    // 사용자 정보: 30줄
                    // 정렬 버튼: 50줄
                    // 백과사전 버튼: 20줄
                    // 로그아웃 버튼: 40줄
                    // ... 계속
                  ],
                ),
              ),
              // 연락처 버튼: 50줄
              // 레포지토리 그리드: 100줄
            ],
          ),
        ),
      ),
    );
  }
}
```

### After (모듈화된 위젯)

```dart
class ForestScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Column(
            children: [
              ForestHeader(...),      // 헤더 위젯
              ContactButton(...),     // 연락처 버튼 위젯
              _buildRepositoryGrid(), // 레포지토리 그리드
            ],
          ),
        ),
      ),
    );
  }
}
```

## 핵심 Flutter 개념

### 1. 위젯 타입

| 타입 | 설명 | 사용 시점 |
|------|------|-----------|
| `StatelessWidget` | 상태 없음, 부모가 rebuild될 때 같이 rebuild | 정적 UI |
| `StatefulWidget` | 자체 상태 보유, 스스로 rebuild 가능 | 동적 UI |
| `ConsumerWidget` | Riverpod Provider 구독 가능 | Provider 데이터 사용 시 |

### 2. 생성자 파라미터

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({
    required this.title,    // 필수: 반드시 전달해야 함
    this.subtitle,          // 선택: null 가능
    this.onTap,             // 선택: 콜백
    super.key,              // 항상 super에 전달
  });

  final String title;       // 필수: non-nullable
  final String? subtitle;   // 선택: nullable
  final VoidCallback? onTap; // 선택: 콜백
}
```

### 3. 콜백 타입

| 타입 | 시그니처 | 설명 |
|------|----------|------|
| `VoidCallback` | `() => void` | 파라미터 없음, 반환값 없음 |
| `ValueChanged<T>` | `(T value) => void` | 파라미터 1개, 반환값 없음 |
| Custom | `void Function(int, String)` | 직접 정의 |

### 4. const 생성자 장점

- **성능**: 위젯 재사용으로 불필요한 rebuild 방지
- **컴파일 타임 상수**: 컴파일 시점에 객체 생성
- **Best Practice**: 불변 위젯에 권장

## 흔한 실수

### 1. `super.key` 누락

```dart
// Bad
const MyWidget({required this.title});

// Good
const MyWidget({required this.title, super.key});
```

### 2. 콜백 nullable 처리 안 함

```dart
// Bad - 항상 콜백을 전달해야 함
final VoidCallback onTap;

// Good - 콜백 선택적
final VoidCallback? onTap;
```

### 3. null 체크 누락

```dart
// Bad - username이 null이면 에러
Text(username)

// Good
Text(username ?? 'Guest')
```

### 4. const 미사용

```dart
// Bad - 불필요하게 매번 rebuild
class MyWidget extends StatelessWidget {
  MyWidget({super.key});
}

// Good - 재사용 가능
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
}
```

## Props Drilling vs ConsumerWidget

### Props Drilling (안티패턴)

데이터를 여러 계층의 위젯을 거쳐 전달하는 방식:

```dart
// 부모 → 자식 → 손자 → 증손자로 계속 전달해야 함
ForestScreen(token: token)
  → ForestHeader(token: token)
    → RepositoryCard(token: token)
      → CardButton(token: token)  // 여기서만 사용
```

### ConsumerWidget (권장)

필요한 위젯에서 직접 Provider 구독:

```dart
// CardButton에서 직접 Provider 접근
class CardButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(tokenProvider);
    // token 사용
  }
}
```

**장점**:
- 중간 위젯들이 불필요한 파라미터를 전달할 필요 없음
- 코드가 깔끔해짐
- 상태 변경 시 필요한 위젯만 rebuild
