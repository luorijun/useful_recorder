import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:useful_recorder/themes.dart';
import 'package:useful_recorder/models/record_repository.dart';
import 'package:useful_recorder/views/home.dart';
import 'package:useful_recorder/widgets/calendar.dart';
import 'package:useful_recorder/widgets/rating.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';
import 'package:useful_recorder/models/record.dart';

class RecordView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final init = DateTime.now();
    final start = DateTime(1970, 1);

    Future.microtask(() {
      return context.read<HomePageState>().title = "${init.year} 年 ${init.month} 月";
    });

    return ChangeNotifierProvider(
      create: (context) => RecordViewState(init, context),
      child: ListView(children: [
        Consumer<RecordViewState>(builder: (context, state, child) {
          final theme = Theme.of(context);
          return MonthView(
            initDate: init,
            startDate: start,
            dateBuilder: (date, month) {
              final now = state.records[date] ?? Record(date);

              Color background;

              switch (now.type) {
                case Type.Menses:
                  background = colors.menses.slight;
                  break;
                case Type.Ovulation:
                  background = colors.ovulation.slight;
                  break;
                case Type.OvulationDay:
                  background = colors.ovulation.weak;
                  break;
                case Type.Normal:
                  break;
              }

              Color color;
              if (date.isAfter(DateTime.now())) {
                color = Colors.black54;
              }

              Widget day;
              if (date.sameMonth(month)) {
                day = InkWell(
                  borderRadius: BorderRadius.circular(2.0),
                  onTap: () => state.selected = date,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(2.0),
                      border: date.sameDay(state.selected) ? Border.all() : null,
                    ),
                    child: Text(
                      "${date.day}",
                      style: TextStyle(
                        color: color,
                      ),
                    ),
                  ),
                );
              }

              return day ?? Container();
            },
            onMonthChanged: (date) => context.read<HomePageState>().title = "${date.year} 年 ${date.month} 月",
            onDateSelected: (date, month) {
              final record = state.records[date] ?? Record(date);
              context.read<HomePageState>().title = "${date.year} 年 ${date.month} 月"
                  "，${record.type}";
              state.selected = date;
            },
          );
        }),
        ListTile(
          title: Text("记录"),
          dense: true,
          enabled: false,
          trailing: TextButton(
            child: Text("打印"),
            onPressed: () async {
              final list = await RecordRepository().findAllDesc();
              for (var value in list) {
                log("$value");
              }
            },
          ),
        ),
        Consumer<RecordViewState>(builder: (context, state, child) {
          final record = state.record ?? Record(state.selected);

          return state.selected.isAfter(DateTime.now())
              ? ListTile(
                  title: Text("未来的日期无法编辑"),
                  enabled: false,
                )
              : Column(children: [
                  SwitchListTile(
                    title: Text("经期"),
                    value: record.type == Type.Menses,
                    onChanged: (value) {
                      context.read<RecordViewState>().setMenses(value);
                    },
                  ),
                  if (record.type == Type.Menses)
                    RatingListTile(
                      title: Text("痛感"),
                      icon: FontAwesomeIcons.bolt,
                      count: 5,
                      selected: record.pain,
                      color: Colors.yellow,
                      onRating: (value) {
                        context.read<RecordViewState>().setPain(value);
                      },
                    ),
                  if (record.type == Type.Menses)
                    RatingListTile(
                      title: Text("流量"),
                      icon: FontAwesomeIcons.tint,
                      count: 5,
                      selected: record.flow,
                      color: Colors.red,
                      onRating: (value) {
                        context.read<RecordViewState>().setFlow(value);
                      },
                    ),
                  VoteListTile(
                    title: Text("心情"),
                    icons: [
                      FontAwesomeIcons.laugh,
                      FontAwesomeIcons.tired,
                      FontAwesomeIcons.meh,
                      FontAwesomeIcons.angry,
                      FontAwesomeIcons.dizzy,
                    ],
                    selected: record.mood,
                    color: Colors.amber,
                    onVote: (value) {
                      context.read<RecordViewState>().setMood(value);
                    },
                  ),
                ]);
        }),
      ]),
    );
  }
}

/// 日历记录页
///
/// 数据：
///   - 记录表
///
/// 属性：
///   - 选择日期的记录
///
/// 函数：
///   - 查询当日记录：O(1) 通过记录表查询
///
///   TODO: 经期操作后，周期类型不用全局刷新，只需要刷新受影响的经期和它的排卵期
///
///   - 合并经期：O(m) 将前周期的结束日期与后周期的开始日期的周期类型都置为空
///   - 新增经期：O(m) 将选择日期的周期类型置为开始，若第五天不为未来日期，则将其置为结束
///   - 追加经期：O(m) 将前周期的结束日期设置为选择的日期
///   - 提前经期：O(m) 将后周期的开始日期设置为选择的日期
///
///   - 收缩经期：O(m)
///   - 删除经期：O(m)
///
///   - 设置痛感：O(1)
///   - 设置流量：O(1)
///   - 设置心情：O(1)
///
/// **周期类型刷新：**
///
/// 当操作完日期的周期类型后，需要刷新数据，以计算其他日期的周期类型
///
/// **更改周期记录：**
///
/// 在更改周期前必然先要查找前后周期端点，如果能找到，前周期必然是结束日期，后周期必
/// 然是开始日期。合并操作将置空这两个字段，追加操作将设置结束日期为选择日期，提前操
/// 作将设置开始日期为选择日期
///
class RecordViewState extends ChangeNotifier {
  bool loading;
  Map<DateTime, Record> records;

