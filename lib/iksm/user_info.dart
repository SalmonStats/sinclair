class UserInfo {
  String? sessionToken;
  String? iksmSession;
  String? currentVersionReleaseDate;
  String? version;
  int? resultId;

  UserInfo(
      {required this.sessionToken,
      required this.iksmSession,
      required this.currentVersionReleaseDate,
      required this.version,
      required this.resultId});

  factory UserInfo.fromJson(Map<String, String> json) {
    return UserInfo(
        sessionToken: json["sessionToken"],
        iksmSession: json["iksmSession"],
        currentVersionReleaseDate: json["currentVersionReleaseDate"],
        version: json["version"],
        resultId:
            json["resultId"] == null ? null : int.parse(json["resultId"]!));
  }

  Map<String, dynamic> toJson() {
    return {
      "sessionToken": sessionToken,
      "iksmSession": iksmSession,
      "currentVersionReleaseDate": currentVersionReleaseDate,
      "version": version,
      "resultId": resultId
    };
  }
}
