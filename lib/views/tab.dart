import 'package:flutter/material.dart';
import 'package:sinclair/views/home.dart';
import 'package:sinclair/views/setting.dart';

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
