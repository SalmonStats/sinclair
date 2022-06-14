class SessionToken {
  final String sessionToken;

  const SessionToken({required this.sessionToken});

  factory SessionToken.fromJson(Map<String, dynamic> json) {
    return SessionToken(sessionToken: json["session_token"]);
  }
}
