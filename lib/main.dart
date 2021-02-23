import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:useful_recorder/themes.dart';
import 'package:useful_recorder/views/home.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(UsefulRecorderApp());
}

class UsefulRecorderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ApplicationState(themes.normal),
      child: Consumer<ApplicationState>(
        builder: (context, state, child) => MaterialApp(
          title: "Useful Recorder",
          theme: state.theme,
          home: HomePage(),
        ),
      ),
    );
  }
}

class ApplicationState extends ChangeNotifier {
  ThemeData _theme;

  ThemeData get theme => _theme;

  set theme(ThemeData value) {
    _theme = value;
    notifyListeners();
  }

  ApplicationState(this._theme);
}
