import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sinclair/iksm/access_token.dart';
import 'package:sinclair/iksm/error.dart';
import 'package:sinclair/iksm/flapg.dart';
import 'package:sinclair/iksm/s2s.dart';
import 'package:sinclair/iksm/session_token.dart';
import 'package:sinclair/iksm/splatoon_access_token.dart';
import 'package:sinclair/iksm/splatoon_token.dart';
import 'package:sinclair/iksm/user_info.dart';
import 'package:sinclair/iksm/version.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sinclair/response.dart';

Iterable<int> range(int low, int high) sync* {
  for (int i = low; i < high; ++i) {
    yield i;
  }
}

class SplatNet2 {
  final FlutterSecureStorage keychain = new FlutterSecureStorage();
  String? iksmSession;
  String? sessionToken;
  String? currentVersionReleaseDate;
  String? version;
  int? resultId;

  SplatNet2() {
    keychain.readAll().then((value) {
      final UserInfo userInfo = UserInfo.fromJson(value);
      iksmSession = userInfo.iksmSession;
      sessionToken = userInfo.sessionToken;
      currentVersionReleaseDate = userInfo.currentVersionReleaseDate;
      version = userInfo.version;
      resultId = userInfo.resultId;
      inspect(userInfo);
    });
  }

  Future<Version> _getVersion() async {
    http.Client client = http.Client();
    Uri url = Uri.parse("https://itunes.apple.com/lookup?id=1234806557");

    final http.Response response = (await client.get(url));
    return Version.fromJson(json.decode(response.body));
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
      final error = ErrorNSO.fromJson(json.decode(response.body));
      throw HttpException("${response.statusCode}: ${error.errorDescription}");
    }

