import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';
import 'package:useful_recorder/views/records/records.dart';

typedef void DateTimeEvent(DateTime date);
typedef Widget DateWidgetBuilder(BuildContext context, DateTime day, DateTime month);

class CalendarState extends ChangeNotifier {
  CalendarState({
    required double viewWidth,
    required DateTime month,
  }) : this._viewWidth = viewWidth {
    log('初始化 calendar 组件状态');
    // 初始化为日视图
    this.containerHeight = _calcHeightByMonth(month);

    // 计算从最小月份到现在偏移
    this.monthViewController = PageController(
      initialPage: monthToOffset(month),
    );
  }

  late PageController monthViewController;
  late double containerHeight;

  // 仅用于计算视图大小
  final double _viewWidth;
  final DateTime _minMonth = DateTime(1900, 1, 1);

  updateHeight(DateTime month) {
    this.containerHeight = _calcHeightByMonth(month);
    notifyListeners();
  }

  DateTime offsetToMonth(int offset) => DateTime(_minMonth.year, _minMonth.month + offset, 1);

  int monthToOffset(DateTime month) => (month.year - _minMonth.year) * 12 + month.month - _minMonth.month;

  double _calcHeightByMonth(DateTime month) {
    final days = month.daysInMonth + (month.weekday % 7);
    final itemCount = days + ((7 - days % 7) % 7);
    final lines = itemCount / 7;
    return _viewWidth / 7 * lines;
  }
}

class Calendar extends StatelessWidget {
  Calendar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 16;
    final initDate = context.read<RecordsViewState>().month;

    return ChangeNotifierProvider(
      create: (BuildContext context) => CalendarState(viewWidth: width, month: initDate),
      child: CalendarRoot(children: [
        CalendarActionBar(children: [
          Builder(builder: (context) {
            final month = context.select<RecordsViewState, DateTime>((state) => state.month);
            return ActionBarDateView(text: "${month.year} 年 ${month.month} 月");
          }),
          ActionBarOperations(children: [
            Builder(builder: (context) {
              final state = context.read<CalendarState>();
              final recordsState = context.read<RecordsViewState>();
              return OperationToToday(onPressed: () {
                final from = state.monthToOffset(recordsState.month);
                final to = state.monthToOffset(DateTime.now().toMonth);
                final length = (from - to).abs();
                length >= 5
                    ? state.monthViewController.jumpToPage(to)
                    : state.monthViewController.animateToPage(
                        to,
                        duration: Duration(milliseconds: length * 400),
                        curve: Curves.fastOutSlowIn,
                      );
                recordsState.selectDate(DateTime.now().toDate);
              });
            }),
            // todo 视图切换转移到标题栏
            // Builder(builder: (context) {
            //   final state = context.read<RecordsViewState>();
            //   final mode = context.select<RecordsViewState, CalendarMode>((state) => state.calendarMode);
            //   return OperationViewModeSwitcher(
            //     mode: mode,
            //     onSelect: (mode) => state.changeCalendar(mode),
            //   );
            // }),
          ]),
        ]),

        // 日历视图
        Builder(builder: (context) {
          final mode = context.select<RecordsViewState, CalendarMode>((state) => state.calendarMode);
          switch (mode) {
            // 全部视图
            case CalendarMode.ALL:
              return AllView();
            // 年视图
            case CalendarMode.YEAR:
              return YearView();
            // 月视图
            case CalendarMode.MONTH:
              return MonthView();
          }
        }),

        // 状态栏
        CalendarStatusBar(),
      ]),
    );
  }
}

class AllView extends StatelessWidget {
  const AllView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log('构造 AllView 组件');
    return Center(child: Text("总视图"));
  }
}

class YearView extends StatelessWidget {
  const YearView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log('构造 YearView 组件');
    return Center(child: Text("年视图"));
  }
}

class MonthView extends StatelessWidget {
  const MonthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log('构造 MonthView 组件');
    final theme = Theme.of(context);

    return Column(
      children: [
        // 标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"].map((e) {
              return Text(e, style: theme.textTheme.caption);
            }).toList(growable: false),
          ),
        ),

        // 内容网格
        Builder(builder: (context) {
          final state = context.read<CalendarState>();
          final recordsState = context.read<RecordsViewState>();
          final pageHeight = context.select<CalendarState, double>((state) => state.containerHeight);
          return AnimatedContainer(
            height: pageHeight,
            duration: Duration(milliseconds: 200),
            child: PageView.builder(
              itemCount: 6000,
              controller: state.monthViewController,
              itemBuilder: (context, offset) {
                final month = state.offsetToMonth(offset);

                // 计算元素数量
                final days = month.daysInMonth + (month.weekday % 7);
                final itemCount = days + ((7 - days % 7) % 7);

                // 绘制当前页的月网格
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: itemCount,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      var day = month.add(Duration(days: index - (month.weekday % 7)));

                      return DateView(day, month);
                    },
                  ),
                );
              },
              onPageChanged: (offset) {
                final month = state.offsetToMonth(offset);
                state.updateHeight(month);
                recordsState.changeMonth(month);
              },
            ),
          );
        }),
      ],
    );
  }
}

