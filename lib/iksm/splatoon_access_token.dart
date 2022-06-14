import 'package:sinclair/iksm/splatoon_token.dart';

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
