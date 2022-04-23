import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:useful_recorder/constants.dart';
import 'package:useful_recorder/views/home.dart';

void main() {
  runApp(UsefulRecorderApp());
}

Future<void> initOnFirstRun() async {
  final preference = await SharedPreferences.getInstance();

  final mensesLength = preference.getInt(MENSES_LENGTH);
  if (mensesLength == null) {
    preference.setInt(MENSES_LENGTH, 5);
  }

  final periodLength = preference.getInt(PERIOD_LENGTH);
  if (periodLength == null) {
    preference.setInt(PERIOD_LENGTH, 28);
  }
}

class UsefulRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 开发模式下保持屏幕常亮
    // if (kDebugMode) {
    //   Wakelock.enable();
    // }

    // 状态栏置为透明色
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: "Useful Recorder",
      theme: ThemeData.from(
        colorScheme: ColorScheme.light(
          // hsl(345, 85%, 75%)
          primary: Color(0xfff589a4),
          // hsl(345, 85%, 90%)
          primaryContainer: Color(0xfffbd0db),
          secondary: Color(0xffe6e6e6),
          tertiary: Color(0xffcccccc),
          // hsl(0, 0%, 90%)
          tertiaryContainer: Color(0xffe6e6e6),
          // hsl(0, 0%, 98%)
          background: Color(0xfff7f7f7),
        ),
        textTheme: TextTheme(
            caption: TextStyle(
          color: Color(0xff999999),
        )),
      ),
      home: FutureBuilder(
        future: initOnFirstRun(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Scaffold(
              body: CircularProgressIndicator(),
            );
          }

          return HomePage();
        },
      ),
    );
  }
}
