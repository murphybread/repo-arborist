# Google Gemini API 연동 계획

## Gemini Flash 2.0 사용 (무료!)

Google Gemini Flash는 **완전 무료**이고 빠릅니다.

## 구현 단계

### 1단계: API 키 발급

1. https://aistudio.google.com/app/apikey 접속
2. "Create API Key" 클릭
3. API 키 복사

**제한:**
- 분당 15회 요청 (RPM)
- 일일 1,500회 요청 (RPD)
- 분당 400만 토큰 (TPM)

→ 개인 프로젝트에는 충분!

### 2단계: 패키지 설치

```bash
flutter pub add google_generative_ai
```

### 3단계: .env에 API 키 추가

```env
# .env
GITHUB_TOKEN=ghp_...
GEMINI_API_KEY=AIzaSy...  # 추가
```

### 4단계: Gemini 서비스 생성

```dart
// lib/core/services/gemini_service.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env');
    }

    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp', // 최신 무료 모델
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1000,
      ),
    );
  }

  /// 레포지토리 분석 프롬프트 생성
  String _buildAnalysisPrompt({
    required String repoName,
    required String description,
    required int commits,
    required int prs,
    required int stars,
    required int forks,
    required String? readme,
  }) {
    return '''
다음 GitHub 저장소를 분석해주세요:

**레포지토리**: $repoName
**설명**: $description

**통계**:
- 총 커밋: $commits
- 머지된 PR: $prs
- 스타: $stars
- 포크: $forks

${readme != null ? '**README**:\n```\n${readme.substring(0, readme.length > 500 ? 500 : readme.length)}...\n```' : ''}

다음 형식으로 한국어로 분석해주세요:

## 📋 프로젝트 요약
(3-5줄로 요약)

## 🔧 기술 스택 추정
(사용된 기술 스택과 그 이유)

## 💡 개선 제안
1. ...
2. ...
3. ...

## ⭐ 프로젝트 평가
- 코드 품질: X/10
- 활동성: X/10
- 문서화: X/10

## 🎯 다음 단계
(추천하는 다음 작업 3가지)
''';
  }

  /// 레포지토리 분석
  Future<String> analyzeRepository({
    required String repoName,
    required String description,
    required int commits,
    required int prs,
    required int stars,
    required int forks,
    String? readme,
  }) async {
    try {
      final prompt = _buildAnalysisPrompt(
        repoName: repoName,
        description: description,
        commits: commits,
        prs: prs,
        stars: stars,
        forks: forks,
        readme: readme,
      );

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? '분석 결과를 가져올 수 없습니다.';
    } catch (e) {
      if (e.toString().contains('429')) {
        return '⚠️ API 제한 초과: 잠시 후 다시 시도해주세요 (분당 15회 제한)';
      } else if (e.toString().contains('quota')) {
        return '⚠️ 일일 할당량 초과: 내일 다시 시도해주세요';
      }
      return '❌ 분석 실패: $e';
    }
  }

  /// 간단한 요약 (토큰 절약)
  Future<String> getSummary({
    required String repoName,
    required String description,
  }) async {
    try {
      final prompt = '다음 GitHub 저장소를 한 문장으로 요약해주세요: $repoName - $description';
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? description;
    } catch (e) {
      return description;
    }
  }

  /// 레포지토리 페르소나 감지
  Future<String> detectPersona({
    required String repoName,
    required String description,
    required int commits,
    required int prs,
    required int stars,
    required int forks,
    required bool isForked,
    required DateTime createdAt,
    required DateTime? lastActivity,
  }) async {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    final daysSinceLastActivity = lastActivity != null
        ? DateTime.now().difference(lastActivity).inDays
        : 999;

    final prompt = '''
다음 GitHub 저장소의 유형을 판단해주세요:

레포지토리: $repoName
설명: $description
통계:
- 커밋: $commits
- PR: $prs
- 스타: $stars
- 포크: $forks
- 포크됨: $isForked
- 나이: $daysSinceCreation일
- 마지막 활동: $daysSinceLastActivity일 전

다음 중 하나로 분류해주세요:

1. **learning** - 개인 학습/연습 프로젝트
   - 특징: 커밋 많음, PR 거의 없음, 스타/포크 적음

2. **opensource** - 오픈소스 프로젝트
   - 특징: 스타/포크 많음, PR 활발, 여러 기여자

3. **completed** - 완성된 프로젝트
   - 특징: 활동 적지만 스타 있음, 안정적

4. **experimental** - 실험적 프로젝트
   - 특징: 빠르게 생성, 적은 커밋, 짧은 수명

5. **archived** - 아카이브 프로젝트
   - 특징: 오래됨, 최근 활동 없음, 하지만 의미 있음

6. **work** - 업무 프로젝트
   - 특징: PR 중심, 규칙적인 활동, 비공개 가능성

**한 단어로만** 답하세요 (예: learning)
단어만 출력하고 설명은 하지 마세요.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final result = response.text?.trim().toLowerCase() ?? 'experimental';

      // 유효한 페르소나인지 확인
      const validPersonas = [
        'learning',
        'opensource',
        'completed',
        'experimental',
        'archived',
        'work'
      ];

      return validPersonas.contains(result) ? result : 'experimental';
    } catch (e) {
      return 'experimental'; // 기본값
    }
  }

  /// 레포지토리 비교
  Future<String> compareRepositories({
    required String repo1Name,
    required int repo1Commits,
    required int repo1PRs,
    required String repo2Name,
    required int repo2Commits,
    required int repo2PRs,
  }) async {
    final prompt = '''
다음 두 GitHub 저장소를 비교 분석해주세요:

**Repo A**: $repo1Name
- 커밋: $repo1Commits
- PR: $repo1PRs

**Repo B**: $repo2Name
- 커밋: $repo2Commits
- PR: $repo2PRs

다음 형식으로 비교해주세요:

## 🔍 활동성 비교
(어느 쪽이 더 활발한가?)

## 💪 강점 분석
**$repo1Name의 강점:**
- ...

**$repo2Name의 강점:**
- ...

## 🎯 추천
(어떤 프로젝트에 집중하면 좋을까?)
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? '비교 분석을 가져올 수 없습니다.';
    } catch (e) {
      return '❌ 비교 실패: $e';
    }
  }

  /// 숲 전체 요약 (개발자 분석)
  Future<String> analyzeDeveloperForest({
    required String username,
    required int totalRepos,
    required int totalCommits,
    required int totalPRs,
    required List<String> topLanguages,
  }) async {
    final prompt = '''
다음 개발자의 GitHub 활동을 분석해주세요:

**개발자**: $username

**전체 통계**:
- 총 레포지토리: $totalRepos개
- 총 커밋: $totalCommits
- 총 PR: $totalPRs
- 주요 언어: ${topLanguages.join(', ')}

다음 형식으로 분석해주세요:

## 🌲 개발자 프로필
(이 개발자는 어떤 개발자인가?)

## 📊 주력 분야
(어떤 기술 스택에 집중하는가?)

## 📈 성장 트렌드
(활동 패턴과 성장 방향)

## 💡 추천 사항
(다음에 도전해볼 만한 것들)
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? '개발자 분석을 가져올 수 없습니다.';
    } catch (e) {
      return '❌ 분석 실패: $e';
    }
  }
}
```

