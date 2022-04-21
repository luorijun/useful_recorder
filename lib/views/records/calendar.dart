import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';
import 'package:useful_recorder/views/records/records.dart';

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
    final width = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (BuildContext context) => CalendarState(
        viewWidth: width,
        page: initDate,
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
                    final month = context.select<CalendarState, DateTime>((state) => state.month);
                    return Text(
                      "${month.year} 年 ${month.month} 月",
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
                    child: Builder(builder: (context) {
                      final state = context.read<CalendarState>();
                      return ElevatedButton(
                        child: Text("今天"),
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () {
                          final from = state.monthToOffset(state.month);
                          final to = state.monthToOffset(DateTime.now().toMonth);
                          final length = (from - to).abs();
                          length < 5
                              ? state.monthViewController.animateToPage(
                                  to,
                                  duration: Duration(milliseconds: length * 500),
                                  curve: Curves.fastOutSlowIn,
                                )
                              : state.monthViewController.jumpToPage(to);
                        },
                      );
                    }),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Builder(builder: (context) {
                      final state = context.read<RecordsViewState>();
                      final viewMode = context.select<RecordsViewState, CalendarMode>((state) => state.mode);

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
              final viewMode = context.select<RecordsViewState, CalendarMode>((state) => state.mode);

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
                  view = Builder(builder: (context) {
                    final state = context.read<CalendarState>();
                    final pageHeight = context.select<CalendarState, double>((state) => state.containerHeight);

                    return AnimatedContainer(
                      height: pageHeight,
                      duration: Duration(milliseconds: 200),
                      child: PageView.builder(
                        itemCount: 6000,
                        controller: state.monthViewController,
                        itemBuilder: (context, offset) {
                          final month = DateTime(state._minMonth.year, state._minMonth.month + offset, 1);

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
                                    state._title[index],
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
                          final month = state.offsetToMonth(offset);
                          state.month = month;
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
    required double viewWidth,
    required DateTime page,
  }) : this._viewWidth = viewWidth {
    // 初始化为日视图
    this._month = page;
    this._containerHeight = calcHeightByMonth();

    // 计算从最小月份到现在偏移
    this.monthViewController = PageController(
      initialPage: monthToOffset(page),
    );
  }

  // 仅用于计算视图大小
  final double _viewWidth;
  final DateTime _minMonth = DateTime(1900, 1, 1);
  final List<String> _title = const ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];

  late double _containerHeight;

  late DateTime _month;
  late PageController monthViewController;

  DateTime get month => _month;

  set month(DateTime value) {
    _month = value;
    _containerHeight = calcHeightByMonth();
    notifyListeners();
  }

  double get containerHeight => _containerHeight;

  DateTime offsetToMonth(int offset) => DateTime(_minMonth.year, _minMonth.month + offset, 1);

  int monthToOffset(DateTime month) => (month.year - _minMonth.year) * 12 + month.month - _minMonth.month;

  double calcHeightByMonth() {
    final days = _month.daysOfMonth + (_month.weekday % 7);
    final itemCount = days + ((7 - days % 7) % 7) + 7;
    final lines = itemCount / 7;
    return _viewWidth / 7 * lines;
  }
}
