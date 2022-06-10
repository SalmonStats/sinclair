import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinclair/splatnet2.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:developer';
import 'iksm.dart';
import 'response.dart';
import 'package:url_launcher/url_launcher.dart';

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
          primarySwatch: Colors.blue,
        ),
        // home: const MyHomePage(title: 'Sinclair'),
        home: TabView());
  }
}

class TabView extends StatefulWidget {
  @override
  _TabViewState createState() => _TabViewState();
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
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center());
  }
}

class SettingView extends StatefulWidget {
  @override
  _SettingViewState createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
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
                  onPressed: () {
                    launchUrl(
                        Uri.parse("https://api-dev.splatnet2.com/documents"));
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
