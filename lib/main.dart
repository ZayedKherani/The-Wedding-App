import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

import 'theme.dart';
import 'home.dart';

//TODO: Fix entire Material App after git update

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(TheWeddingApp());
}

WeddingAppTheme weddingAppTheme = WeddingAppTheme();

CupertinoWeddingTheme cupertinoWeddingTheme = CupertinoWeddingTheme(
  cupertinoThemeData: CupertinoThemeData(),
);

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

    cupertinoWeddingTheme.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getThemeFromStorage();
      setState(() {
        weddingAppTheme.changeTheme(themeModeValue);
        cupertinoWeddingTheme.changeTheme(themeModeValue);
      });
    });

    setState(() {
      themeRadioState = weddingAppTheme.themeMode;
      themeSegmentState = cupertinoWeddingTheme.themeModeInt;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    assert(themeData.platform != null);

    return Builder(
      builder: (context) {
        switch (themeData.platform) {
          case TargetPlatform.android:
          case TargetPlatform.fuchsia:
          case TargetPlatform.linux:
          case TargetPlatform.windows:
          // return MaterialApp(
          //   routes: {
          //     '/': (_) => MaterialHome(),
          //     'settings': (_) => MaterialSettingsPage(),
          //   },
          //   initialRoute: '/',
          //   theme: lightTheme,
          //   darkTheme: darkTheme,
          //   themeMode: weddingAppTheme.currentTheme(),
          //   debugShowCheckedModeBanner: false,
          //   title: 'The Wedding App',
          // );
          case TargetPlatform.iOS:
          case TargetPlatform.macOS:
            return CupertinoApp(
              theme: cupertinoWeddingTheme.getTheme(),
              debugShowCheckedModeBanner: false,
              initialRoute: '/',
              routes: {
                '/': (_) => CupertinoHome(),
                'settings': (_) => CupertinoSettings(),
              },
            );
        }

        return Center(
          child: CupertinoActivityIndicator(),
        );
      },
    );
  }
}

class CupertinoSettings extends StatefulWidget {
  @override
  _CupertinoSettingsState createState() => _CupertinoSettingsState();
}

class _CupertinoSettingsState extends State<CupertinoSettings> {
  Brightness currentThemeMode;

  TextStyle generateTextStyle() {
    if (cupertinoWeddingTheme.themeModeInt == 0 ||
        cupertinoWeddingTheme.themeModeInt == 1)
      return null;
    else {
      return (SchedulerBinding.instance.window.platformBrightness ==
              Brightness.light)
          ? cupertinoWeddingTheme.light.textTheme.textStyle
          : cupertinoWeddingTheme.dark.textTheme.textStyle;
    }
  }

  @override
  void initState() {
    setState(() {
      currentThemeMode = SchedulerBinding.instance.window.platformBrightness;

      themeSegmentState = cupertinoWeddingTheme.themeModeInt;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (SchedulerBinding.instance.window.platformBrightness !=
        currentThemeMode) {
      setState(() {
        currentThemeMode = SchedulerBinding.instance.window.platformBrightness;
      });
    }

    return Builder(
      builder: (context) {
        return CupertinoPageScaffold(
          child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                CupertinoSliverNavigationBar(
                  largeTitle: Text("Settings"),
                  previousPageTitle: "The Wedding App",
                ),
              ];
            },
            body: CupertinoScrollbar(
              child: ListView(
                children: [
                  CupertinoFormSection(
                    children: [
                      CupertinoFormRow(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Text(
                                "Theme",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoDynamicColor.resolve(
                                    CupertinoDynamicColor.withBrightness(
                                      color: Colors.black,
                                      darkColor: Colors.white,
                                    ),
                                    context,
                                  ),
                                ),
                              ),
                              CupertinoSegmentedControl(
                                onValueChanged: (value) {
                                  setState(() {
                                    themeSegmentState = value;
                                    cupertinoWeddingTheme.changeTheme(value);
                                  });
                                },
                                groupValue: themeSegmentState,
                                children: {
                                  0: Text(
                                    "Light",
                                  ),
                                  1: Text(
                                    "Dark",
                                  ),
                                  2: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      "System",
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      CupertinoFormRow(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Text(
                                "Notification",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoDynamicColor.resolve(
                                    CupertinoDynamicColor.withBrightness(
                                      color: Colors.black,
                                      darkColor: Colors.white,
                                    ),
                                    context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
