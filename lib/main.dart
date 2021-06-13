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

int themeSegmentState;
int themeRadioState;

class TheWeddingApp extends StatefulWidget {
  @override
  _TheWeddingAppState createState() => _TheWeddingAppState();
}

class _TheWeddingAppState extends State<TheWeddingApp> {
  int themeModeValue;

  Future<void> getThemeFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    int themeValue = prefs.getInt("themeValue");

    themeValue = (themeValue == null) ? 2 : themeValue;

    themeModeValue = themeValue;
  }

  @override
  void initState() {
    weddingAppTheme.addListener(() {
      setState(() {});
    });

    // cupertinoWeddingTheme.addListener(() {
    //   setState(() {});
    // });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getThemeFromStorage();
      setState(() {
        weddingAppTheme.changeTheme(themeModeValue);
        // cupertinoWeddingTheme.changeTheme(themeModeValue);
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
    ThemeData themeData = Theme.of(context);
    assert(themeData.platform != null);

    return Builder(
      builder: (context) {
        return MaterialApp(
          routes: {
            '/': (_) => MaterialHome(),
            'settings': (_) => MaterialSettingsPage(),
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

class MaterialSettingsPage extends StatefulWidget {
  @override
  _MaterialSettingsPageState createState() => _MaterialSettingsPageState();
}

class _MaterialSettingsPageState extends State<MaterialSettingsPage> {
  Color generateTextColor() {
    if (weddingAppTheme.themeMode == 0)
      return Colors.black;
    else if (weddingAppTheme.themeMode == 1)
      return Colors.white;
    else
      return (SchedulerBinding.instance.window.platformBrightness ==
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
                      themeRadioState = value;
                      weddingAppTheme.changeTheme(value);
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
                      themeRadioState = value;
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
                      themeRadioState = value;
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
