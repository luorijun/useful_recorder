import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';

enum CalendarMode {
  YEAR,
  MONTH,
  DATE,
}

typedef void CalendarModeEvent(CalendarMode mode);
typedef void DateTimeEvent(DateTime date);
typedef Widget DateWidgetBuilder(BuildContext context, DateTime day, DateTime month);

class Calendar extends StatelessWidget {
  Calendar({
    Key? key,
    DateTime? initDate,
    this.dateBuilder,
    this.statusBarBuilder,
    this.onSelectDate,
    this.onChangePage,
  }) : super(key: key) {
    this.initDate = initDate ?? DateTime.now();
  }

  /// 初始日期
  late final DateTime initDate;

  /// 日期组件插槽
  final DateWidgetBuilder? dateBuilder;

  /// 状态栏插槽
  final WidgetBuilder? statusBarBuilder;

  /// 选中日期事件
  final DateTimeEvent? onSelectDate;

  ///  切换页面事件
  final DateTimeEvent? onChangePage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 计算组件高度
    final height = MediaQuery.of(context).size.width / 7 * 6;
    return ChangeNotifierProvider(
      create: (BuildContext context) => CalendarState(
        page: initDate,
        pageHeight: 0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 操作栏
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 展示部分
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Builder(builder: (context) {
                    final page = context.select<CalendarState, DateTime>((state) => state.page);
                    return Text(
                      "${page.year} 年 ${page.month} 月",
                      style: theme.textTheme.headline5,
                    );
                  }),
                ),

                // 操作部分
                Row(children: [
                  Container(
                    width: 56,
                    height: 28,
                    margin: EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      child: Text("今天"),
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(0),
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Builder(builder: (context) {
                      final state = context.read<CalendarState>();
                      final viewMode = context.select<CalendarState, CalendarMode>((state) => state.mode);

                      final modes = [
                        CalendarMode.YEAR,
                        CalendarMode.MONTH,
                        CalendarMode.DATE,
                      ];

                      return ToggleButtons(
                        children: [
                          Text("年"),
                          Text("月"),
                          Text("日"),
                        ],
                        isSelected: [
                          viewMode == CalendarMode.YEAR,
                          viewMode == CalendarMode.MONTH,
                          viewMode == CalendarMode.DATE,
                        ],
                        constraints: BoxConstraints(
                          minHeight: 28,
                          minWidth: 32,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        onPressed: (index) {
                          state.mode = modes[index];
                        },
                      );
                    }),
                  ),
                ]),
              ],
            ),
          ),

          // 日历视图
          Container(
            child: Builder(builder: (context) {
              final viewMode = context.select<CalendarState, CalendarMode>((state) => state.mode);

              var view;
              // region switch
              switch (viewMode) {
                // 年视图
                case CalendarMode.YEAR:
                  view = Center(child: Text("年视图"));
                  break;
                // 月视图
                case CalendarMode.MONTH:
                  view = Center(child: Text("周视图"));
                  break;
                // 日视图
                case CalendarMode.DATE:

                  /// 日视图允许的最小日期
                  final DateTime _minMonth = DateTime(1900, 1, 1);
                  final List<String> _title = const ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];

                  // 计算从最小月份到现在偏移
                  var offset = (initDate.year - _minMonth.year) * 12;
                  offset += initDate.month - _minMonth.month;

                  // 绘制日视图，五百年内分页滑动
                  view = Builder(builder: (context) {
                    final state = context.read<CalendarState>();
                    final pageHeight = context.select<CalendarState, double>((state) => state.pageHeight);

                    return AnimatedContainer(
                      height: pageHeight,
                      duration: Duration(milliseconds: 200),
                      child: PageView.builder(
                        itemCount: 6000,
                        controller: PageController(initialPage: offset),
                        itemBuilder: (context, offset) {
                          final month = DateTime(_minMonth.year, _minMonth.month + offset, 1);

                          // 计算元素数量
                          final days = month.daysOfMonth + (month.weekday % 7);
                          final itemCount = days + ((7 - days % 7) % 7) + 7;

                          // 绘制当前页的月网格
                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: itemCount,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 1,
                            ),
                            itemBuilder: (context, index) {
                              // 绘制标题
                              if (index < 7) {
                                return Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    _title[index],
                                    style: theme.textTheme.caption,
                                  ),
                                );
                              }

                              // 绘制日期
                              var day = month.add(Duration(days: index - 7 - (month.weekday % 7)));

                              if (dateBuilder != null) {
                                return dateBuilder!(context, day, month);
                              }

                              if (day.sameMonth(month)) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    margin: EdgeInsets.all(4),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${day.day}",
                                      style: TextStyle(
                                        color: day.isFuture ? Colors.black26 : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  onTap: () => onSelectDate?.call(day),
                                );
                              } else {
                                return Container();
                              }
                            },
                          );
                        },
                        onPageChanged: (offset) {
                          final month = DateTime(_minMonth.year, _minMonth.month + offset, 1);
                          final days = month.daysOfMonth + (month.weekday % 7);
                          final itemCount = days + ((7 - days % 7) % 7) + 7;
                          final lines = itemCount / 7;
                          final height = MediaQuery.of(context).size.width / 7 * lines;
                          state.pageHeight = height;
                          state.page = month;
                          if (onChangePage != null) {
                            onChangePage!(month);
                          }
                        },
                      ),
                    );
                  });
                  break;
              }
              // endregion

              return view;
              // return PageTransitionSwitcher(
              //   transitionBuilder: (Widget child, Animation<double> primary, Animation<double> secondary) {
              //     return SharedAxisTransition(
              //       animation: primary,
              //       secondaryAnimation: secondary,
              //       transitionType: SharedAxisTransitionType.scaled,
              //     );
              //   },
              //   child: view,
              // );
            }),
          ),

          // 状态栏
          if (statusBarBuilder != null)
            Container(
              height: 32,
              child: statusBarBuilder!(context),
            )
        ],
      ),
    );
  }
}

class CalendarState extends ChangeNotifier {
  CalendarState({
    required DateTime page,
    required double pageHeight,
  }) {
    this._page = page;
    this._pageHeight = pageHeight;
    this._mode = CalendarMode.DATE;
  }

  late DateTime _page;
  late double _pageHeight;
  late CalendarMode _mode;

  DateTime get page {
    return _page;
  }

  set page(DateTime value) {
    _page = value;
    notifyListeners();
  }

  double get pageHeight {
    return _pageHeight;
  }

  set pageHeight(double value) {
    _pageHeight = value;
    notifyListeners();
  }

  CalendarMode get mode {
    return _mode;
  }

  set mode(CalendarMode mode) {
    _mode = mode;
    notifyListeners();
  }
}
