import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_recorder/models/record.dart';
import 'package:useful_recorder/views/analysis/analysis.dart';
import 'package:useful_recorder/views/records/records.dart';
import 'package:useful_recorder/views/settings/settings.dart';

class HomePageState extends ChangeNotifier {
  HomePageState(this.pages) {
    this._older = 0;
    this._newer = 0;
  }

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

  // ==============================
  // region 注册页面状态
  // ==============================

  final Map<String, ChangeNotifier> states = {};

// endregion
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final state = HomePageState([
      RecordsView(),
      if (kDebugMode) AnalysisView(),
      SettingsView(),
    ]);

    return ChangeNotifierProvider(
      create: (context) => state,
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
                if (kDebugMode)
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
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.bug_report),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => BottomSheet(
                builder: (context) {
                  return FabSheetColumn(children: [
                    FabSheetButton(
                      child: Text("打印数据表"),
                      onPressed: () async {
                        final repo = RecordRepository();
                        final list = await repo.findAll();
                        final result = list.map((element) => Record.fromMap(element)).toList();
                        result.sort((a, b) => a.date!.compareTo(b.date!));
                        result.forEach((element) {
                          log('$element');
                        });
                        Navigator.pop(context);
                      },
                    ),
                    FabSheetButton(
                      child: Text("打印本页数据"),
                      onPressed: () {
                        final recordsState = state.states['recordsView'] as RecordsViewState;
                        recordsState.monthData.forEach((key, value) {
                          log('日期：$key，状态：${value.mode}');
                        });
                        Navigator.pop(context);
                      },
                    )
                  ]);
                },
                onClosing: () {},
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==============================
// 样式
// ==============================

class FabSheetColumn extends StatelessWidget {
  const FabSheetColumn({Key? key, required this.children}) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Column(
        children: children,
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}

class FabSheetButton extends StatelessWidget {
  const FabSheetButton({
    Key? key,
    this.child,
    this.onPressed,
  }) : super(key: key);

  final Widget? child;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ElevatedButton(
        child: child,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: Size.fromHeight(40),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