### 5단계: Repository에 README 가져오기 기능 추가

```dart
// lib/features/github/repositories/github_repository.dart

/// README 가져오기
Future<String?> getReadme({
  required String owner,
  required String repo,
  String? token,
}) async {
  try {
    final effectiveToken = token ?? dotenv.env['GITHUB_TOKEN'];

    final url = Uri.parse('$_baseUrl/repos/$owner/$repo/readme');
    final response = await http.get(
      url,
      headers: _getHeaders(token: effectiveToken),
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['content'] as String;

    // Base64 디코딩
    final decoded = utf8.decode(base64.decode(content));
    return decoded;
  } catch (e) {
    print('[GitHub API] README 가져오기 실패: $e');
    return null;
  }
}
```

### 6단계: Repository Detail 화면에 AI 분석 추가

```dart
// lib/features/github/screens/repository_detail_screen.dart

import 'package:template/core/services/gemini_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class _RepositoryDetailScreenState extends ConsumerState<RepositoryDetailScreen> {
  final _geminiService = GeminiService();
  String? _aiAnalysis;
  bool _isAnalyzing = false;

  Future<void> _analyzeWithGemini() async {
    setState(() => _isAnalyzing = true);

    try {
      // README 가져오기 (선택사항)
      final parts = widget.repository.fullName.split('/');
      final readme = await GitHubRepository().getReadme(
        owner: parts[0],
        repo: parts[1],
      );

      // Gemini 분석 요청
      final analysis = await _geminiService.analyzeRepository(
        repoName: widget.repository.fullName,
        description: widget.repository.description ?? '설명 없음',
        commits: widget.stats.totalCommits,
        prs: widget.stats.totalMergedPRs,
        stars: widget.repository.stargazersCount ?? 0,
        forks: widget.repository.forksCount ?? 0,
        readme: readme,
      );

      setState(() {
        _aiAnalysis = analysis;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyizing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI 분석 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... 기존 코드
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 기존 통계 표시
            _buildStats(),

            const SizedBox(height: 16),

            // AI 분석 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeWithGemini,
                icon: _isAnalyzing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.auto_awesome),
                label: Text(
                  _isAnalyzing ? '🤖 AI 분석 중...' : '🤖 Gemini로 분석하기',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4285F4), // Google Blue
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
            ),

            // AI 분석 결과 표시
            if (_aiAnalysis != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Color(0xFF1E293B),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Color(0xFF4285F4)),
                            SizedBox(width: 8),
                            Text(
                              'Gemini AI 분석',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Color(0xFF334155)),
                        MarkdownBody(
                          data: _aiAnalysis!,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(color: Color(0xFFCBD5E1)),
                            h2: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            listBullet: TextStyle(color: Color(0xFF14B8A6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
```

