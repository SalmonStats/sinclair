import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
// Sinclair
import 'package:sinclair/iksm/iksm.dart';
import 'package:sinclair/deeplink.dart';
import 'package:sinclair/iksm/user_info.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

class _TabViewState extends State<TabView> {
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
              Tab(icon: Icon(Icons.settings), text: "Settings"),
            ],
          ),
          title: const Text('Sinclair'),
        ),
        body: TabBarView(
          children: [
            HomeView(),
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

class _SettingViewState extends State<SettingView>
    with DeepLinkNotificationMixin {
  final SplatNet2 session = SplatNet2();

  @override
  void initState() {
    super.initState();
  }

  @override
  void onDeepLinkNotify(Uri? uri) {
    if (uri == null) {
      return;
    }

    final RegExp regex = RegExp("de=(.*)&");
    final RegExpMatch? match = regex.firstMatch(uri.toString());
    final String? sessionTokenCode = match?.group(1);

    if (sessionTokenCode == null) {
      return;
    }

    session.getCookie(sessionTokenCode).then(
      (userInfo) {
        inspect(userInfo);
        setState(() {
          _userInfo = userInfo;
        });
      },
    );
  }

  UserInfo? _userInfo = null;
  bool _isForceUpdated = false;

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
                  onPressed: () async {
                    launchUrlString(SplatNet2.oauthURL,
                        mode: LaunchMode.externalApplication);
                  },
                )),
            ListTile(
              title: Text('Release Date'),
              subtitle: Text(_userInfo?.currentVersionReleaseDate ?? "Unknown"),
            ),
            ListTile(
              title: Text('Iksm Session'),
              subtitle: Text(_userInfo?.iksmSession ?? "Unknown"),
            ),
            ListTile(
              title: Text('Session Token'),
              subtitle: Text(_userInfo?.sessionToken ?? "Unknown", maxLines: 1),
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
            ListTile(
              title: Text('Version'),
              subtitle: Text(_userInfo?.version ?? "Unknown"),
            ),
          ],
        ),
      ),
    );
  }
}
