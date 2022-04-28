import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:useful_recorder/constants.dart';
import 'package:useful_recorder/models/record.dart';
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
                        final record = context.select<RecordsViewState, Record?>((state) => state.selectedRecord);
                        final mode = context.select<RecordsViewState, DateMode>((state) => state.selectedDateMode);

                        // 根据日期类型改变颜色
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
                          case DateMode.NORMAL:
                            break;
                        }

                        //  根据记录选择是否展示经期，状态和日记提示点
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

                        return AnimatedContainer(
                          duration: Duration(milliseconds: 60),
                          margin: EdgeInsets.all(4),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${day.day}"),
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
                            border: selectedDate.sameDay(day) ? Border.all() : null,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      }),
                      onTap: () {
                        state.selectDate(day);
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

  final _repository = RecordRepository();

  CalendarMode _mode = CalendarMode.DATE;
  DateTime selectedDate = DateTime.now();
  Record? selectedRecord;
  DateMode selectedDateMode = DateMode.NORMAL;

  CalendarMode get mode => _mode;

  set mode(CalendarMode mode) {
    _mode = mode;
    notifyListeners();
  }

  /// 查询选中的记录是异步操作，而设置选中日期是同步操作，因此
  /// 需要分开触发重建操作
  selectDate(DateTime date) async {
    this.selectedDate = date;
    notifyListeners();

    // TODO 需要测试一下，在一个上下文中 select 多个值会不会重复 build
    this.selectedRecord = await _repository.findByDate(date);
    this.selectedDateMode = await calcDateMode(date);
    notifyListeners();
  }

  /// _ o _
  /// { o _
  /// } o _
  /// _ o {
  /// } o {
  /// { o }
  Future<DateMode> calcDateMode(DateTime date) async {
    // 查询之后最近一次经期
    final next = await _repository.findFirstMensesAfterDate(date);

    // 如果之后是经期结束，则直接返回经期
    if (next?.type == RecordType.MENSES_END) {
      return DateMode.MENSES;
    }

    // 如果之后是经期开始。则根据日期推算
    if (next?.type == RecordType.MENSES_START) {
      final duration = next!.date!.difference(date).inDays;

      // 10 - 18 天内为排卵期，14 天为排卵日，其他为普通日期
      if (duration > 10 && duration < 18) {
        if (duration == 14) {
          return DateMode.SENSITIVE;
        }
        return DateMode.OVULATION;
      }
      return DateMode.NORMAL;
    }

    // 如果之后没有记录（否则），则查询之前最近一次经期
    final prev = await _repository.findLastMensesBeforeDat(date);

    // 如果之前是经期开始，并且当天不是未来日期，则直接返回经期
    if (prev?.type == RecordType.MENSES_START && !date.isFuture) {
      return DateMode.MENSES;
    }

    // 如果之前是经期结束，或者是经期开始且当天是未来日期（非空记录，即需要预测的日期），则开始预测
    if (prev != null && prev.type == RecordType.MENSES_END) {
      // 计算当日在周期中所属的天数
      final sp = await SharedPreferences.getInstance();
      final period = sp.getInt(PERIOD_LENGTH);
      final duration = (date.difference(prev.date!).inDays % period!) + 1;

      // 10 - 18 天内为排卵期，14 天为排卵日，其他为普通日期
      if (duration > 10 && duration < 18) {
        if (duration == 14) {
          return DateMode.SENSITIVE;
        }
        return DateMode.OVULATION;
      }
      return DateMode.NORMAL;
    }

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
