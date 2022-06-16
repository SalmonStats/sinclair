import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sinclair/iksm/iksm.dart';
import 'package:sinclair/views/alert.dart';
import 'package:velocity_x/velocity_x.dart';

class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final SplatNet2 session = SplatNet2();
  int resultIdMax = 0;
  int resultIdMin = 0;
  double progressValue = 0.0;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    session.addListener(() {
      setState(() {
        resultIdMax = session.resultCount;
        resultIdMin = session.resultNow;
        if (resultIdMax != 0) {
          progressValue = resultIdMin.toDouble() / resultIdMax.toDouble();
          debugPrint("Update Value ${progressValue}");
        }
      });
    });
  }

  void _showAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: const Text('No new results.'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            /// This parameter indicates this action is the default,
            /// and turns the action's text to bold text.
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as deletion, and turns
            /// the action's text color to red.
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ZStack([
          SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.grey,
                color: Colors.blue,
              )),
          SizedBox(
              width: 140,
              height: 140,
              child: Align(
                  alignment: Alignment.center,
                  child: Text("${resultIdMin}/${resultIdMax}",
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center)))
        ])),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            session.uploadResult().then((_) {
              debugPrint("Done");
            }).catchError((error) {
              _showAlertDialog(context);
              inspect(error);
            });
          },
          backgroundColor: Colors.blue,
          child: const Icon(Icons.autorenew),
        ));
  }
}
