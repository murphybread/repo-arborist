# OpenAI 레포지토리 분석 연동 계획

## 기능 개요

GitHub 저장소 정보를 OpenAI API로 분석하여 인사이트 제공

## 구현 단계

### 1단계: OpenAI 패키지 설치

```bash
flutter pub add dart_openai
flutter pub add flutter_dotenv  # 이미 있음
```

### 2단계: .env에 API 키 추가

```env
# .env
GITHUB_TOKEN=ghp_...
OPENAI_API_KEY=sk-proj-...  # 추가
```

### 3단계: OpenAI 서비스 생성

```dart
// lib/core/services/openai_service.dart

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  OpenAIService() {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey != null) {
      OpenAI.apiKey = apiKey;
    }
  }

  /// 레포지토리 분석 프롬프트 생성
  String _buildAnalysisPrompt({
    required String repoName,
    required String description,
    required int commits,
    required int prs,
    required Map<String, int> languages,
    String? readme,
  }) {
    return '''
다음 GitHub 저장소를 분석해주세요:

레포지토리: $repoName
설명: $description
통계:
- 총 커밋: $commits
- 머지된 PR: $prs
- 주요 언어: ${languages.entries.map((e) => '${e.key} ${e.value}%').join(', ')}

${readme != null ? 'README:\n$readme' : ''}

다음 형식으로 분석 결과를 작성해주세요:

## 📋 프로젝트 요약
(3-5줄로 요약)

## 🔧 기술 스택 분석
(사용된 기술과 그 이유 추측)

## 💡 개선 제안
(구체적인 개선 사항 3가지)

## ⭐ 프로젝트 점수
코드 품질: X/10
활동성: X/10
문서화: X/10

## 🎯 다음 단계
(추천하는 다음 작업 3가지)
''';
  }

  /// 레포지토리 분석 요청
  Future<String> analyzeRepository({
    required String repoName,
    required String description,
    required int commits,
    required int prs,
    required Map<String, int> languages,
    String? readme,
  }) async {
    final prompt = _buildAnalysisPrompt(
      repoName: repoName,
      description: description,
      commits: commits,
      prs: prs,
      languages: languages,
      readme: readme,
    );

    final response = await OpenAI.instance.chat.create(
      model: 'gpt-4o-mini', // 저렴한 모델
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              '당신은 소프트웨어 개발 전문가입니다. GitHub 저장소를 분석하고 개선 제안을 제공합니다.',
            ),
          ],
        ),
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
          ],
        ),
      ],
      temperature: 0.7,
      maxTokens: 1000,
    );

    return response.choices.first.message.content?.first.text ?? '분석 실패';
  }

  /// 간단한 요약 (토큰 절약)
  Future<String> getSummary({
    required String repoName,
    required String description,
  }) async {
    final response = await OpenAI.instance.chat.create(
      model: 'gpt-4o-mini',
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              '다음 GitHub 저장소를 한 문장으로 요약해주세요: $repoName - $description',
            ),
          ],
        ),
      ],
      maxTokens: 100,
    );

    return response.choices.first.message.content?.first.text ?? description;
  }
}
```

### 4단계: Repository Detail 화면에 버튼 추가

```dart
// lib/features/github/screens/repository_detail_screen.dart

class RepositoryDetailScreen extends ConsumerStatefulWidget {
  // ... 기존 코드
}

class _RepositoryDetailScreenState extends ConsumerState<RepositoryDetailScreen> {
  final _openAIService = OpenAIService();
  String? _aiAnalysis;
  bool _isAnalyzing = false;

  Future<void> _analyzeWithAI() async {
    setState(() => _isAnalyzing = true);

    try {
      // GitHub API로 언어 정보 가져오기
      final languages = await _fetchLanguages();

      // OpenAI 분석 요청
      final analysis = await _openAIService.analyzeRepository(
        repoName: widget.repository.fullName,
        description: widget.repository.description ?? '',
        commits: widget.stats.totalCommits,
        prs: widget.stats.totalMergedPRs,
        languages: languages,
        readme: null, // 옵션: README 가져오기
      );

      setState(() {
        _aiAnalysis = analysis;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI 분석 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... 기존 코드
      body: Column(
        children: [
          // 기존 통계 표시
          _buildStats(),

          // AI 분석 버튼
          ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _analyzeWithAI,
            icon: Icon(Icons.auto_awesome),
            label: Text(_isAnalyzing ? '분석 중...' : 'AI 분석 요청'),
          ),

          // AI 분석 결과 표시
          if (_aiAnalysis != null)
            Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: MarkdownBody(data: _aiAnalysis!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

### 5단계: 비용 최적화

**문제**: OpenAI API는 사용량에 따라 과금

**해결책**:
1. 캐싱: 한 번 분석한 레포는 저장
2. 모델 선택: `gpt-4o-mini` 사용 (저렴)
3. 토큰 제한: `maxTokens: 1000` 설정

```dart
// Firestore에 AI 분석 결과 캐싱
final cacheKey = 'ai_analysis_${repository.fullName}';
final cached = await _cacheService.get(cacheKey);

if (cached != null) {
  return cached['analysis'] as String;
}

final analysis = await _openAIService.analyzeRepository(...);

// 7일간 캐싱
await _cacheService.set(
  cacheKey,
  {'analysis': analysis},
  ttl: Duration(days: 7),
);
```

### 6단계: 유니크한 기능 추가

**1. 레포 비교 기능**
```dart
"이 두 레포지토리를 비교해서 어느 쪽이 더 활발한지 분석해주세요:
- Repo A: ...
- Repo B: ..."
```

**2. 커밋 메시지 품질 분석**
```dart
"최근 커밋 메시지들을 분석해서 팀의 커밋 컨벤션을 평가해주세요:
- feat: add feature
- fix: bug fix
- chore: update deps
..."
```

**3. 숲 전체 요약**
```dart
"이 개발자의 30개 레포지토리를 분석해서 주력 분야와 성장 트렌드를 분석해주세요"
```

**4. 나무 성장 예측**
```dart
"현재 활동 패턴을 보면, 이 레포가 언제쯤 '나무' 단계에 도달할까요?"
```

## 비용 추정

**GPT-4o-mini 가격** (2024년 기준):
- Input: $0.150 / 1M tokens
- Output: $0.600 / 1M tokens

**레포 1개 분석 비용**:
- Prompt: ~500 tokens
- Response: ~1000 tokens
- 비용: $0.0006 (약 0.8원)

**월간 비용** (하루 10개 분석):
- 10 repos/day × 30 days = 300 repos/month
- 비용: $0.18/month (약 240원)

→ 매우 저렴!

## 다음 단계

1. OpenAI API 키 발급: https://platform.openai.com/api-keys
2. `.env`에 키 추가
3. `dart_openai` 패키지 설치
4. 위 코드 구현
5. 테스트 및 개선

## 참고 자료

- OpenAI API 문서: https://platform.openai.com/docs
- dart_openai 패키지: https://pub.dev/packages/dart_openai
