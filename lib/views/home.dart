import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_recorder/models/record.dart';
import 'package:useful_recorder/models/record_repository.dart';

import 'package:useful_recorder/views/period.dart';
import 'package:useful_recorder/views/record.dart';
import 'package:useful_recorder/views/analysis.dart';
import 'package:useful_recorder/views/settings.dart';

class HomePage extends StatelessWidget {
  final bodies = [
    PeriodView(),
    RecordView(),
    AnalysisView(),
    SettingsView(),
  ];

  final navs = [
    BottomNavigationBarItem(
      icon: Icon(Icons.timelapse),
      label: "首页",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today),
      label: "记录",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.analytics),
      label: "统计",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: "设置",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomePageState(
        title: "首页",
        page: 1,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Selector<HomePageState, String>(
              selector: (context, state) => state.title,
              builder: (context, title, child) {
                return Text(title);
              }),
        ),
        body: Builder(builder: (context) {
          final reverse = context.select<HomePageState, bool>(
            (state) => state.reverse,
          );

          final index = context.select<HomePageState, int>(
            (state) => state.index,
          );

          return PageTransitionSwitcher(
            reverse: reverse,
            transitionBuilder: (child, primary, secondary) {
              return SharedAxisTransition(
                animation: primary,
                secondaryAnimation: secondary,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
            child: bodies[index],
          );
        }),
        bottomNavigationBar: Selector<HomePageState, int>(
            selector: (context, state) => state.index,
            builder: (context, index, child) {
              return BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: index,
                onTap: (i) => context.read<HomePageState>().index = i,
                items: navs,
              );
            }),
      ),
    );
  }
}

class HomePageState extends ChangeNotifier {
  // region 索引属性

  int _older;
  int _newer;

  int get index => _newer;

  set index(int value) {
    _older = _newer;
    _newer = value;
    notifyListeners();
  }

  get reverse => _older > _newer;

  // endregion

  // region 标题属性

  String _title;

  String get title => _title;

  set title(String value) {
    _title = value;
    notifyListeners();
  }

  // endregion

  HomePageState({String title, int page}) {
    this._older = page;
    this._newer = page;
    this._title = title;
  }
}