class DateView extends StatelessWidget {
  DateView(this.date, this.month, {Key? key}) : super(key: key);

  final DateTime date;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    if (!date.sameMonth(month)) {
      return Container();
    }

    return Builder(builder: (context) {
      final recordsState = context.read<RecordsViewState>();
      final selected = context.select<RecordsViewState, DateInfo>((state) => state.selected);
      final monthData = context.select<RecordsViewState, Map<DateTime, DateInfo>>((value) => value.monthData);

      final data = monthData[date];
      final record = data?.curr;
      final mode = data?.mode;

      //  根据选中日期的记录展示经期，状态和日记提示点
      var mensesDot = false;
      var statusDot = false;
      var noteDot = false;
      if (record != null) {
        if (record.pain != null || record.flow != null) {
          mensesDot = true;
        }
        if (record.emotion != null && record.weather != null) {
          statusDot = true;
        }
        if (record.title != null && record.note != null) {
          noteDot = true;
        }
      }

      // 根据选中日期的记录类型改变颜色
      var color = Colors.transparent;
      switch (mode) {
        case DateMode.MENSES:
          color = Colors.red.shade200;
          break;
        case DateMode.OVULATION:
          color = Colors.purple.shade200;
          break;
        case DateMode.SENSITIVE:
          color = Colors.purple.shade300;
          break;
        default:
          break;
      }

      // 如果是未来日期则淡化文字颜色
      final style = date.isFuture ? TextStyle(color: Colors.grey) : null;

      return GestureDetector(
        key: Key('${date.millisecondsSinceEpoch}'),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 60),
          margin: EdgeInsets.all(4),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${date.day}", style: style),
              // todo 添加提示点
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       width: 4,
              //       height: 4,
              //       margin: EdgeInsets.all(2),
              //       decoration: BoxDecoration(
              //         color: Colors.red,
              //         shape: BoxShape.circle,
              //       ),
              //     ),
              //     Container(
              //       width: 4,
              //       height: 4,
              //       margin: EdgeInsets.all(2),
              //       decoration: BoxDecoration(
              //         color: Colors.green,
              //         shape: BoxShape.circle,
              //       ),
              //     ),
              //     Container(
              //       width: 4,
              //       height: 4,
              //       margin: EdgeInsets.all(2),
              //       decoration: BoxDecoration(
              //         color: Colors.blue,
              //         shape: BoxShape.circle,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
          decoration: BoxDecoration(
            color: color,
            border: selected.date.sameDay(date) ? Border.all() : null,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        onTap: () {
          recordsState.selectDate(date);
        },
      );
    });
  }
}

// ==============================
// 样式
// ==============================

class CalendarRoot extends StatelessWidget {
  const CalendarRoot({Key? key, required this.children}) : super(key: key);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children,
      mainAxisSize: MainAxisSize.min,
    );
  }
}

class CalendarActionBar extends StatelessWidget {
  const CalendarActionBar({Key? key, required this.children}) : super(key: key);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}

class ActionBarDateView extends StatelessWidget {
  const ActionBarDateView({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Text(text, style: theme.textTheme.headline5),
    );
  }
}

class ActionBarOperations extends StatelessWidget {
  const ActionBarOperations({Key? key, required this.children}) : super(key: key);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(children: children),
    );
  }
}

class OperationToToday extends StatelessWidget {
  const OperationToToday({Key? key, required this.onPressed}) : super(key: key);
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 28,
      margin: EdgeInsets.only(right: 8),
      child: ElevatedButton(
        child: Text("今天"),
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
        ),
      ),
    );
  }
}

class OperationViewModeSwitcher extends StatelessWidget {
  OperationViewModeSwitcher({Key? key, required this.mode, required this.onSelect}) : super(key: key);

  final CalendarMode mode;
  final Function(CalendarMode) onSelect;
  final modes = [
    CalendarMode.ALL,
    CalendarMode.YEAR,
    CalendarMode.MONTH,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16),
      child: ToggleButtons(
        children: [
          Text("年"),
          Text("月"),
          Text("日"),
        ],
        isSelected: [
          mode == CalendarMode.ALL,
          mode == CalendarMode.YEAR,
          mode == CalendarMode.MONTH,
        ],
        constraints: BoxConstraints(
          minHeight: 28,
          minWidth: 32,
        ),
        borderRadius: BorderRadius.circular(4),
        onPressed: (index) => onSelect(modes[index]),
      ),
    );
  }
}

class CalendarStatusBar extends StatelessWidget {
  const CalendarStatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
