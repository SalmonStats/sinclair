class SplatoonToken {
  final int status;
  final Result result;

  const SplatoonToken({required this.status, required this.result});

  factory SplatoonToken.fromJson(Map<String, dynamic> json) {
    return SplatoonToken(
        status: json["status"], result: Result.fromJson(json["result"]));
  }
}

class User {
  final String nsaId;
  final String imageUri;
  final String name;
  final bool isChildRestricted;
  final bool membership;
  final String friendCode;

  const User(
      {required this.nsaId,
      required this.imageUri,
      required this.name,
      required this.isChildRestricted,
      required this.membership,
      required this.friendCode});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        nsaId: json["nsaId"],
        imageUri: json["imageUri"],
        name: json["name"],
        isChildRestricted: json["isChildRestricted"],
        membership: json["links"]["nintendoAccount"]["membership"]["active"],
        friendCode: json["links"]["friendCode"]["id"]);
  }
}

class Result {
  final User user;
  final WebApiServerCredential webApiServerCredential;

  const Result({required this.user, required this.webApiServerCredential});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
        user: User.fromJson(json["user"]),
        webApiServerCredential:
            WebApiServerCredential.fromJson(json["webApiServerCredential"]));
  }
}

class WebApiServerCredential {
  final String accessToken;
  final int expiresIn;

  const WebApiServerCredential(
      {required this.accessToken, required this.expiresIn});

  factory WebApiServerCredential.fromJson(Map<String, dynamic> json) {
    return WebApiServerCredential(
        accessToken: json["accessToken"], expiresIn: json["expiresIn"]);
  }
}
