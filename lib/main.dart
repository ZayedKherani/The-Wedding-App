import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

import 'theme.dart';
import 'home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(TheWeddingApp());
}

WeddingAppTheme weddingAppTheme = WeddingAppTheme();

int? themeSegmentState;
int? themeRadioState;

class TheWeddingApp extends StatefulWidget {
  @override
  _TheWeddingAppState createState() => _TheWeddingAppState();
}

class _TheWeddingAppState extends State<TheWeddingApp> {
  int? themeModeValue;

  Future<void> getThemeFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    int themeValue = prefs.getInt("themeValue") ?? 2;

    themeModeValue = themeValue;
  }

  void getDefaultThemeRdaioState() async {
    final prefs = await SharedPreferences.getInstance();

    themeRadioState = prefs.getInt("themeValue");
  }

  @override
  void initState() {
    weddingAppTheme.addListener(() {
      setState(() {});
    });

    // cupertinoWeddingTheme.addListener(() {
    //   setState(() {});
    // });

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      await getThemeFromStorage();

      setState(() {
        weddingAppTheme.changeTheme(themeModeValue ?? 2);
        // cupertinoWeddingTheme.changeTheme(themeModeValue);

        getDefaultThemeRdaioState();
      });
    });

    setState(() {
      themeRadioState = weddingAppTheme.themeMode;
      // themeSegmentState = cupertinoWeddingTheme.themeModeInt;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ThemeData themeData = Theme.of(context);

    return Builder(
      builder: (context) {
        return MaterialApp(
          routes: {
            '/': (_) => WeddingHome(),
            'settings': (_) => SettingsPage(),
          },
          initialRoute: '/',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: weddingAppTheme.currentTheme(),
          debugShowCheckedModeBanner: false,
          title: 'The Wedding App',
        );
      },
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Color generateTextColor() {
    if (weddingAppTheme.themeMode == 0)
      return Colors.black;
    else if (weddingAppTheme.themeMode == 1)
      return Colors.white;
    else
      return (SchedulerBinding.instance!.window.platformBrightness ==
              Brightness.dark)
          ? Colors.white
          : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Settings"),
      ),
      body: Scrollbar(
        child: ListView(
          children: [
            Column(
              children: [
                Text(
                  "Theme",
                  style: TextStyle(
                    color: generateTextColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RadioListTile(
                  value: 0,
                  groupValue: themeRadioState,
                  onChanged: (value) {
                    setState(() {
                      themeRadioState = value as int?;
                      weddingAppTheme.changeTheme(value as int);
                    });
                  },
                  title: Text(
                    "Light",
                    style: TextStyle(
                      color: generateTextColor(),
                    ),
                  ),
                ),
                RadioListTile(
                  value: 1,
                  groupValue: themeRadioState,
                  onChanged: (value) {
                    setState(() {
                      themeRadioState = value as int;
                      weddingAppTheme.changeTheme(value);
                    });
                  },
                  title: Text(
                    "Dark",
                    style: TextStyle(
                      color: generateTextColor(),
                    ),
                  ),
                ),
                RadioListTile(
                  value: 2,
                  groupValue: themeRadioState,
                  onChanged: (value) {
                    setState(() {
                      themeRadioState = value as int;
                      weddingAppTheme.changeTheme(value);
                    });
                  },
                  title: Text(
                    "System",
                    style: TextStyle(
                      color: generateTextColor(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    await prefs.clear();
                  },
                  child: Text(
                    "Clear Storage",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
