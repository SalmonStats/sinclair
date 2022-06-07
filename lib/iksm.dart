import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SessionToken {
  final String sessionToken;

  const SessionToken({required this.sessionToken});

  factory SessionToken.fromJson(Map<String, dynamic> json) {
    return SessionToken(sessionToken: json["session_token"]);
  }
}

class AccessToken {
  final String accessToken;

  const AccessToken({required this.accessToken});

  factory AccessToken.fromJson(Map<String, dynamic> json) {
    return AccessToken(accessToken: json["access_token"]);
  }
}

class Hash {
  final String hash;
  final String naIdToken;
  final String timestamp;

  const Hash(
      {required this.hash, required this.naIdToken, required this.timestamp});

  factory Hash.fromJson(Map<String, dynamic> json) {
    return Hash(
        hash: json["hash"],
        naIdToken: json["naIdToken"],
        timestamp: json["timestamp"]);
  }
}

class Flapg {
  final String f;
  final String p1;
  final String p2;
  final String p3;

  const Flapg(
      {required this.f, required this.p1, required this.p2, required this.p3});

  factory Flapg.fromJson(Map<String, dynamic> json) {
    return Flapg(
        f: json["result"]["f"],
        p1: json["result"]["p1"],
        p2: json["result"]["p2"],
        p3: json["result"]["p3"]);
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

class SplatoonToken {
  final int status;
  final Result result;

  const SplatoonToken({required this.status, required this.result});

  factory SplatoonToken.fromJson(Map<String, dynamic> json) {
    return SplatoonToken(
        status: json["status"], result: Result.fromJson(json["result"]));
  }
}

class SplatoonAccessToken {
  final int status;
  final WebApiServerCredential result;
  final String correlationId;

  const SplatoonAccessToken(
      {required this.status,
      required this.result,
      required this.correlationId});

  factory SplatoonAccessToken.fromJson(Map<String, dynamic> json) {
    return SplatoonAccessToken(
        status: json["status"],
        result: WebApiServerCredential.fromJson(json["result"]),
        correlationId: json["correlationId"]);
  }
}

class ErrorNSO {
  final String errorDescription;
  final String error;

  const ErrorNSO({required this.errorDescription, required this.error});

  factory ErrorNSO.fromJson(Map<String, dynamic> json) {
    return ErrorNSO(
        errorDescription: json["error_description"], error: json["error"]);
  }
}

class ErrorAPP {
  final int status;
  final String correlationId;
  final String errorMessage;

  const ErrorAPP({
    required this.status,
    required this.correlationId,
    required this.errorMessage,
  });

  factory ErrorAPP.fromJson(Map<String, dynamic> json) {
    return ErrorAPP(
        status: json["status"],
        correlationId: json["correlationId"],
        errorMessage: json["errorMessage"]);
  }
}

Future<SessionToken> _getSessionToken(String sessionTokenCode) async {
  http.Client client = http.Client();
  const String verifier = "OwaTAOolhambwvY3RXSD-efxqdBEVNnQkc0bBJ7zaak";
  Map<String, String> parameters = {
    "client_id": "71b963c1b7b6d119",
    "session_token_code": sessionTokenCode,
    "session_token_code_verifier": verifier,
  };
  Uri url = Uri.parse(
      "https://accounts.nintendo.com/connect/1.0.0/api/session_token");
  final http.Response response = (await client.post(url, body: parameters));

  if (response.statusCode != 200) {
    throw HttpException("${response.body}");
  }
  debugPrint(response.statusCode.toString());
  return SessionToken.fromJson(json.decode(response.body));
}

Future<AccessToken> _getAccessToken(SessionToken token) async {
  final String sessionToken = token.sessionToken;
  http.Client client = http.Client();
  Map<String, String> parameters = {
    "client_id": "71b963c1b7b6d119",
    "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer-session-token",
    "session_token": sessionToken,
  };
  Uri url = Uri.parse("https://accounts.nintendo.com/connect/1.0.0/api/token");
  final String response = (await client.post(url, body: parameters)).body;
  debugPrint(response);
  return AccessToken.fromJson(json.decode(response));
}

Future<Hash> _getHash(String accessToken, int timestamp) async {
  http.Client client = http.Client();
  Map<String, String> parameters = {
    "naIdToken": accessToken,
    "timestamp": "$timestamp",
  };
  Uri url = Uri.parse("https://s2s-hash-server.herokuapp.com/hash");
  final String response = (await client.post(url, body: parameters)).body;
  debugPrint(response);
  return Hash.fromJson(json.decode(response));
}

enum FlapgType { NSO, APP }

extension FlapgTypeExt on FlapgType {
  String get rawValue {
    switch (this) {
      case FlapgType.APP:
        return "app";
      case FlapgType.NSO:
        return "nso";
    }
  }
}

Future<Flapg> _getFlapgToken(
    String accessToken, int timestamp, String hash, FlapgType type) async {
  http.Client client = http.Client();
  Map<String, String> headers = {
    "x-token": accessToken,
    "x-time": "$timestamp",
    "x-guid": "037239ef-1914-43dc-815d-178aae7d8934",
    "x-hash": hash,
    "x-ver": "3",
    "x-iid": type.rawValue,
  };
  Uri url = Uri.parse("https://flapg.com/ika2/api/login");
  final String response = (await client.get(url, headers: headers)).body;
  debugPrint(response);
  return Flapg.fromJson(json.decode(response));
}

Future<SplatoonToken> _getSplatoonToken(Flapg result, String version) async {
  http.Client client = http.Client();
  final Map<String, String> headers = {
    "X-ProductVersion": version,
    "X-Platform": "Android",
    "Content-Type": "application/json"
  };

  final Map<String, Map<String, String>> parameters = {
    "parameter": {
      "f": result.f,
      "naIdToken": result.p1,
      "timestamp": result.p2,
      "requestId": result.p3,
      "naCountry": "JP",
      "naBirthday": "1990-01-01",
      "language": "ja-JP",
    }
  };

  Uri url = Uri.parse("https://api-lp1.znc.srv.nintendo.net/v3/Account/Login");
  debugPrint(headers.toString());
  debugPrint(json.encode(parameters).toString());
  final String response =
      (await client.post(url, headers: headers, body: json.encode(parameters)))
          .body;
  debugPrint(response);
  return SplatoonToken.fromJson(json.decode(response));
}

Future<SplatoonToken> _getSplatoonTokenValue(
    AccessToken token, String version) async {
  final String accessToken = token.accessToken;
  final int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final Hash hash = await _getHash(accessToken, timestamp);
  final Flapg result =
      await _getFlapgToken(accessToken, timestamp, hash.hash, FlapgType.NSO);
  return _getSplatoonToken(result, version);
}

Future<SplatoonAccessToken> _getSplatoonAccessTokenValue(
    SplatoonToken token, String version) async {
  final String accessToken = token.result.webApiServerCredential.accessToken;
  final int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final Hash hash = await _getHash(accessToken, timestamp);
  final Flapg result =
      await _getFlapgToken(accessToken, timestamp, hash.hash, FlapgType.APP);
  return _getSplatoonAccessToken(result, accessToken, version);
}

Future<SplatoonAccessToken> _getSplatoonAccessToken(
    Flapg result, String accessToken, String version) async {
  http.Client client = http.Client();
  Map<String, String> headers = {
    "X-ProductVersion": version,
    "X-Platform": "Android",
    "Authorization": "Bearer $accessToken",
    "Content-Type": "application/json"
  };

  Map<String, Map<String, String>> parameters = {
    "parameter": {
      "f": result.f,
      "id": "5741031244955648",
      "registrationToken": result.p1,
      "timestamp": result.p2,
      "requestId": result.p3,
    }
  };

  Uri url = Uri.parse(
      "https://api-lp1.znc.srv.nintendo.net/v2/Game/GetWebServiceToken");
  final String response =
      (await client.post(url, headers: headers, body: json.encode(parameters)))
          .body;
  debugPrint(response);
  return SplatoonAccessToken.fromJson(json.decode(response));
}

Future<String> _getIksmSession(SplatoonAccessToken token) async {
  http.Client client = http.Client();
  final String accessToken = token.result.accessToken;
  final Uri url = Uri.parse("https://app.splatoon2.nintendo.net/");

  Map<String, String> headers = {
    "Cookie": "iksm_session=",
    "X-GameWebToken": accessToken
  };

  final String? cookies =
      (await client.get(url, headers: headers)).headers["set-cookie"];

  if (cookies == null) {
    throw HttpException("AAA");
  }

  final String? iksmSession =
      new RegExp(r"iksm_session=([0-9a-f]{40})").firstMatch(cookies)?.group(1);

  if (iksmSession == null) {
    throw HttpException("AAA");
  }

  return iksmSession;
}

class UserInfo {
  String sessionToken;
  String iksmSession;

  UserInfo(this.sessionToken, this.iksmSession) {}
}

Future<String?> getCookie(String urlScheme) async {
  const String version = "2.1.1";
  final String? sessionTokenCode =
      new RegExp(r"de=(.*)&").firstMatch(urlScheme)?.group(1);

  if (sessionTokenCode == null) {
    return null;
  }

  debugPrint(sessionTokenCode);
  final Future<SessionToken> sessionToken = _getSessionToken(sessionTokenCode)
      .then((value) => value)
      .catchError((error) {
    debugPrint(error.toString());
    return;
  });

  return _getAccessToken((await sessionToken))
      .then((value) => _getSplatoonTokenValue(value, version))
      .then((value) => _getSplatoonAccessTokenValue(value, version))
      .then((value) async {
    final String? iksmSession = (await _getIksmSession(value));
  }).catchError((error) {
    debugPrint(error.toString());
    return null;
  });
}

Uri getOAuthUri() {
  const String state = "V6DSwHXbqC4rspCn_ArvfkpG1WFSvtNYrhugtfqOHsF6SYyX";
  const String verifier = "OwaTAOolhambwvY3RXSD-efxqdBEVNnQkc0bBJ7zaak";
  const String challenge = "tYLPO5PxpK-DTcAHJXugD7ztvAZQlo0DQQp3au5ztuM";

  final Uri oauthUri = Uri.parse(
      "https://accounts.nintendo.com/connect/1.0.0/authorize?state=V6DSwHXbqC4rspCn_ArvfkpG1WFSvtNYrhugtfqOHsF6SYyX&redirect_uri=npf71b963c1b7b6d119://auth&client_id=71b963c1b7b6d119&scope=openid+user+user.birthday+user.mii+user.screenName&response_type=session_token_code&session_token_code_challenge=tYLPO5PxpK-DTcAHJXugD7ztvAZQlo0DQQp3au5ztuM&session_token_code_challenge_method=S256&theme=login_form");
  final Map<String, String> parameters = {
    "state": state,
    "redirect_uri": "npf71b963c1b7b6d119://auth",
    "client_id": "71b963c1b7b6d119",
    "scope": "openid+user+user.birthday+user.mii+user.screenName",
    "response_type": "session_token_code",
    "session_token_code_challenge": challenge,
    "session_token_code_challenge_method": "S256",
    "theme": "login_form",
  };

  return oauthUri;
}
