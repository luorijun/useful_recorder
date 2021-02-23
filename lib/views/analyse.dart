import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_recorder/models/period.dart';
import 'package:useful_recorder/models/record.dart';
import 'package:useful_recorder/models/record_repository.dart';
import 'package:useful_recorder/views/home.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';

class AnalyseView extends StatelessWidget {
  /// 分析元素：
  ///   - 周期数
  ///   - 异常周期数
  ///   - 周期详情列表
  /// 周期详情：
  ///   - 周期阶段图
  ///   - 开始日期
  ///   - 结束日期
  ///   - 天数
  ///
  /// 阶段图：
  ///   - 经期开始
  ///   - 经期结束
  ///   - 排卵期开始
  ///   - 排卵日
  ///   - 排卵期结束
  @override
  Widget build(BuildContext context) {
    Future.microtask(() => context.read<HomePageState>().title = "分析");

    return ChangeNotifierProvider(
      create: (context) => AnalyseViewState(),
      child: ListView(
        children: [
          ListTile(
            title: Text("统计"),
            dense: true,
            enabled: false,
          ),
          Row(children: [
            Expanded(
              flex: 1,
              child: Card(
                margin: EdgeInsets.fromLTRB(16, 8, 8, 8),
                child: Column(
                  children: [
                    SizedBox(height: 8),
                    Text(
                      "总周期数",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 8),
                    Selector<AnalyseViewState, int>(
                      selector: (context, state) => state.periodCount,
                      builder: (context, value, child) {
                        return Text(
                          "$value",
                          style: TextStyle(
                            fontSize: 36,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Card(
                margin: EdgeInsets.fromLTRB(8, 8, 16, 8),
                child: Column(
                  children: [
                    SizedBox(height: 8),
                    Text(
                      "异常周期",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 8),
                    Selector<AnalyseViewState, int>(
                      selector: (context, state) => state.abnormalCount,
                      builder: (context, value, child) {
                        return Text(
                          "$value",
                          style: TextStyle(
                            fontSize: 36,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ]),
          ListTile(
            enabled: false,
            dense: true,
            title: Text("周期"),
          ),
          Consumer<AnalyseViewState>(
            builder: (context, state, child) {
              return Column(
                children: state.periods.map((period) {
                  return Column(children: [
                    ListTile(
                      title: Text("${period.firstDay.toDateString()} - ${period.mensesLength} 天"),
                      trailing: Chip(label: Text("异常")),
                    ),
                  ]);
                }).toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AnalyseViewState extends ChangeNotifier {
  bool loading;

  List<Period> periods;
  List<Period> abnormalPeriods;

  int get periodCount => periods.length;

  int get abnormalCount => abnormalPeriods.length;

  AnalyseViewState() {
    loading = true;
    periods = [];
    abnormalPeriods = [];

    _analysePeriod();
  }

  _analysePeriod() async {
    final records = await RecordRepository().findAllAsc();

    Record prev;
    Period period;
    for (var record in records) {
      if (record.type == Type.Menses) {
        final diff = record.date.difference(prev?.date ?? record.date).inDays;
        if (diff != 1) {
          period?.lastDay = record.date.subtract(Duration(days: 1));
          if (period?.abnormal ?? false) {
            abnormalPeriods.add(period);
          }
          periods.add(period = Period());
        }
        period.mensesLength++;
      }
      period?.add(record);
      if (record.type == Type.Menses) prev = record;
    }
    loading = false;
    notifyListeners();
  }
}
