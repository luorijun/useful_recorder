import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_recorder/views/analysis/analysis.dart';
import 'package:useful_recorder/views/records/records.dart';
import 'package:useful_recorder/views/settings/settings.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (context) => HomePageState([
        RecordsView(),
        AnalysisView(),
        SettingsView(),
      ]),
      child: Scaffold(
        body: Builder(builder: (context) {
          final state = context.read<HomePageState>();
          final page = context.select<HomePageState, Widget>((state) => state.page);
          return PageTransitionSwitcher(
            reverse: state.reverse,
            transitionBuilder: (child, primary, secondary) {
              return SharedAxisTransition(
                animation: primary,
                secondaryAnimation: secondary,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
            child: page,
          );
        }),
        bottomNavigationBar: Builder(builder: (context) {
          final state = context.read<HomePageState>();
          final index = context.select<HomePageState, int>((state) => state.index);
          return Container(
            child: BottomNavigationBar(
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              currentIndex: index,
              backgroundColor: Colors.white,
              onTap: (i) => state.index = i,
              items: [
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
              ],
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: .25,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class HomePageState extends ChangeNotifier {
  List<Widget> pages;

  late int _older;
  late int _newer;

  Widget get page => pages[index];

  int get index => _newer;

  set index(int value) {
    _older = _newer;
    _newer = value;
    notifyListeners();
  }

  get reverse => _older > _newer;

  HomePageState(this.pages) {
    this._older = 0;
    this._newer = 0;
  }
}
