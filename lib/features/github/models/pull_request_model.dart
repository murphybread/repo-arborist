/// GitHub Pull Request 데이터 모델
class PullRequestModel {
  /// PullRequestModel 생성자
  const PullRequestModel({
    required this.number,
    required this.title,
    required this.author,
    required this.createdAt,
    required this.mergedAt,
    required this.url,
  });

  /// PR 번호
  final int number;

  /// PR 제목
  final String title;

  /// 작성자 이름
  final String author;

  /// 생성 날짜
  final DateTime createdAt;

  /// 머지 날짜
  final DateTime? mergedAt;

  /// PR URL
  final String url;

  /// JSON에서 PullRequestModel 생성
  factory PullRequestModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;

    return PullRequestModel(
      number: json['number'] as int,
      title: json['title'] as String,
      author: userJson?['login'] as String? ?? 'Unknown',
      createdAt: DateTime.parse(json['created_at'] as String),
      mergedAt: json['merged_at'] != null
          ? DateTime.parse(json['merged_at'] as String)
          : null,
      url: json['html_url'] as String,
    );
  }
}
