import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:useful_recorder/constants.dart';
import 'package:useful_recorder/models/record.dart';
import 'package:useful_recorder/styles.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';
import 'package:useful_recorder/utils/nullable.dart';
import 'package:useful_recorder/views/home.dart';
import 'package:useful_recorder/views/records/calendar.dart';
import 'package:useful_recorder/views/records/inspector.dart';

enum CalendarMode {
  ALL,
  YEAR,
  MONTH,
}

enum DateMode {
  MENSES,
  MENSES_FORECAST,
  OVULATION,
  OVULATION_FORECAST,
  SENSITIVE,
  SENSITIVE_FORECAST,
  NORMAL,
}

class DateInfo {
  DateInfo({
    required this.date,
    this.curr,
    this.prev,
    this.next,
    this.mode = DateMode.NORMAL,
  });

  DateTime date;
  Record? curr;
  Record? prev;
  Record? next;
  DateMode mode;

  @override
  String toString() {
    return 'DateInfo{date: $date, curr: $curr, prev: $prev, next: $next, mode: $mode}';
  }
}

class RecordsViewState extends ChangeNotifier {
  final _repository = RecordRepository();

  RecordsViewState() {
    log('初始化 records 页面状态');
    this.calendarMode = CalendarMode.MONTH;
    this.month = DateTime.now().toMonth;
    this.monthData = {};
    this.selected = DateInfo(date: DateTime.now().toDate);

    this.updateMonthData();
  }

  // ==============================
  // region 切换视图
  // ==============================

  late CalendarMode calendarMode;

  changeCalendar(CalendarMode calendarMode) {
    log('切换视图：${this.calendarMode.name} => ${calendarMode.name}');
    this.calendarMode = calendarMode;
    notifyListeners();
  }

  // endregion

  // ==============================
  // region 按代查看
  // ==============================

  // endregion

  // ==============================
  // region 按年查看
  // ==============================

  // endregion

  // ==============================
  // region 按月查看
  // ==============================

  late DateTime month;
  late Map<DateTime, DateInfo> monthData;

  changeMonth(DateTime month) {
    log('切换月份：${this.month.year}-${this.month.month} => ${month.year}-${month.month}');
    this.month = month;
    updateMonthData();
  }

  updateMonthData() async {
    log('查询 ${month.year}-${month.month} 的记录');

    final list = await _repository.findAllInMonth(month);
    final map = Map.fromIterable(
      list,
      key: (list) => list.date,
      value: (list) => list,
    );

    final dateList = List.generate(
      month.daysInMonth,
      (index) => DateTime(month.year, month.month, index + 1),
    );

    monthData = {};
    for (final date in dateList) {
      final prev = await _repository.findLastMensesBeforeDate(date);
      final next = await _repository.findFirstMensesAfterDate(date);

      monthData[date] = DateInfo(
        date: date,
        curr: map[date],
        prev: prev,
        next: next,
        mode: await _calcDateMode(date, prev, next),
      );
    }
    notifyListeners();
  }

  Future<DateMode> _calcDateMode(DateTime date, Record? prev, Record? next) async {
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

    // 如果之后没有记录（否则），则根据之前的日期推算
    // 如果之前是经期开始，并且当天不是未来日期，则直接返回经期
    if (prev?.type == RecordType.MENSES_START && !date.isFuture) {
      return DateMode.MENSES;
    }

    // 如果之前是经期结束，或者是经期开始且当天是未来日期（非空记录，即需要预测的日期），则开始预测
    // 确定未来第一个周期的开始日期：
    //   - 如果之前是经期结束，则最后一次开始经期的日期为第一天
    //   - 如果之前是经期开始，则此经期开始为第一天
    if (prev != null && prev.type != DateMode.NORMAL) {
      // 计算当日在周期中所属的天数
      final sp = await SharedPreferences.getInstance();
      final menses = sp.getInt(MENSES_LENGTH) ?? DEFAULT_MENSES_LENGTH;
      final period = sp.getInt(PERIOD_LENGTH) ?? DEFAULT_PERIOD_LENGTH;

      // 确定预测周期开始计算日期
      var offsetStart;
      if (prev.type == RecordType.MENSES_START) {
        offsetStart = prev;
      } else {
        offsetStart = await _repository.findLastMensesStart();
      }

      final offset = (date.difference(offsetStart.date!).inDays % period) + 1;

      // 0 - 5 天内为经期
      if (offset <= menses) {
        return DateMode.MENSES_FORECAST;
      }

      // 10 - 18 天内为排卵期，14 天为排卵日
      if (offset > 10 && offset < 18) {
        if (offset == 14) {
          return DateMode.SENSITIVE_FORECAST;
        }
        return DateMode.OVULATION_FORECAST;
      }

      // 其他为普通日期
      return DateMode.NORMAL;
    }

    // 其他情况（默认）返回正常日期
    return DateMode.NORMAL;
  }

