import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:useful_recorder/constants.dart';
import 'package:useful_recorder/views/home.dart';
import 'package:wakelock/wakelock.dart';

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
    if (kDebugMode) {
      Wakelock.enable();
    }

    // 状态栏置为透明色
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return MaterialApp(
      title: "Useful Recorder",
      theme: ThemeData.from(
        colorScheme: ColorScheme.light(
          // hsl(345, 85%, 75%)
          primary: Color(0xfff589a4),
          // hsl(345, 85%, 90%)
          primaryContainer: Color(0xfffbd0db),
          // hsl(0, 0%, 90%)
          secondary: Color(0xffe6e6e6),
          // hsl(0, 0%, 98%)
          background: Color(0xfffafafa),
        ),
        // textTheme: TextTheme(
        //   bodyText1: TextStyle(
        //     fontSize: 12,
        //     color: Color(0xff999999),
        //   ),
        //   bodyText2: TextStyle(
        //     fontSize: 14,
        //     color: Color(0xff333333),
        //   ),
        // ),
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
