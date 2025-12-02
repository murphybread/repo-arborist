/// GitHub 컨트리뷰터 정보 모델
class ContributorModel {
  /// 기본 생성자
  const ContributorModel({
    required this.login,
    required this.id,
    required this.avatarUrl,
    required this.htmlUrl,
    required this.contributions,
    required this.type,
  });

  /// JSON에서 ContributorModel 생성
  factory ContributorModel.fromJson(Map<String, dynamic> json) {
    return ContributorModel(
      login: json['login'] as String,
      id: json['id'] as int,
      avatarUrl: json['avatar_url'] as String,
      htmlUrl: json['html_url'] as String,
      contributions: json['contributions'] as int,
      type: json['type'] as String,
    );
  }

  /// 사용자명
  final String login;

  /// 사용자 ID
  final int id;

  /// 프로필 이미지 URL
  final String avatarUrl;

  /// GitHub 프로필 URL
  final String htmlUrl;

  /// 기여 횟수 (커밋 수)
  final int contributions;

  /// 사용자 타입 (User, Bot 등)
  final String type;

  /// ContributorModel을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'id': id,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
      'contributions': contributions,
      'type': type,
    };
  }
}
