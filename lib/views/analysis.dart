import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:useful_recorder/models/period.dart';
import 'package:useful_recorder/models/record.dart';
import 'package:useful_recorder/models/record_repository.dart';
import 'package:useful_recorder/views/home.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';

class AnalysisView extends StatelessWidget {
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
      create: (context) => AnalysisViewState(),
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
                    Selector<AnalysisViewState, int>(
                      selector: (context, state) => state.periods.length,
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
                    Selector<AnalysisViewState, int>(
                      selector: (context, state) => state.abnormal.length,
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
            trailing: Consumer<AnalysisViewState>(
              builder: (context, state, child) {
                return TextButton(
                  child: Text("打印"),
                  onPressed: () {
                    for (var period in state.periods) {
                      log("$period");
                    }
                  },
                );
              },
            ),
          ),
          Consumer<AnalysisViewState>(
            builder: (context, state, child) {
              return Column(
                children: state.periods.map((period) {
                  return Column(children: [
                    ListTile(
                      title: Text("${period.records.first.date.toDateString()}"
                          " - ${period.menses} 天"
                          " - ${period.period} 天"),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          if (period.processing)
                            Chip(
                              label: Text("进行中"),
                              backgroundColor: Colors.blue.shade200,
                            ),
                          if (period.abnormal)
                            Chip(
                              label: Text("异常"),
                              backgroundColor: Colors.red.shade100,
                            ),
                        ],
                      ),
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

class AnalysisViewState extends ChangeNotifier {
  bool loading;
  List<Period> periods;
  List<Period> abnormal;

  AnalysisViewState() {
    loading = true;
    periods = [];
    abnormal = [];
    _analysePeriod();
  }

  _analysePeriod() async {
    final list = await RecordRepository().findAllAsc();

    var period;
    for (var record in list) {
      if (!record.isMenses) continue;

      if (record.type == Type.MensesStart) {
        if (period != null) period.end(record.date);
        period = Period();
        period.add(record);
      } else {
        period.add(record);
        if (record.type == Type.MensesEnd) {
          periods.add(period);
        }
      }
    }

    if (period.records.last.type != Type.MensesEnd) {
      periods.add(period);
    }
    period.end(DateTime.now() + 1.day);
    abnormal = periods.where((item) => item.abnormal).toList(growable: false);

    loading = false;
    notifyListeners();
  }
}
