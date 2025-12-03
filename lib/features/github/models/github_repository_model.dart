/// GitHub Repository 정보 모델
class GithubRepositoryModel {
  /// GithubRepositoryModel 생성자
  const GithubRepositoryModel({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.isPrivate,
    required this.htmlUrl,
    required this.createdAt,
    required this.pushedAt,
    this.language,
  });

  /// JSON에서 모델로 변환
  factory GithubRepositoryModel.fromJson(Map<String, dynamic> json) {
    return GithubRepositoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      description: json['description'] as String?,
      isPrivate: json['private'] as bool,
      htmlUrl: json['html_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      pushedAt: json['pushed_at'] != null
          ? DateTime.parse(json['pushed_at'] as String)
          : null,
      language: json['language'] as String?,
    );
  }

  /// Repository ID
  final int id;

  /// Repository 이름
  final String name;

  /// 전체 이름 (owner/repo)
  final String fullName;

  /// 설명
  final String? description;

  /// Private 여부
  final bool isPrivate;

  /// GitHub URL
  final String htmlUrl;

  /// 생성 날짜
  final DateTime createdAt;

  /// 마지막 푸시 날짜 (최근 커밋 날짜)
  final DateTime? pushedAt;

  /// 주요 프로그래밍 언어 (Dart, JavaScript, Python 등)
  final String? language;

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'description': description,
      'private': isPrivate,
      'html_url': htmlUrl,
      'created_at': createdAt.toIso8601String(),
      'pushed_at': pushedAt?.toIso8601String(),
      'language': language,
    };
  }
}
