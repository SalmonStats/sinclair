import 'dart:developer';

class UserData {
  final String? iksmSession;
  final String? nsaid;

  const UserData({required this.iksmSession, required this.nsaid});
}

class UserInfo {
  String? sessionToken;
  String? iksmSession;
  String? currentVersionReleaseDate;
  String? version;
  String? expiresIn;
  String? nsaid;
  int? resultId;

  UserInfo(
      {required this.sessionToken,
      required this.iksmSession,
      required this.currentVersionReleaseDate,
      required this.version,
      required this.resultId,
      required this.nsaid,
      required this.expiresIn});

  factory UserInfo.fromJson(Map<String, String> json) {
    return UserInfo(
        sessionToken: json["sessionToken"],
        iksmSession: json["iksmSession"],
        currentVersionReleaseDate: json["currentVersionReleaseDate"],
        version: json["version"],
        expiresIn: json["expiresIn"],
        nsaid: json["nsaid"],
        resultId: json["resultId"] == null
            ? null
            : int.tryParse(json["resultId"]!) ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {
      "sessionToken": sessionToken,
      "iksmSession": iksmSession,
      "currentVersionReleaseDate": currentVersionReleaseDate,
      "version": version,
      "expiresIn": expiresIn,
      "nsaid": nsaid,
      "resultId": resultId
    };
  }
}
