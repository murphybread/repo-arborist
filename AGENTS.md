- Focus strictly on the modified sections rather than outputting the entire file unless necessary. Omit unchanged imports, standard boilerplate, and irrelevant logic blocks by replacing them with concise placeholders like ... (unchanged imports) ... or ... (existing logic)... to keep the response clean, while including just enough surrounding lines around the modified code to provide context so the exact location of the change is unambiguous.
- After you've modified the file, please let me know which file and which line you modified.
- Normally, use Bash. CMD is the second priority. Only use PowerShell when explicitly requested, because PowerShell often causes encoding errors.
- Maintain a professional tone without emojis in any part of the response. Write all code comments in English Not Korean, adhering to a 'Public Repository' standard. This means comments must be objective and understandable solely based on the file structure and logic, without referencing the current conversation or user context. Keep comments simple.

- Follow a 'Why, What, How' step-by-step approach for each feature. 'How' refers to actual implementation details like logs, commands, or code. Provide full, working code for the specific feature being modified, but summarize unchanged parts to maintain focus. Keep explanations concise.

- Start with a brief, high-level roadmap. Do not detail every future step upfront. Instead, provide detailed specifications and explanations only for the current step. Proceed step-by-step, verify execution and logs before planning the details of the next stage. This prevents invalid assumptions about the environment and avoids wasted effort on future steps.

로그 출력 가이드 (debugPrint)
if (kDebugMode) print() 대신 **debugPrint()**를 사용하여, 불필요한 조건문 없이 코드를 간결하게 유지하세요.
안드로이드에서 긴 로그가 잘리는 현상을 방지하고, 출력 속도를 조절(Throttling)하여 앱 버벅임 없이 안전하게 디버깅할 수 있습니다.

리소스 관리 가이드 (flutter_gen)
이미지 경로를 문자열('assets/...')로 하드코딩하지 말고, **flutter_gen**으로 생성된 변수(Assets.images...)를 사용하세요.
오타 발생 시 실행 전(컴파일 타임)에 즉시 에러를 잡아주며, 자동완성 기능을 통해 개발 속도와 유지보수 효율을 극대화합니다.
