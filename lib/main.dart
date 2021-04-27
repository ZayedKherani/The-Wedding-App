import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'home.dart';

void main() {
  runApp(TheWeddingApp());
}

class TheWeddingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    assert(themeData.platform != null);

    switch (themeData.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'The Wedding App',
          home: MaterialHome(),
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoApp(
          debugShowCheckedModeBanner: false,
          home: CupertinoHome(),
        );
    }
    return Center(
      child: CupertinoActivityIndicator(),
    );
  }
}
