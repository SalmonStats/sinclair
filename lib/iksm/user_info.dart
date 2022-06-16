class UserInfo {
  String? sessionToken;
  String? iksmSession;
  String? currentVersionReleaseDate;
  String? version;
  String? expiresIn;
  int? resultId;

  UserInfo(
      {required this.sessionToken,
      required this.iksmSession,
      required this.currentVersionReleaseDate,
      required this.version,
      required this.resultId,
      required this.expiresIn});

  factory UserInfo.fromJson(Map<String, String> json) {
    return UserInfo(
        sessionToken: json["sessionToken"],
        iksmSession: json["iksmSession"],
        currentVersionReleaseDate: json["currentVersionReleaseDate"],
        version: json["version"],
        expiresIn: json["expiresIn"],
        resultId:
            json["resultId"] == null ? null : int.parse(json["resultId"]!));
  }

  Map<String, dynamic> toJson() {
    return {
      "sessionToken": sessionToken,
      "iksmSession": iksmSession,
      "currentVersionReleaseDate": currentVersionReleaseDate,
      "version": version,
      "expiresIn": expiresIn,
      "resultId": resultId
    };
  }
}