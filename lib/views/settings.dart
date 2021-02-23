import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:useful_recorder/views/home.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.microtask(() => context.read<HomePageState>().title = '设置');

    return ChangeNotifierProvider(
      create: (_) => SettingsViewState(),
      child: Column(children: [
        ListTile(
          title: Text("周期天数"),
          trailing: Selector<SettingsViewState, int>(
            selector: (context, state) => state.periodLength,
            builder: (context, length, child) => Text("$length"),
          ),
        ),
        ListTile(
          title: Text("经期天数"),
          trailing: Selector<SettingsViewState, int>(
            selector: (context, state) => state.mensesLength,
            builder: (context, length, child) => Text("$length"),
          ),
        ),
      ]),
    );
  }
}

class SettingsViewState extends ChangeNotifier {
  int mensesLength;
  int periodLength;

  SettingsViewState() {
    initData();
  }

  initData() async {
    final sp = await SharedPreferences.getInstance();
    mensesLength = sp.containsKey('mensesLength') ? sp.getInt('mensesLength') : 5;
    periodLength = sp.containsKey('periodLength') ? sp.getInt('periodLength') : 28;
    notifyListeners();
  }
}