### 7단계: .gitignore에 API 키 보호 확인

```bash
# .gitignore에 이미 있음
.env
```

---

## 비용 비교

| 서비스 | 월 300개 레포 분석 비용 |
|--------|----------------------|
| **Gemini Flash** | **무료** (제한: 일일 1,500회) |
| OpenAI GPT-4o-mini | $0.18 (약 240원) |
| Claude Haiku | $0.75 (약 1,000원) |

→ Gemini가 **압도적으로 저렴** (무료!)

---

## 다음 단계

1. API 키 발급: https://aistudio.google.com/app/apikey
2. `.env`에 추가: `GEMINI_API_KEY=AIzaSy...`
3. 패키지 설치: `flutter pub add google_generative_ai`
4. 위 코드 구현
5. 테스트!

---

## 제한 사항 대응

**일일 1,500회 제한 (RPD) 대응:**
```dart
// Firestore에 AI 분석 결과 캐싱 (7일)
final cacheKey = 'gemini_analysis_${repository.fullName}';
final cached = await _cacheService.get(cacheKey);

if (cached != null) {
  return cached['analysis'] as String;
}

final analysis = await _geminiService.analyzeRepository(...);

await _cacheService.set(
  cacheKey,
  {'analysis': analysis},
  ttl: Duration(days: 7), // 7일간 재사용
);
```

**분당 15회 제한 (RPM) 대응:**
```dart
// 간단한 Rate Limiter
class RateLimiter {
  final _timestamps = <DateTime>[];

  Future<void> waitIfNeeded() async {
    final now = DateTime.now();
    _timestamps.removeWhere((t) => now.difference(t).inMinutes >= 1);

    if (_timestamps.length >= 15) {
      final oldestRequest = _timestamps.first;
      final waitTime = Duration(minutes: 1) - now.difference(oldestRequest);
      await Future.delayed(waitTime);
    }

    _timestamps.add(now);
  }
}
```

---

## 참고 자료

- Gemini API 문서: https://ai.google.dev/gemini-api/docs
- google_generative_ai 패키지: https://pub.dev/packages/google_generative_ai
- API 키 발급: https://aistudio.google.com/app/apikey
