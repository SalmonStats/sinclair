import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sinclair/deeplink.dart';
import 'package:sinclair/iksm/iksm.dart';
import 'package:sinclair/iksm/user_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingView extends StatefulWidget {
  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView>
    with DeepLinkNotificationMixin {
  final SplatNet2 session = SplatNet2();
  bool _isForceUpdated = false;
  UserInfo? _userInfo;

  @override
  void initState() {
    super.initState();
    session.addListener(() {
      debugPrint("Notification: UserInfo is updated.");
      inspect(session);
      setState(() {
        _userInfo = session.userInfo;
      });
    });
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

    session.getCookie(sessionTokenCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
                title: const Text("Salmon Stats"),
                subtitle: const Text("Home"),
                trailing: OutlinedButton(
                  child: const Text("Open"),
                  onPressed: () {
                    if (session.nsaid == null) {
                      launchUrl(Uri.parse("https://salmonstats.netlify.app/"));
                    } else {
                      launchUrl(Uri.parse(
                          "https://salmonstats.netlify.app/users/${session.nsaid}"));
                    }
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
              title: const Text('Player ID'),
              subtitle: Text(session.nsaid.toString()),
            ),
            ListTile(
              title: const Text('Iksm Session'),
              subtitle: Text(session.iksmSession.toString()),
            ),
            ListTile(
              title: const Text('Session Token'),
              subtitle: Text(session.sessionToken.toString(), maxLines: 1),
            ),
            ListTile(
              title: const Text('Expires In'),
              subtitle: Text(session.expiresIn.toString(), maxLines: 1),
            ),
            ListTile(
              title: const Text('Result ID'),
              subtitle: Text(session.resultId.toString()),
            ),
            // SwitchListTile(
            //     value: _isForceUpdated,
            //     onChanged: (bool newValue) {
            //       setState(() {
            //         _isForceUpdated = newValue;
            //       });
            //     },
            //     title: const Text("Force update")),
            ListTile(
              title: const Text('Version'),
              subtitle: Text(session.version.toString()),
            ),
            ListTile(
              title: const Text('Release Date'),
              subtitle: Text(session.currentVersionReleaseDate.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
