import 'dart:io';
import 'dart:async';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/material.dart';

mixin DeepLinkNotificationMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription? _sub;
  @override
  void initState() {
    //DeepLinkの監視
    _sub = uriLinkStream.listen(_onNewNotify);
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void onDeepLinkNotify(Uri? uri);

  void _onNewNotify(Uri? uri) {
    if (mounted) onDeepLinkNotify(uri);
  }
}
