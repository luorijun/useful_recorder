import 'dart:developer';

import 'package:flutter/material.dart';

typedef void DateTimeEvent(DateTime date);
typedef void DateSelectedEvent(DateTime day, DateTime month);
typedef T DateTimeBuilder<T>(DateTime date);
typedef T DateBuilder<T>(DateTime date, DateTime month);

//==============================================================================
// 日历组件
//==============================================================================

//==============================================================================
// 年份视图
//==============================================================================

//==============================================================================
// 月份视图
//==============================================================================

class MonthView extends StatelessWidget {
  final DateTime initDate;
  final DateTime startDate;
  final DateTime endMonth;

  final int firstWeek;

  final double gap;
  final Axis direction;
  final DateBuilder<Widget> dateBuilder;
  final DateSelectedEvent onDateSelected;
  final DateTimeEvent onMonthChanged;

  MonthView({
    Key key,
    @required this.initDate,
    @required this.startDate,
    this.endMonth,
    firstWeek = DateTime.sunday,
    this.gap = 8,
    this.direction = Axis.horizontal,
    this.dateBuilder,
    this.onDateSelected,
    this.onMonthChanged,
  })  : this.firstWeek = firstWeek % 7,
        super(key: key);

  final _title = const ["日", "一", "二", "三", "四", "五", "六"];

  @override
  Widget build(BuildContext context) {
    final title = _MonthBuilder(
      gap: gap,
      count: 7,
      builder: (context, index) {
        final offset = (firstWeek + index) % 7;
        return Center(child: Text("${_title[offset]}"));
      },
    );

    var offset = (initDate.year - startDate.year) * 12;
    offset += initDate.month - startDate.month;

    final body = PageView.builder(
      controller: PageController(initialPage: offset),
      itemBuilder: (context, index) {
        final now = DateTime(
          startDate.year,
          startDate.month + index,
        );

        final month = Month(
          month: now,
          firstWeek: firstWeek,
          gap: gap,
          builder: dateBuilder,
          onDateSelected: onDateSelected,
        );

        return month;
      },
      onPageChanged: (index) {
        onMonthChanged?.call(DateTime(
          startDate.year,
          startDate.month + index,
        ));
      },
    );

    final query = MediaQuery.of(context);
    final height = (query.size.width - gap * 2.0) / 7.0 * 6.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        title,
        Container(
          height: height,
          child: Material(
            child: body,
          ),
        ),
      ],
    );
  }
}

class Month extends StatelessWidget {
  final DateTime month;
  final double gap;
  final DateTime firstDayOfWeek;
  final DateSelectedEvent onDateSelected;
  final DateBuilder<Widget> builder;

  Month({
    Key key,
    @required this.month,
    @required int firstWeek,
    this.gap,
    this.onDateSelected,
    this.builder,
  })  : this.firstDayOfWeek = month.subtract(Duration(
          days: (month.weekday + 7 - firstWeek) % 7,
        )),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return _MonthBuilder(
      gap: gap,
      count: 7 * 6,
      builder: (context, index) {
        var now = firstDayOfWeek.add(Duration(days: index));
        return builder?.call(now, month);
      },
    );
  }
}

class _MonthBuilder extends StatelessWidget {
  final double gap;
  final int count;
  final IndexedWidgetBuilder builder;

  const _MonthBuilder({
    Key key,
    this.gap,
    this.count,
    this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2 * gap),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
        ),
        itemCount: count,
        itemBuilder: builder,
      ),
    );
  }
}

//==============================================================================
// 日期组件
//==============================================================================