  // endregion

  // ==============================
  // region 选择日期
  // ==============================

  late DateInfo selected;

  /// 选中日期，传入构建日历时计算出的值
  selectDate(DateTime date) async {
    log('选中日期：${date.year}-${date.month}-${date.day}');
    this.selected = except(this.monthData[date], "选中的日期信息未找到");
    notifyListeners();
  }

  // endregion

  // ==============================
  // region 修改记录时间
  // ==============================

  /// 开始记录
  void start(DateTime date, Record? selected) async {
    if (selected == null) {
      final selected = Record(date, type: RecordType.MENSES_START);
      await _repository.add(selected.toMap());
    } else {
      selected.type = RecordType.MENSES_START;
      await _repository.updateById(selected.toMap());
    }

    await updateMonthData();
    selectDate(except(this.selected).date);
  }

  /// 添加记录
  void add(DateTime date, Record? selected) async {
    // 在当天添加开始记录
    if (selected == null) {
      final selected = Record(date, type: RecordType.MENSES_START);
      await _repository.add(selected.toMap());
    } else {
      selected.type = RecordType.MENSES_START;
      await _repository.updateById(selected.toMap());
    }

    // 在经期长度天数后添加结束记录
    final menses = (await SharedPreferences.getInstance()).getInt(MENSES_LENGTH) ?? DEFAULT_MENSES_LENGTH;
    final nextMenses = date + menses.days;

    final nextRecord = await _repository.findByDate(nextMenses);
    if (nextRecord == null) {
      final record = Record(nextMenses, type: RecordType.MENSES_END);
      await _repository.add(record.toMap());
    } else {
      nextRecord.type = RecordType.MENSES_END;
      await _repository.updateById(nextRecord.toMap());
    }
    await updateMonthData();
    selectDate(except(this.selected).date);
  }

  /// 合并记录
  void merge(Record prev, Record next) async {
    prev.type = RecordType.NORMAL;
    next.type = RecordType.NORMAL;
    await _repository.updateById(prev.toMap());
    await _repository.updateById(next.toMap());
    await updateMonthData();
    selectDate(except(this.selected).date);
  }

  /// 追加记录
  void append(DateTime date, Record prev) async {
    // 清除当日之前的结束记录
    prev.type = RecordType.NORMAL;
    await _repository.updateById(prev.toMap());

    // 在当天的后一天添加新的结束记录
    var curr = await _repository.findByDate(date.nextDay);
    if (curr == null) {
      curr = Record(date.nextDay, type: RecordType.MENSES_END);
      await _repository.add(curr.toMap());
    } else {
      curr.type = RecordType.MENSES_END;
      await _repository.updateById(curr.toMap());
    }

    await updateMonthData();
    selectDate(except(this.selected).date);
  }

  /// 提前记录
  void insert(DateTime date, Record? selected, Record next) async {
    // 清除当日之后的开始记录
    next.type = RecordType.NORMAL;
    await _repository.updateById(next.toMap());

    // 在当天添加新的开始记录
    if (selected == null) {
      final selected = Record(date, type: RecordType.MENSES_START);
      await _repository.add(selected.toMap());
    } else {
      selected.type = RecordType.MENSES_START;
      await _repository.updateById(selected.toMap());
    }
    await updateMonthData();
    selectDate(except(this.selected).date);
  }

  /// 结束记录
  void end(DateTime date, Record? selected) async {
    if (selected == null) {
      final selected = Record(date, type: RecordType.MENSES_END);
      await _repository.add(selected.toMap());
    } else {
      selected.type = RecordType.MENSES_END;
      await _repository.updateById(selected.toMap());
    }
    await updateMonthData();
    selectDate(except(this.selected).date);
  }

  /// 删除经期
  void remove(Record? selected, Record prev, Record? next) async {
    // 如果本经期有结束记录，则清除结束记录
    if (next != null) {
      next.type = RecordType.NORMAL;
      await _repository.updateById(next.toMap());
    }

    // 如果当天有记录并且是开始记录，则清除当天的开始记录
    if (selected != null && selected.type == RecordType.MENSES_START) {
      selected.type = RecordType.NORMAL;
      await _repository.updateById(selected.toMap());
    }

    // 否则清除当天之前最近的开始记录
    else {
      prev.type = RecordType.NORMAL;
      await _repository.updateById(prev.toMap());
    }

    await updateMonthData();
    selectDate(except(this.selected).date);
  }

