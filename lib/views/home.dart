import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_recorder/views/analysis/analysis.dart';
import 'package:useful_recorder/views/records/records.dart';
import 'package:useful_recorder/views/settings/settings.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomePageState([
        RecordsView(),
        AnalysisView(),
        SettingsView(),
      ]),
      child: Scaffold(
        body: Builder(builder: (context) {
          final state = context.watch<HomePageState>();

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
            child: state.pages[state.index],
          );
        }),
        bottomNavigationBar: Selector<HomePageState, int>(
          selector: (context, state) => state.index,
          builder: (context, index, child) {
            return BottomNavigationBar(
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              currentIndex: index,
              backgroundColor: Colors.white,
              onTap: (i) => context.read<HomePageState>().index = i,
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
            );
          },
        ),
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
