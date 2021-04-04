import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:useful_recorder/constants.dart';

import 'package:useful_recorder/themes.dart';
import 'package:useful_recorder/models/record_repository.dart';
import 'package:useful_recorder/views/home.dart';
import 'package:useful_recorder/widgets/calendar.dart';
import 'package:useful_recorder/widgets/more_list_tile.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';
import 'package:useful_recorder/models/record.dart';

// TODO: 将固定时长检查改为按配置时长
// TODO: 检查优化组件结构，保证重建效率

class RecordView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final init = DateTime.now();
    final start = DateTime(1970, 1);

    Future.microtask(() {
      return context.read<HomePageState>().title = "${init.year} 年 ${init.month} 月";
    });

    return ChangeNotifierProvider(
      create: (context) => RecordViewState(init),
      child: ListView(children: [
        Consumer<RecordViewState>(builder: (context, state, child) {
          return MonthView(
            initDate: init,
            startDate: start,
            dateBuilder: (date, month) {
              final now = state.getRecord(date);

              Color background;

              switch (now.type) {
                case Type.MensesStart:
                case Type.Menses:
                case Type.MensesEnd:
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
                  onTap: () => state.select(date),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(2.0),
                      border: date.sameDay(state.selected.date) ? Border.all() : null,
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
              final record = state.getRecord(date);
              context.read<HomePageState>().title = "${date.year} 年 ${date.month} 月"
                  "，${record.type}";
              state.select(date);
            },
          );
        }),
        Consumer<RecordViewState>(builder: (context, state, child) {
          return ListTile(
            title: Text("记录"),
            dense: true,
            enabled: false,
            trailing: TextButton(
              child: Text("打印"),
              onPressed: () async {
                final dbList = await RecordRepository().findAllAsc();
                log("=== database : ${dbList.length} ===");
                for (final value in dbList) {
                  log("${value.date.toDateString()} : ${value.type}");
                }

                final memoList = state._records;
                log("=== memory : ${memoList.length} ===");
                memoList.forEach((key, value) {
                  // if (value.isMenses)
                  log("${value.date.toDateString()} : ${value.type}");
                });
              },
            ),
          );
        }),
        Consumer<RecordViewState>(builder: (context, state, child) {
          final selected = state.selected;

          return selected.date.isFuture
              ? ListTile(
                  title: Text("未来的日期无法编辑"),
                  enabled: false,
                )
              : Column(children: [
                  // ====================
                  // == 经期状态切换栏
                  // == TODO: 统一操作检查逻辑，删除 isXXX 检查方式
                  // ====================
                  SwitchListTile(
                    title: Builder(builder: (context) {
                      switch (operation(state)) {
                        case MensesOperation.Merge:
                          return Text("经期 - 合并");
                        case MensesOperation.Add:
                          return Text("经期 - 新增");
                        case MensesOperation.Append:
                          return Text("经期 - 追加");
                        case MensesOperation.Advance:
                          return Text("经期 - 提前");
                        case MensesOperation.Shrink:
                          return Text("经期 - 缩减");
                        case MensesOperation.Remove:
                          return Text("经期 - 删除");
                        default:
                          return Text("经期 - 处理异常");
                      }
                    }),
                    value: selected.isMenses,
                    onChanged: (value) {
                      if (!selected.isMenses) {
                        if (isMerge(state)) {
                          state.mergeMenses();
                        } else if (isAdd(state)) {
                          state.addMenses();
                        } else if (isAppend(state)) {
                          state.appendMenses();
                        } else if (isAdvance(state)) {
                          state.advanceMenses();
                        }
                      } else {
                        if (selected.type == Type.MensesStart) {
                          state.removeMenses();
                        } else {
                          state.shrinkMenses();
                        }
                      }
                    },
                  ),
                  if (selected.isMenses)
                    RatingListTile(
                      title: Text("痛感"),
                      icon: FontAwesomeIcons.bolt,
                      count: 5,
                      selected: selected.pain,
                      color: Colors.yellow,
                      onRating: (value) {
                        context.read<RecordViewState>().setPain(value);
                      },
                    ),
                  if (selected.isMenses)
                    RatingListTile(
                      title: Text("流量"),
                      icon: FontAwesomeIcons.tint,
                      count: 5,
                      selected: selected.flow,
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
                    selected: selected.mood,
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

  MensesOperation operation(RecordViewState state) {
    if (state.selected.isMenses && state.selected.type == Type.MensesStart) {
      return MensesOperation.Remove;
    } else if (state.selected.isMenses) {
      return MensesOperation.Shrink;
    } else if (state.prev == null && state.next == null) {
      return MensesOperation.Add;
    } else if (state.prev == null) {
      return MensesOperation.Advance;
    } else if (state.next == null) {
      return MensesOperation.Append;
    } else {
      return MensesOperation.Merge;
    }
  }
}

bool isMerge(RecordViewState state) => state.prev != null && state.next != null;

bool isAdd(RecordViewState state) => state.prev == null && state.next == null;

bool isAppend(RecordViewState state) => state.prev != null && state.next == null;

bool isAdvance(RecordViewState state) => state.prev == null && state.next != null;

enum MensesOperation { Merge, Add, Append, Advance, Shrink, Remove }

/// 日历记录页
///
/// 数据：
///   - 记录表
///
/// 属性：
///   - 当日（选择日）记录
///
/// 函数：
///   - 选择日期：O(1) 通过记录表查询
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
  Map<DateTime, Record> _records;

  bool loading;
  Record selected;
  Record prev;
  Record next;

  /// 初始化数据
  RecordViewState(DateTime initDate) {
    _records = {};
    selected = Record(initDate);
    _refreshData();
  }

  Record getRecord(DateTime date) => _records[date] ?? Record(date);

  Record getRealRecord(DateTime date) => _records.putIfAbsent(date, () => Record(date));

  /// 获取当日记录
  void select(DateTime date) {
    selected = getRecord(date);

    prev = null;
    for (int i = 1; i <= 5; i++) {
      var prevDate = selected.date - i.day;
      final prevRecord = getRecord(prevDate);

      if (prevRecord.type == Type.MensesEnd) {
        prev = prevRecord;
        break;
      }
    }

    next = null;
    for (int i = 1; i <= 10; i++) {
      var nextDate = selected.date + i.day;
      final nextRecord = getRecord(nextDate);

      if (nextRecord.type == Type.MensesStart) {
        next = nextRecord;
        break;
      }
    }

    notifyListeners();
  }

  /// 合并周期
  Future<void> mergeMenses() async {
    if (loading) return;
    assert(!selected.isMenses);
    assert(prev != null && next != null);

    prev.type = Type.Normal;
    next.type = Type.Normal;

    await _saveRecord(prev);
    await _saveRecord(next);
    _refreshData();
  }

  /// 提前周期
  void advanceMenses() async {
    if (loading) return;
    assert(!selected.isMenses);
    assert(prev == null && next != null);

    next.type = Type.Normal;
    selected.type = Type.MensesStart;

    await _saveRecord(next);
    await _saveRecord(selected);
    _refreshData();
  }

  /// 追加周期
  void appendMenses() async {
    if (loading) return;
    assert(!selected.isMenses);
    assert(prev != null && next == null);

    prev.type = Type.Normal;
    selected.type = Type.MensesEnd;

    await _saveRecord(prev);
    await _saveRecord(selected);
    _refreshData();
  }

  /// 新增周期
  void addMenses() async {
    if (loading) return;
    assert(!selected.isMenses);
    assert(prev == null && next == null);

    selected.type = Type.MensesStart;
    await _saveRecord(selected);

    final sp = await SharedPreferences.getInstance();
    final endDate = selected.date + sp.getInt(MENSES_LENGTH).day - 1.day;
    if (!endDate.isFuture) {
      final endRecord = getRecord(endDate);
      endRecord.type = Type.MensesEnd;
      await _saveRecord(endRecord);
    }

    _refreshData();
  }

  /// 缩短周期
  void shrinkMenses() async {
    if (loading) return;
    assert(selected.type == Type.Menses || selected.type == Type.MensesEnd);

    final endDate = selected.date - 1.day;
    final newEnd = getRecord(endDate);
    assert(newEnd.type != Type.MensesStart);

    newEnd.type = Type.MensesEnd;

    var oldEnd = selected;
    while (!oldEnd.date.isFuture && oldEnd.type != Type.MensesEnd) {
      final nextDate = oldEnd.date + 1.day;
      oldEnd = _records.putIfAbsent(nextDate, () => Record(nextDate));
    }
    oldEnd
      ..type = Type.Normal
      ..pain = 0
      ..flow = 0;

    await _saveRecord(newEnd);
    if (!oldEnd.date.isFuture) {
      await _saveRecord(oldEnd);
    }
    _refreshData();
  }

  /// 删除周期
  void removeMenses() async {
    if (loading) return;
    assert(selected.type == Type.MensesStart);

    selected
      ..type = Type.Normal
      ..pain = 0
      ..flow = 0;

    var testEnd = selected;
    while (testEnd.type != Type.MensesEnd && !testEnd.date.isFuture) {
      final nextDate = testEnd.date + 1.day;
      testEnd = _records.putIfAbsent(nextDate, () => Record(nextDate));
    }

    testEnd
      ..type = Type.Normal
      ..pain = 0
      ..flow = 0;

    await _saveRecord(selected);
    if (!testEnd.date.isFuture) {
      await _saveRecord(testEnd);
    }
    _refreshData();
  }

  // 设置痛感
  void setPain(int value) async {
    if (loading) return;

    selected.pain = value;

    await _saveRecord(selected);
    _refreshData();
  }

  // 设置流量
  void setFlow(int value) async {
    if (loading) return;

    selected.flow = value;

    await _saveRecord(selected);
    _refreshData();
  }

  // 设置心情
  void setMood(int value) async {
    if (loading) return;

    selected.mood = value;

    await _saveRecord(selected);
    _refreshData();
  }

  /// 刷新数据
  ///   - 刷新纪录列表
  ///   - 刷新选择项
  Future<void> _refreshData() async {
    loading = true;
    notifyListeners();

    final list = await RecordRepository().findAllAsc();
    _records = Map.fromIterable(
      list,
      key: (item) => item.date,
      value: (item) => item,
    );

    var length = -1;
    var first;
    if (list.isNotEmpty) {
      first = list.first;
      length = DateTimeExtension.diff(first.date, DateTime.now());
    }

    var prevType = Type.Normal;
    for (var i = 0; i <= length; i++) {
      // TODO: 傻逼问题没找到，加号重载不起作用
      final date = first.date.add(Duration(days: i));
      final record = getRealRecord(date);

      if (record.type == Type.MensesStart) {
        for (int i = 1; i <= 18; i++) {
          final testDate = record.date - i.day;
          final testRecord = getRealRecord(testDate);

          if (testRecord.type == Type.MensesEnd) break;

          if (i == 14) {
            testRecord.type = Type.OvulationDay;
          } else if (i > 9) {
            testRecord.type = Type.Ovulation;
          }
        }
      } else if (record.type != Type.MensesEnd && prevType == Type.MensesStart) {
        record.type = Type.Menses;
      }

      if (record.type == Type.MensesStart || record.type == Type.MensesEnd) {
        prevType = record.type;
      }
    }

    loading = false;
    notifyListeners();
  }

  /// 保存记录到数据库
  Future<void> _saveRecord(Record record) async {
    return RecordRepository().save(record);
  }
}
