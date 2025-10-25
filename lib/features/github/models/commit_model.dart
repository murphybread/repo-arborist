/// GitHub 커밋 데이터 모델
class CommitModel {
  /// CommitModel 생성자
  const CommitModel({
    required this.sha,
    required this.message,
    required this.author,
    required this.date,
    required this.url,
  });

  /// 커밋 SHA
  final String sha;

  /// 커밋 메시지
  final String message;

  /// 작성자 이름
  final String author;

  /// 커밋 날짜
  final DateTime date;

  /// 커밋 URL
  final String url;

  /// JSON에서 CommitModel 생성
  factory CommitModel.fromJson(Map<String, dynamic> json) {
    final commitData = json['commit'] as Map<String, dynamic>;
    final authorData = commitData['author'] as Map<String, dynamic>;

    return CommitModel(
      sha: json['sha'] as String,
      message: commitData['message'] as String,
      author: authorData['name'] as String,
      date: DateTime.parse(authorData['date'] as String),
      url: json['html_url'] as String,
    );
  }
}