  /// 从左边剪裁
  void clipLeft(DateTime date, Record? selected, Record prev) async {
    // 如果开始记录在当天，则操作没有意义，直接跳过
    if (selected?.type == RecordType.MENSES_START) {
      return;
    }

    // 否则，清除开始记录
    prev.type = RecordType.NORMAL;
    await _repository.updateById(prev.toMap());

    // 在当天添加新的开始记录
    if (selected == null) {
      final selected = Record(date, type: RecordType.MENSES_START);
      await _repository.add(selected.toMap());
    } else {
      selected.type = RecordType.MENSES_START;
      await _repository.updateById(selected.toMap());
    }

    await updateMonthData();
    selectDate(except(this.selected).date);
  }

  /// 从右边剪裁
  void clipRight(DateTime date, Record? next) async {
    // 如果结束记录在当天的下一天，则操作没有意义，直接跳过
    final nextDate = next?.date;
    if (nextDate != null && date.sameDay(nextDate)) {
      return;
    }

    // 如果有结束记录，删除结束记录
    if (next != null) {
      next.type = RecordType.NORMAL;
      await _repository.updateById(next.toMap());
    }

    // 在当天的后一天添加新的结束记录
    var curr = await _repository.findByDate(date.nextDay);
    if (curr == null) {
      curr = Record(date.nextDay, type: RecordType.MENSES_END);
      await _repository.add(curr.toMap());
    } else {
      curr.type = RecordType.MENSES_END;
      await _repository.updateById(curr.toMap());
    }

    await updateMonthData();
    selectDate(except(this.selected).date);
  }

  // endregion

  // ==============================
  // region 修改记录数据
  // ==============================

  // 更新痛感数据
  void updatePain(DateTime date, int level) async {
    final record = monthData[date]?.curr ?? Record(date);
    record.pain = level;
    await _repository.updateById(record.toMap());
    selectDate(date);
  }

  // 更新流量数据
  void updateFlow(DateTime date, int level) async {
    final record = monthData[date]?.curr ?? Record(date);
    record.flow = level;
    await _repository.updateById(record.toMap());
    notifyListeners();
  }

  // 更新心情数据
  void updateEmotion(DateTime date, RecordEmotion emotion) async {
    final record = monthData[date]?.curr ?? Record(date);
    record.emotion = emotion;
    await _repository.updateById(record.toMap());
    notifyListeners();
  }

  // 更新天气数据
  void updateWeather(DateTime date, RecordWeather weather) async {
    final record = monthData[date]?.curr ?? Record(date);
    record.weather = weather;
    await _repository.updateById(record.toMap());
    notifyListeners();
  }

// endregion
}

class RecordsView extends StatelessWidget {
  const RecordsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 注册页面状态
    final state = RecordsViewState();
    context.read<HomePageState>().states.putIfAbsent('recordsView', () => state);

    return ChangeNotifierProvider(
      create: (_) => state,
      child: Column(children: [
        // 标题栏
        RecordsAppBar(title: "记录"),

        // 页面正文
        Expanded(
          child: Column(children: [
            // 日历
            SingleChildScrollView(
              child: Calendar(),
            ),
            // 数据检视
            Flexible(child: Builder(builder: (context) {
              final selected = context.select<RecordsViewState, DateInfo>((state) => state.selected);

              if (selected.date.isFuture) {
                return Center(
                  child: Text(
                    "未来的日期不能编辑",
                    style: styles.text.normal.copyWith(
                      color: styles.color.surfaceBackgroundTextWeak,
                    ),
                  ),
                );
              } else {
                return Inspector();
              }
            })),
          ]),
        ),
      ]),
    );
  }
}

// ==============================
// 样式组件
// ==============================

class RecordsAppBar extends StatelessWidget {
  const RecordsAppBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = MediaQuery.of(context).padding.top;

    return Container(
      height: top + 56,
      color: theme.primaryColor,
      padding: EdgeInsets.only(left: 16),
      child: Column(
        children: [
          SizedBox(height: top),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              // todo 左半部分 - 当前年月
              // todo 右半部分 - 视图切换
              children: [
                Text(
                  title,
                  style: styles.text.title.copyWith(
                    color: styles.color.primaryBackgroundText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
