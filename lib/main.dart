import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinclair/deeplink.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:developer';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
// Sinclair
import 'package:sinclair/iksm.dart';
import 'package:sinclair/response.dart';
import 'package:sinclair/splatnet2.dart';
import 'package:sinclair/deeplink.dart';

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
          primarySwatch: Colors.blue,
        ),
        // home: const MyHomePage(title: 'Sinclair'),
        home: TabView());
  }
}

class TabView extends StatefulWidget {
  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> with DeepLinkNotificationMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void onDeepLinkNotify(Uri? uri) {
    debugPrint(uri.toString());
    inspect(uri);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.home),
                text: "Home",
              ),
              // Tab(icon: Icon(Icons.snowing), text: "Salmon Stats"),
              Tab(icon: Icon(Icons.settings), text: "Settings"),
            ],
          ),
          title: const Text('Sinclair'),
        ),
        body: TabBarView(
          children: [
            HomeView(),
            // SalmonStatsView(),
            SettingView(),
          ],
        ),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center());
  }
}

class SettingView extends StatefulWidget {
  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  bool _isForceUpdated = false;
  Uri oauthURL = Uri.parse(
      "https://accounts.nintendo.com/connect/1.0.0/authorize?state=V6DSwHXbqC4rspCn_ArvfkpG1WFSvtNYrhugtfqOHsF6SYyX&redirect_uri=npf71b963c1b7b6d119://auth&client_id=71b963c1b7b6d119&scope=openid+user+user.birthday+user.mii+user.screenName&response_type=session_token_code&session_token_code_challenge=tYLPO5PxpK-DTcAHJXugD7ztvAZQlo0DQQp3au5ztuM&session_token_code_challenge_method=S256&theme=login_form");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
                title: const Text("Salmon Stats"),
                subtitle: const Text("Docs"),
                trailing: OutlinedButton(
                  child: const Text("Open"),
                  onPressed: () {
                    launchUrl(
                        Uri.parse("https://api-dev.splatnet2.com/documents"));
                  },
                )),
            ListTile(
                title: const Text("SplatNet2"),
                subtitle: const Text("Login"),
                trailing: OutlinedButton(
                  child: const Text("Login"),
                  onPressed: () {
                    launchUrl(oauthURL, mode: LaunchMode.externalApplication);
                  },
                )),
            const ListTile(
              title: Text('Iksm Session'),
              subtitle: Text("Meowing"),
            ),
            const ListTile(
              title: Text('Session Token'),
              subtitle: Text("Meowing"),
            ),
            const ListTile(
              title: Text('Result ID'),
              subtitle: Text("Meowing"),
            ),
            SwitchListTile(
                value: _isForceUpdated,
                onChanged: (bool newValue) {
                  setState(() {
                    _isForceUpdated = newValue;
                  });
                },
                title: const Text("Force update")),
          ],
        ),
      ),
    );
  }
}
