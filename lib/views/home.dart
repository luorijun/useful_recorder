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
      child: Builder(builder: (context) {
        final state = context.read<HomePageState>();
        final index = context.select<HomePageState, int>((state) => state.index);
        return Scaffold(
          body: PageTransitionSwitcher(
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
          ),
          bottomNavigationBar: Container(
            child: BottomNavigationBar(
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
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: .25,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ),
          ),
          floatingActionButton: index == 0
              ? Container(
                  child: Builder(builder: (context) {
                    return FloatingActionButton.extended(
                      elevation: 0,
                      icon: Icon(Icons.add),
                      label: Text('新增记录'),
                      backgroundColor: Colors.white,
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            builder: (context) {
                              return Container(
                                margin: EdgeInsets.all(16),
                                padding: EdgeInsets.all(8),
                                height: 300,
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: Text("关闭"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: ButtonStyle(),
                                      ),
                                      ElevatedButton(
                                        child: Text("保存"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: ButtonStyle(
                                          elevation: MaterialStateProperty.all(0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(width: .25, color: theme.colorScheme.tertiary),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              );
                            });
                      },
                    );
                  }),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: .35,
                      color: theme.colorScheme.tertiary,
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                )
              : null,
        );
      }),
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
