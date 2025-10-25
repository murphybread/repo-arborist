/// GitHub 사용자 정보 모델
class GithubUserModel {
  /// GithubUserModel 생성자
  const GithubUserModel({
    required this.login,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    required this.publicRepos,
    required this.followers,
    required this.following,
  });

  /// JSON에서 모델로 변환
  factory GithubUserModel.fromJson(Map<String, dynamic> json) {
    return GithubUserModel(
      login: json['login'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String,
      bio: json['bio'] as String?,
      publicRepos: json['public_repos'] as int,
      followers: json['followers'] as int,
      following: json['following'] as int,
    );
  }

  /// 사용자 로그인 ID
  final String login;

  /// 사용자 이름
  final String? name;

  /// 프로필 이미지 URL
  final String avatarUrl;

  /// 자기소개
  final String? bio;

  /// 공개 저장소 수
  final int publicRepos;

  /// 팔로워 수
  final int followers;

  /// 팔로잉 수
  final int following;

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'name': name,
      'avatar_url': avatarUrl,
      'bio': bio,
      'public_repos': publicRepos,
      'followers': followers,
      'following': following,
    };
  }
}
