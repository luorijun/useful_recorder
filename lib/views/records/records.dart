import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';
import 'package:useful_recorder/views/records/calendar.dart';
import 'package:useful_recorder/views/records/inspector.dart';

class RecordsView extends StatelessWidget {
  const RecordsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final top = MediaQuery.of(context).padding.top;

    return ChangeNotifierProvider<RecordsViewState>(
      create: (_) => RecordsViewState(),
      child: Column(children: [
        // 标题栏
        Container(
          height: top + 56,
          color: theme.primaryColor,
        ),

        // 页面正文
        Expanded(
          child: Column(children: [
            // 日历
            SingleChildScrollView(
              child: Calendar(
                dateBuilder: (context, day, month) {
                  if (!day.sameMonth(month)) {
                    return Container();
                  }

                  return Builder(builder: (context) {
                    final state = context.read<RecordsViewState>();
                    return GestureDetector(
                      child: Builder(builder: (context) {
                        final selectedDate = context.select<RecordsViewState, DateTime>((state) => state.selectedDate);
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 60),
                          margin: EdgeInsets.all(4),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${day.day}",
                              ),
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
                            border: selectedDate.sameDay(day) ? Border.all() : null,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      }),
                      onTap: () {
                        state.selectedDate = day;
                      },
                    );
                  });
                },
              ),
            ),

            // 数据检视
            Flexible(child: Inspector()),
          ]),
        ),
      ]),
    );
  }
}

class RecordsViewState extends ChangeNotifier {
  RecordsViewState();

  CalendarMode _mode = CalendarMode.DATE;
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  set selectedDate(DateTime date) {
    this._selectedDate = date;
    notifyListeners();
  }

  CalendarMode get mode => _mode;

  set mode(CalendarMode mode) {
    _mode = mode;
    notifyListeners();
  }

  ///
  /// _ o _
  /// { o _
  /// } o _
  /// _ o {
  /// } o {
  /// { o }
  DateMode getDateMode(DateTime date) {
    // 查询之后最近一次经期

    // 如果之后是经期结束，则直接返回经期

    // 如果之后是经期开始。则根据日期推算当前是否为排卵期

    // 如果之后没有记录（否则），则查询之前最近一次经期

    // 如果之前是经期开始，并且当天不是未来日期，则直接返回经期

    // 如果之前是经期结束，或者当天是未来日期（否则），则开始预测

    // 计算当日在周期中所属的天数

    // 如果是排卵日，则返回排卵日

    // 如果是排卵期，则返回排卵期

    // 如果是经期，则返回经期

    // 其他情况（默认）返回正常日期

    return DateMode.NORMAL;
  }
}

enum CalendarMode {
  YEAR,
  MONTH,
  DATE,
}

enum DateMode {
  MENSES,
  OVULATION,
  SENSITIVE,
  NORMAL,
}