  /// 选择日期时判断操周期作类型
  ///
  /// 若当日为经期：
  ///   - 若当日为中间日期，周期操作类型为缩短
  ///   - 若当日为开始日期，周期操作类型为删除
  ///   - 若当日为结束日期，周期操作禁用
  ///
  /// 若当日为非经期：
  ///   - 前周期五天之内，后周期十天之内，周期操作类型为合并
  ///   - 前周期五天之外，后周期十天之外，周期操作类型为新增
  ///   - 前周期五天之内，后周期十天之外，周期操作类型为追加
  ///   - 前周期五天之外，后周期十天之内，周期操作类型为提前
  // region property: selected
  DateTime _selected;

  DateTime get selected => _selected;

  set selected(DateTime value) {
    _selected = DateTime(value.year, value.month, value.day);
    notifyListeners();
  }
  // endregion

  // region legacy implementations
  Record get record => records[selected];

  set record(Record value) => records[selected] = value;

  void setMenses(bool value) {
    if (loading) return;
    value ? _startRecord() : _removeRecord();
  }

  /// 开始记录的操作有四种类型：新增周期，延长周期，提前周期，合并周期
  ///
  /// TODO: 独立四种操作，当选择日期时进行操作类型判断，分别赋值。
  ///
  void _startRecord() {
    final list = <Record>[];

    // 当天为经期
    record = (record ?? Record(selected))..type = Type.Menses;
    list.add(record);

    // 如果前五天内有经期，则本次操作为追加操作
    bool append = false;
    for (var i = -5; i < 0; i++) {
      final now = selected.add(Duration(days: i));

      if (append) {
        records[now] = (records[now] ?? Record(now))..type = Type.Menses;
        list.add(records[now]);
      } else {
        if (records[now]?.type == Type.Menses) {
          append = true;
        }
      }
    }

    // 后四天也为经期
    bool insert = !append;
    for (var i = 4; i > 0; i--) {
      final now = selected.add(Duration(days: i));

      if (insert) {
        if (!now.isAfter(DateTime.now())) {
          records[now] = (records[now] ?? Record(now))..type = Type.Menses;
          list.add(records[now]);
        }
      } else {
        if (records[now]?.type == Type.Menses) {
          insert = true;
        }
      }
    }

    // 前五天内没经期，则为新的周期，并计算排卵期
    if (!append)
      for (var i = -1; i > -19; i--) {
        final now = selected.add(Duration(days: i));

        if (records[now]?.type == Type.Menses) break;

        if (i > -10) {
          records[now]?.type = Type.Normal;
        } else if (i == -14) {
          records[now] = (records[now] ?? Record(now))..type = Type.OvulationDay;
        } else {
          records[now] = (records[now] ?? Record(now))..type = Type.Ovulation;
        }

        if (records[now] != null) list.add(records[now]);
      }

    _saveAllToDatabase(list);
    notifyListeners();
  }

  void _removeRecord() {
    final list = <Record>[];

    // 删除从当天开始连续的经期，最终指向经期结束的后一天
    var next = selected;
    while (records[next]?.type == Type.Menses) {
      records[next]
        ..type = Type.Normal
        ..pain = 0
        ..flow = 0;
      list.add(records[next]);

      next = next.add(Duration(days: 1));
    }

    // 搜索经期后十八天内是否有下一个经期（此经期的排卵期会被覆盖）
    Record after;
    for (var i = 0; i < 18; i++) {
      final now = next.add(Duration(days: i));

      if (records[now] != null && records[now].type == Type.Menses) {
        after = records[now];
        break;
      }
    }

    // 如果有下一个经期，则恢复被覆盖的排卵期记录
    if (after != null)
      for (var i = -1; i > -19; i--) {
        final now = after.date.add(Duration(days: i));

        if (records[now]?.type == Type.Menses) break;

        if (i > -10) {
          records[now]?.type = Type.Normal;
          records[now]?.pain = 0;
          records[now]?.flow = 0;
        } else if (i == -14) {
          records[now] = (records[now] ?? Record(now))..type = Type.OvulationDay;
        } else {
          records[now] = (records[now] ?? Record(now))..type = Type.Ovulation;
        }

        if (records[now] != null) list.add(records[now]);
      }

    // 如果是整个经期被取消，则删除排卵期记录
    var prev = selected.subtract(Duration(days: 1));
    if (records[prev] == null || records[prev].type != Type.Menses)
      for (var i = -1; i > -19; i--) {
        final now = records[selected.add(Duration(days: i))];

        if (now != null && now.type == Type.Menses) break;

        if (i < -9) {
          now
            ..type = Type.Normal
            ..pain = 0
            ..flow = 0;
          list.add(now);
        }
      }

    _saveAllToDatabase(list);
    notifyListeners();
  }
  // endregion

  ///
  RecordViewState(this._selected, BuildContext context) {
    this.loading = false;
  }

  /// 获取当日记录
  void getRecord(DateTime date){

  }

  void setPain(int value) {
    if (loading) return;

    (record = record ?? Record(selected))..pain = record.pain == value ? 0 : value;
    _saveToDatabase(record);

    notifyListeners();
  }

  void setFlow(int value) {
    if (loading) return;

    (record = record ?? Record(selected))..flow = record.flow == value ? 0 : value;
    _saveToDatabase(record);

    notifyListeners();
  }

  void setMood(int value) {
    if (loading) return;

    (record = record ?? Record(selected))..mood = record.mood == value ? 0 : value;
    _saveToDatabase(record);

    notifyListeners();
  }

  _saveToDatabase(Record record) async {
    loading = true;

    await RecordRepository().save(record);

    loading = false;
    notifyListeners();
  }

  _saveAllToDatabase(Iterable<Record> records) async {
    loading = true;

    final list = <Future>[];
    records.forEach((record) {
      list.add(RecordRepository().save(record));
    });

    await Future.wait(list);
    loading = false;
    notifyListeners();
  }
}