    return SessionToken.fromJson(json.decode(response.body));
  }

  Future<AccessToken> _getAccessToken(String sessionToken) async {
    http.Client client = http.Client();
    Map<String, String> parameters = {
      "client_id": "71b963c1b7b6d119",
      "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer-session-token",
      "session_token": sessionToken,
    };
    Uri url =
        Uri.parse("https://accounts.nintendo.com/connect/1.0.0/api/token");
    final http.Response response = (await client.post(url, body: parameters));

    if (response.statusCode != 200) {
      final error = ErrorNSO.fromJson(json.decode(response.body));
      throw HttpException("${response.statusCode}: ${error.errorDescription}");
    }

    return AccessToken.fromJson(json.decode(response.body));
  }

  Future<Hash> _getHash(String accessToken, int timestamp) async {
    http.Client client = http.Client();
    Map<String, String> parameters = {
      "naIdToken": accessToken,
      "timestamp": "$timestamp",
    };
    Uri url = Uri.parse("https://s2s-hash-server.herokuapp.com/hash");
    final http.Response response = (await client.post(url, body: parameters));

    if (response.statusCode != 200) {
      throw HttpException("${response.statusCode}: Internal Server Error");
    }

    return Hash.fromJson(json.decode(response.body));
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
    final http.Response response = (await client.get(url, headers: headers));

    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 400:
          throw HttpException("${response.statusCode}: Bad Request.");
        case 404:
          throw HttpException("${response.statusCode}: Not Found.");
        case 427:
          throw HttpException("${response.statusCode}: Upgrade Required.");
        default:
          throw HttpException("${response.statusCode}: Internal Server Error.");
      }
    }

    return Flapg.fromJson(json.decode(response.body));
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
    final String body = json.encode(parameters);

    Uri url =
        Uri.parse("https://api-lp1.znc.srv.nintendo.net/v3/Account/Login");

    final http.Response response =
        (await client.post(url, headers: headers, body: body));
    try {
      return SplatoonToken.fromJson(json.decode(response.body));
    } catch (e) {
      final error = ErrorAPP.fromJson(json.decode(response.body));
      throw HttpException("${error.status}: ${error.errorMessage}");
    }
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
    final http.Response response =
        await client.post(url, headers: headers, body: json.encode(parameters));

    try {
      return SplatoonAccessToken.fromJson(json.decode(response.body));
    } catch (e) {
      final error = ErrorAPP.fromJson(json.decode(response.body));
      throw HttpException("${error.status}: ${error.errorMessage}");
    }
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
      throw const HttpException("403: Forbidden.");
    }

    final String? iksmSession =
        RegExp(r"iksm_session=([0-9a-f]{40})").firstMatch(cookies)?.group(1);

    if (iksmSession == null) {
      throw const HttpException("403: Forbidden.");
    }

    return iksmSession;
  }

  Future<void> _getCookie(String sessionToken) async {
    final Version product = await _getVersion();
    final UserInfo userInfo = UserInfo(
        iksmSession: null,
        sessionToken: sessionToken,
        currentVersionReleaseDate: product.currentVersionReleaseDate,
        version: product.version,
        resultId: null);
    inspect(userInfo);
    _getAccessToken(sessionToken).then((accessToken) {
      inspect(sessionToken);
      return _getSplatoonTokenValue(accessToken, product.version);
    }).then((splatoonToken) {
      inspect(splatoonToken);
      return _getSplatoonAccessTokenValue(splatoonToken, product.version);
    }).then((splatoonAccessToken) {
      inspect(splatoonAccessToken);
      return _getIksmSession(splatoonAccessToken);
    }).then((iksmSession) {
      inspect(iksmSession);
      userInfo.iksmSession = iksmSession;
      return _getSummary(iksmSession);
    }).then((summary) {
      inspect(summary);
      userInfo.resultId = summary.summary.card.jobNum;
    }).catchError((error) {
      throw error;
    }).whenComplete(() {
      userInfo.toJson().forEach((key, value) {
        keychain.write(key: key, value: value.toString());
      });
    });
  }

  Future<void> getCookie(String sessionTokenCode) async {
    final SessionToken sessionToken = await _getSessionToken(sessionTokenCode);
    _getCookie(sessionToken.sessionToken);
  }

  Future<int> uploadResult(int resultId, String iksmSession) async {
    final int resultId = (await _getSummary(iksmSession)).summary.card.jobNum;

    final List<int> resultIds = range(resultId - 49, resultId).toList();
    await Future.forEach(resultIds, (data) async {
      final int resultId = data as int;
      final http.Response result = await _getResult(resultId, iksmSession);
      final http.Response uploadResult = await _uploadResult(result.body);
      inspect(uploadResult);
    });
    return 0;
  }

  Future<http.Response> _getResult(int resultId, String iksmSession) async {
    http.Client client = http.Client();
    Map<String, String> headers = {
      "cookie": "iksm_session=$iksmSession",
    };
    Uri url = Uri.parse(
        "https://app.splatoon2.nintendo.net/api/coop_results/${resultId}");
    return client.get(url, headers: headers);
  }

  Future<http.Response> _uploadResult(String result) {
    http.Client client = http.Client();
    Uri url = Uri.parse("https://api-dev.splatnet2.com/v1/results");
    Map<String, List<Object>> parameters = {
      "results": [json.decode(result)],
    };

    return client.post(url,
        headers: {"content-type": "application/json"},
        body: json.encode(parameters));
  }

  Future<Results> _getSummary(String iksmSession) async {
    http.Client client = http.Client();
    Map<String, String> headers = {
      "cookie": "iksm_session=$iksmSession",
    };
    Uri url = Uri.parse("https://app.splatoon2.nintendo.net/api/coop_results");

    final http.Response response = await client.get(url, headers: headers);
    return Results.fromJson(json.decode(response.body));
  }

  static final String oauthURL = (() {
    const String state = "V6DSwHXbqC4rspCn_ArvfkpG1WFSvtNYrhugtfqOHsF6SYyX";
    const String verifier = "OwaTAOolhambwvY3RXSD-efxqdBEVNnQkc0bBJ7zaak";
    const String challenge = "tYLPO5PxpK-DTcAHJXugD7ztvAZQlo0DQQp3au5ztuM";

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

    return Uri.decodeFull(Uri(
            scheme: "https",
            host: "accounts.nintendo.com",
            path: "connect/1.0.0/authorize",
            queryParameters: parameters)
        .toString());
  })();
}
