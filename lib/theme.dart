import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData.light();

ThemeData darkTheme = ThemeData.dark();

class WeddingAppTheme with ChangeNotifier {
  int themeMode;

  ThemeMode currentTheme() {
    if (themeMode == 0)
      return ThemeMode.light;
    else if (themeMode == 1)
      return ThemeMode.dark;
    else
      return ThemeMode.system;
  }

  void changeTheme(int themeModeValue) async {
    final prefs = await SharedPreferences.getInstance();

    themeModeValue = (themeModeValue == null) ? 2 : themeModeValue;

    await prefs.setInt("themeValue", themeModeValue);

    themeMode = themeModeValue;

    print(
      "Material: {themeModeValue: $themeModeValue, themeMode: $themeMode, themeValueSharedPreferences: ${prefs.getInt("themeValue")}}",
    );

    notifyListeners();
  }

  Future<int> getThemeModeInt() async {
    notifyListeners();

    return this.themeMode;
  }
}

class CupertinoWeddingTheme with ChangeNotifier {
  int themeModeInt;

  CupertinoThemeData light;

  CupertinoThemeData dark;

  CupertinoThemeData system;

  CupertinoWeddingTheme({
    @required CupertinoThemeData cupertinoThemeData,
    int defaultThemeMode,
  }) {
    light = CupertinoThemeData(
      barBackgroundColor: cupertinoThemeData.barBackgroundColor,
      brightness: Brightness.light,
      primaryColor: cupertinoThemeData.primaryColor,
      primaryContrastingColor: cupertinoThemeData.primaryContrastingColor,
      scaffoldBackgroundColor: cupertinoThemeData.scaffoldBackgroundColor,
      // textTheme: cupertinoThemeData.textTheme,
    );

    dark = CupertinoThemeData(
      barBackgroundColor: cupertinoThemeData.barBackgroundColor,
      brightness: Brightness.dark,
      primaryColor: cupertinoThemeData.primaryColor,
      primaryContrastingColor: cupertinoThemeData.primaryContrastingColor,
      scaffoldBackgroundColor: cupertinoThemeData.scaffoldBackgroundColor,
      // textTheme: cupertinoThemeData.textTheme,
    );

    system = cupertinoThemeData;
  }

  CupertinoThemeData getTheme() {
    if (this.themeModeInt == 0)
      return light;
    else if (this.themeModeInt == 1)
      return dark;
    else
      return system;
  }

  void changeTheme(int themeModeInt) async {
    final prefs = await SharedPreferences.getInstance();

    themeModeInt = (themeModeInt == null) ? 2 : themeModeInt;

    this.themeModeInt = themeModeInt;

    await prefs.setInt("themeValue", themeModeInt);

    print(
      "Cupertino: {themeModeValue: $themeModeInt, themeMode: ${getTheme().brightness}, themeValueSharedPreferences: ${prefs.getInt("themeValue")}}",
    );

    notifyListeners();
  }
}
