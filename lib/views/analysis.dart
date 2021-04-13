import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:useful_recorder/models/period.dart';
import 'package:useful_recorder/models/record.dart';
import 'package:useful_recorder/models/record_repository.dart';
import 'package:useful_recorder/views/home.dart';
import 'package:useful_recorder/widgets/headers.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';

// TODO: 展示经期每日流量与痛感（可选：可编辑）
class AnalysisView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      return context.read<HomePageState>().title = "分析";
    });

    return ChangeNotifierProvider(
      create: (context) => AnalysisViewState(),
      builder: (context, child) {
        var state = context.watch<AnalysisViewState>();

        return ListView(children: [
          SectionHeader("统计"),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: InkWell(
                    child: Column(children: [
                      Text("总周期", style: normalTitleStyle()),
                      SizedBox(height: 8),
                      Text("5", style: normalContentStyle()),
                    ]),
                    onTap: () {},
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 76,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: Container(
                  child: Column(children: [
                    Text("异常周期", style: exceptionTitleStyle()),
                    SizedBox(height: 8),
                    Text("1", style: exceptionContentStyle()),
                  ]),
                ),
              ),
            ],
          ),
          SectionHeader("时间轴"),
          ...state.periods.reversed.map((period) {
            var records = period.records;

            return Card(
              margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ExpansionTile(
                title: Text(
                  "开始于 ${records.first.date.toDateString()}",
                  style: durationTextStyle(),
                ),
                subtitle: Text("一共 ${period.period} 天，经期持续了 ${period.menses} 天"),
              ),
            );
          }),
        ]);
      },
    );
  }

  normalTitleStyle() {
    return TextStyle(
      fontSize: 18,
    );
  }

  normalContentStyle() {
    return TextStyle(
      fontSize: 36,
    );
  }

  exceptionTitleStyle() {
    return TextStyle(
      fontSize: 18,
      color: Colors.red.shade800,
    );
  }

  exceptionContentStyle() {
    return TextStyle(
      fontSize: 36,
      color: Colors.red.shade800,
    );
  }

  durationTextStyle() {
    return TextStyle(
      fontSize: 12,
      color: Colors.grey.shade600,
    );
  }

  lengthTextStyle() {
    return TextStyle(
      fontSize: 16,
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
    initData();
  }

  initData() async {
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
