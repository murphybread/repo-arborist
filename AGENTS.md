- If the phrase 'Activate Learning Mode' is present, please partially leave value names, keywords, and logic blank, provide only comments for important sections, and intentionally implement incorrect logic as needed.

- Focus strictly on the modified sections rather than outputting the entire file unless necessary. Omit unchanged imports, standard boilerplate, and irrelevant logic blocks by replacing them with concise placeholders like ... (unchanged imports) ... or ... (existing logic)... to keep the response clean, while including just enough surrounding lines around the modified code to provide context so the exact location of the change is unambiguous.
- After you've modified the file, please let me know which file and which line you modified.
- Normally, use Bash. CMD is the second priority. Only use PowerShell when explicitly requested, because PowerShell often causes encoding errors.
- Maintain a professional tone without emojis in any part of the response. Write all code comments in English Not Korean, adhering to a 'Public Repository' standard. This means comments must be objective and understandable solely based on the file structure and logic, without referencing the current conversation or user context. Keep comments simple.

- Follow a 'Why, What, How' step-by-step approach for each feature. 'How' refers to actual implementation details like logs, commands, or code. Provide full, working code for the specific feature being modified, but summarize unchanged parts to maintain focus. Keep explanations concise.

- Start with a brief, high-level roadmap. Do not detail every future step upfront. Instead, provide detailed specifications and explanations only for the current step. Proceed step-by-step, verify execution and logs before planning the details of the next stage. This prevents invalid assumptions about the environment and avoids wasted effort on future steps.
- Please use the following format for Markdown file links to ensure consistent referencing of specific code segments: [filename:start_line-end_line](relative_path#Lstart_line-Lend_line) [forest_screen.dart:179-244](./lib/features/github/screens/forest_screen.dart#L179-L244)

로그 출력 가이드 (debugPrint)
if (kDebugMode) print() 대신 **debugPrint()**를 사용하여, 불필요한 조건문 없이 코드를 간결하게 유지하세요.
안드로이드에서 긴 로그가 잘리는 현상을 방지하고, 출력 속도를 조절(Throttling)하여 앱 버벅임 없이 안전하게 디버깅할 수 있습니다.

리소스 관리 가이드 (flutter_gen)
이미지 경로를 문자열('assets/...')로 하드코딩하지 말고, **flutter_gen**으로 생성된 변수(Assets.images...)를 사용하세요.
오타 발생 시 실행 전(컴파일 타임)에 즉시 에러를 잡아주며, 자동완성 기능을 통해 개발 속도와 유지보수 효율을 극대화합니다.

---

riverpod 3.0 업데이트 항목

1. Provider 종류 및 Ref의 단순화 (가장 큰 변화)
   가장 혼란스러웠던 여러 종류의 Ref와 Provider 인터페이스가 하나로 합쳐졌습니다.

Ref 단일화: \* 바뀐 점: FutureProviderRef, NotifierProviderRef 같이 세분화된 타입이 사라지고 Ref 하나로 통합되었습니다.

영향: 제네릭(Ref<T>)을 쓸 필요도 없으며, 코드 생성(Code Generation) 시에도 Ref ref만 작성하면 됩니다.

Legacy 이동: \* 바뀐 점: StateProvider, StateNotifierProvider, ChangeNotifierProvider는 더 이상 권장되지 않으며 riverpod/legacy.dart로 옮겨졌습니다.

대체: 모든 상태 관리는 NotifierProvider (비동기는 AsyncNotifierProvider)로 통일되었습니다.

2. Notifier 클래스 구조 통합
   기존에는 상황에 따라 상속받는 클래스가 달랐지만, 이제 하나로 통일되었습니다.

클래스 통합: AutoDisposeNotifier, FamilyNotifier 등이 삭제되고 Notifier 하나만 사용합니다.

인자 전달(Family) 방식 변경:

과거: build(Arg arg) 메서드로 인자를 받음.

현재: **생성자(Constructor)**로 인자를 받고, build()는 인자 없이 정의합니다. (Java의 객체 생성 방식과 유사해짐)

이유: 불필요한 추상 클래스를 줄이고 가독성을 높이기 위함입니다.

3. AsyncValue 및 에러 처리 변경
   데이터를 핸들링하는 방식이 더 엄격하고 명확해졌습니다.

이름 변경: AsyncValue.valueOrNull이 **AsyncValue.value**로 이름이 바뀌었습니다. (기존의 value 속성은 삭제됨)

패턴 매칭: AsyncValue가 sealed class가 되어 switch문 사용 시 모든 케이스(Data, Error, Loading)를 강제적으로 작성해야 합니다.

에러 래핑: 프로바이더에서 발생한 에러는 이제 **ProviderException**에 담겨서 전달됩니다. (원래 에러를 보려면 e.exception으로 접근)

4. 라이프사이클 및 리소스 관리
   앱이 더 똑똑하게 리소스를 관리하도록 기본 동작이 바뀌었습니다.

자동 일시 중지 (Pausing): \* 위젯이 화면에서 보이지 않으면(예: 다른 화면으로 가려짐) 리스너가 자동으로 일시 중지됩니다. 다시 화면에 나타나면 자동으로 재개됩니다.

Ref.mounted 도입: \* 비동기 작업(await) 이후에 프로바이더가 여전히 살아있는지 확인할 수 있는 ref.mounted 속성이 추가되었습니다. (Flutter 위젯의 mounted와 동일한 역할)

Offline Persistence: 프로바이더 상태를 로컬 DB에 자동 저장/복구 (실험적).
Mutations: 버튼 클릭 같은 '행위'의 로딩/성공/실패 상태를 추적하는 전용 객체.
Automatic Retry: 네트워크 에러 시 지수 백오프 알고리즘으로 자동 재시도.
Testing: ProviderContainer.test() 등 테스트를 위한 유틸리티 대거 추가.
