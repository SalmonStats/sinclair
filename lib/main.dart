import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'response.dart';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Sinclair'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? iksm_session;
  int? resultId;

  void saveData(int resultId, String iksm_session) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('resultId', resultId);
    prefs.setString('iksm_session', iksm_session);

    setState(() {
      this.iksm_session = prefs.getString('iksm_session');
      this.resultId = prefs.getInt('resultId');
    });
  }

  void loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      this.iksm_session = prefs.getString('iksm_session');
      this.resultId = prefs.getInt('resultId');
    });
  }

  Results parseResults(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    // final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return Results.fromJson(parsed);
  }

  Future<http.Response> _fetch(int resultId) async {
    http.Client client = http.Client();
    String iksm_session = "ee930b7a558ae565c06ac3b2c7184b1bbb6f3087";
    Map<String, String> headers = {
      "cookie": "iksm_session=$iksm_session",
    };
    Uri url = Uri.parse(
        "https://app.splatoon2.nintendo.net/api/coop_results/${resultId}");
    return client.get(url, headers: headers);
  }

  Future<http.Response> _post(String result) {
    http.Client client = http.Client();
    Uri url = Uri.parse("http://localhost:3000/v1/results");
    Map<String, List<Object>> parameters = {
      "results": [json.decode(result)],
    };
    return client.post(url,
        headers: {"content-type": "application/json"},
        body: json.encode(parameters));
  }

  Future<Results> _summary() async {
    http.Client client = http.Client();
    String iksm_session = "ee930b7a558ae565c06ac3b2c7184b1bbb6f3087";
    Map<String, String> headers = {
      "cookie": "iksm_session=$iksm_session",
    };
    Uri url = Uri.parse("https://app.splatoon2.nintendo.net/api/coop_results");
    final response = await client.get(url, headers: headers);
    return parseResults(response.body);
  }

  void _request() async {
    if (iksm_session == null) {
      throw Exception("iksm_session is null");
    }

    if (resultId == null) {
      throw Exception("result_id is null");
    }

    _summary()
        .then((value) => inspect(value))
        .catchError((error) => debugPrint(error.toString()));
    //  _fetch(resultId!)
    //     .then((result) => _post(result.body))
    //     .then((response) => debugPrint(response.body))
    //     .catchError((error) {
    //   debugPrint(error.toString());
    // });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
                onSubmitted: (String value) async {
                  saveData(0, value);
                },
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "session_token")),
            TextField(
                onSubmitted: (String value) async {
                  saveData(0, value);
                },
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "result_id")),
            TextField(
                onSubmitted: (String value) async {
                  saveData(0, value);
                },
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "iksm_session")),
            Text(
                "Your iksm Session is ${iksm_session == null ? "unset" : "set"}"),
            Text("Your resultId is ${resultId ?? 0}"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _request,
        tooltip: 'Request',
        child: const Icon(Icons.autorenew_sharp),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
