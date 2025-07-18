class OauthLoginResp {
  final int userId;
  final String username;
  final String accessToken;
  final String refreshToken;
  final bool isNewUser;

  OauthLoginResp({
    required this.userId,
    required this.username,
    required this.accessToken,
    required this.refreshToken,
    required this.isNewUser,
  });

  factory OauthLoginResp.fromJson(Map<String, dynamic> json) {
    return OauthLoginResp(
      userId: json['userId'],
      username: json['username'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      isNewUser: json['isNewUser'],
    );
  }
}