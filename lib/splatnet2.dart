import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'response.dart';

Iterable<int> range(int low, int high) sync* {
  for (int i = low; i < high; ++i) {
    yield i;
  }
}

Future<int> uploadResult(int resultId) async {
  final int resultId = (await _getSummary()).summary.card.jobNum;

  final List<int> resultIds = range(resultId - 49, resultId).toList();
  await Future.forEach(resultIds, (data) async {
    final int resultId = data as int;
    final http.Response result = await _get(resultId);
    debugPrint(result.toString());
  });
  return 0;
}

Future<http.Response> _get(int resultId) async {
  http.Client client = http.Client();
  String iksmSession = "ee930b7a558ae565c06ac3b2c7184b1bbb6f3087";
  Map<String, String> headers = {
    "cookie": "iksm_session=$iksmSession",
  };
  Uri url = Uri.parse(
      "https://app.splatoon2.nintendo.net/api/coop_results/${resultId}");
  return client.get(url, headers: headers);
}

Future<http.Response> _upload(String result) {
  http.Client client = http.Client();
  Uri url = Uri.parse("https://api.splatnet2.com/v1/results");
  Map<String, List<Object>> parameters = {
    "results": [json.decode(result)],
  };

  return client.post(url,
      headers: {"content-type": "application/json"},
      body: json.encode(parameters));
}

Future<Results> _getSummary() async {
  http.Client client = http.Client();
  String iksmSession = "ee930b7a558ae565c06ac3b2c7184b1bbb6f3087";
  Map<String, String> headers = {
    "cookie": "iksm_session=$iksmSession",
  };
  Uri url = Uri.parse("https://app.splatoon2.nintendo.net/api/coop_results");

  final http.Response response = await client.get(url, headers: headers);
  return Results.fromJson(json.decode(response.body));
}
