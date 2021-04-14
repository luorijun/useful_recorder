import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:useful_recorder/models/period.dart';
import 'package:useful_recorder/models/record.dart';
import 'package:useful_recorder/models/record_repository.dart';
import 'package:useful_recorder/views/home.dart';
import 'package:useful_recorder/widgets/headers.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';
import 'package:useful_recorder/widgets/more_list_tile.dart';

// TODO: 展示经期每日流量与痛感（可选：可编辑）(目前打开卡片无法加载数据)
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
                      Text("${state.periods.length}", style: normalContentStyle()),
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
                    Text("${state.abnormals.length}", style: exceptionContentStyle()),
                  ]),
                ),
              ),
            ],
          ),
          SectionHeader("时间轴"),
          if (state.periods.length > 0)
            ...state.periods.reversed.map((period) {
              return Container(
                margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Color(0x11000000), blurRadius: 4),
                  ],
                ),
                child: ExpansionTile(
                  title: Text(
                    "开始于 ${period.mensesStartDate.format('-')}",
                    style: durationTextStyle(),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text("一共 ${period.periodLength} 天，经期持续了 ${period.mensesLength} 天"),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text("进行中"),
                            backgroundColor: Colors.blue.shade100,
                          ),
                          Chip(
                            label: Text("经期异常"),
                            backgroundColor: Colors.red.shade100,
                          ),
                          Chip(
                            label: Text("周期异常"),
                            backgroundColor: Colors.red.shade100,
                          ),
                        ],
                      ),
                    ],
                  ),
                  backgroundColor: Colors.grey.shade50,
                  children: List.generate(period.mensesLength, (index) {
                    var menses = context.select<AnalysisViewState, Map<Period, Map<int, Record>>>(
                      (state) => state.menses,
                    );

                    return menses.containsKey(period)
                        ? RatingListTile(
                            title: Text("${period.mensesStartDate.format('-')}"),
                            icon: FontAwesomeIcons.bolt,
                            count: 5,
                            selected: menses[period][(period.mensesStartDate + Duration(days: index)).daySign].pain,
                            dense: true,
                            color: Colors.yellow,
                          )
                        : RatingListTile(
                            title: Text("时间"),
                            icon: FontAwesomeIcons.bolt,
                            count: 5,
                            selected: 5,
                            dense: true,
                          );
                  }),
                  onExpansionChanged: (expand) {
                    if (expand) state.loadMenses(period);
                  },
                ),
              );
            }),
          if (state.periods.length == 0)
            ListTile(
              title: Text("目前还没有记录哦"),
            ),
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
  bool mensesLoading;

  List<Period> periods;
  List<Period> abnormals;

  Map<Period, Map<int, Record>> menses;

  AnalysisViewState() {
    loading = true;
    mensesLoading = false;
    periods = [];
    abnormals = [];
    menses = {};
    initData();
  }

  initData() async {
    final list = await RecordRepository().findAllAsc();

    for (var record in list) {
      if (record.type == Type.MensesStart) {
        if (periods.length > 0) {
          var prev = periods.last;
          prev.finish(record.date - Duration(days: 1));
          if (prev.abnormal) abnormals.add(prev);
        }
        periods.add(Period()..add(record));
      } else {
        periods.last.add(record);
      }
    }

    loading = false;
    notifyListeners();
  }

  loadMenses(Period period) async {
    final result = await period.menses;
    menses[period] = Map<int, Record>.fromIterable(
      result,
      key: (record) => record.date.daySign,
      value: (record) => record,
    );
    notifyListeners();
  }
}
