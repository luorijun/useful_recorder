import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:provider/provider.dart';
//
// import 'package:useful_recorder/models/period.dart';
// import 'package:useful_recorder/models/record.dart';
// import 'package:useful_recorder/repositories/record_repository.dart';
// import 'package:useful_recorder/views/home.dart';
// import 'package:useful_recorder/widgets/headers.dart';
// import 'package:useful_recorder/utils/datetime_extension.dart';
// import 'package:useful_recorder/widgets/more_list_tile.dart';
//
// class AnalysisView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     Future.microtask(() {
//       return context.read<HomePageState>().title = "分析";
//     });
//
//     return ChangeNotifierProvider(
//       create: (context) => AnalysisViewState(),
//       builder: (context, child) {
//         var state = context.watch<AnalysisViewState>();
//         var menses = context.select<AnalysisViewState, Map<Period, Map<int, Record>>>(
//           (state) => state.menses,
//         );
//
//         return ListView(children: [
//           SectionHeader("统计"),
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8),
//                   child: InkWell(
//                     child: Column(children: [
//                       Text("总周期", style: normalTitleStyle()),
//                       SizedBox(height: 8),
//                       Text("${state.periods.length}", style: normalContentStyle()),
//                     ]),
//                     onTap: () {},
//                   ),
//                 ),
//               ),
//               Container(
//                 width: 1,
//                 height: 76,
//                 color: Colors.grey.shade300,
//               ),
//               Expanded(
//                 child: Container(
//                   child: Column(children: [
//                     Text("异常周期", style: exceptionTitleStyle()),
//                     SizedBox(height: 8),
//                     Text("${state.abnormals.length}", style: exceptionContentStyle()),
//                   ]),
//                 ),
//               ),
//             ],
//           ),
//           SectionHeader("时间轴"),
//           if (state.periods.length > 0)
//             ...state.periods.reversed.map((period) {
//               return Container(
//                 margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(color: Color(0x11000000), blurRadius: 4),
//                   ],
//                 ),
//                 child: ExpansionTile(
//                   title: Text("开始于 ${period.mensesStartDate.format('-')}"),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 8),
//                       Text("一共 ${period.periodLength} 天，经期持续了 ${period.mensesLength} 天"),
//                       Wrap(
//                         spacing: 8,
//                         children: [
//                           if (period.processing)
//                             Chip(
//                               label: Text("进行中"),
//                               backgroundColor: Colors.blue.shade100,
//                             ),
//                           if (period.mensesAbnormal)
//                             Chip(
//                               label: Text("经期异常"),
//                               backgroundColor: Colors.red.shade100,
//                             ),
//                           if (period.periodAbnormal)
//                             Chip(
//                               label: Text("周期异常"),
//                               backgroundColor: Colors.red.shade100,
//                             ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   backgroundColor: Colors.grey.shade50,
//                   children: List.generate(period.mensesLength, (index) {
//                     if (menses.containsKey(period)) {
//                       var now = period.mensesStartDate + Duration(days: index);
//                       var record = menses[period][now.daySign] ?? Record(now, RecordType.MENSES);
//
//                       return Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         decoration: BoxDecoration(
//                             border: Border(top: BorderSide(color: Colors.grey.shade200))),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("第 ${index + 1} 天"),
//                             Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: List.generate(5, (index) {
//                                     return Padding(
//                                       padding: const EdgeInsets.all(6),
//                                       child: Icon(
//                                         FontAwesomeIcons.bolt,
//                                         color: index < record.pain ? Colors.yellow : Colors.grey,
//                                       ),
//                                     );
//                                   }),
//                                 ),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: List.generate(5, (index) {
//                                     return Padding(
//                                       padding: const EdgeInsets.all(6),
//                                       child: Icon(
//                                         FontAwesomeIcons.tint,
//                                         color: index < record.flow ? Colors.red : Colors.grey,
//                                       ),
//                                     );
//                                   }),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                       // return RatingListTile(
//                       //   title: Text("第 ${index + 1} 天"),
//                       //   icon: FontAwesomeIcons.bolt,
//                       //   count: 5,
//                       //   selected: record.pain,
//                       //   dense: true,
//                       //   color: Colors.yellow,
//                       // );
//                     } else {
//                       return RatingListTile(
//                         title: Text("时间"),
//                         icon: FontAwesomeIcons.bolt,
//                         count: 5,
//                         selected: 5,
//                         dense: true,
//                       );
//                     }
//                   }),
//                   onExpansionChanged: (expand) {
//                     if (expand) state.loadMenses(period);
//                   },
//                 ),
//               );
//             }),
//           if (state.periods.length == 0)
//             ListTile(
//               title: Text("目前还没有记录哦"),
//             ),
//         ]);
//       },
//     );
//   }
//
//   normalTitleStyle() {
//     return TextStyle(
//       fontSize: 18,
//     );
//   }
//
//   normalContentStyle() {
//     return TextStyle(
//       fontSize: 36,
//     );
//   }
//
//   exceptionTitleStyle() {
//     return TextStyle(
//       fontSize: 18,
//       color: Colors.red.shade800,
//     );
//   }
//
//   exceptionContentStyle() {
//     return TextStyle(
//       fontSize: 36,
//       color: Colors.red.shade800,
//     );
//   }
//
//   durationTextStyle() {
//     return TextStyle(
//       fontSize: 12,
//     );
//   }
//
//   lengthTextStyle() {
//     return TextStyle(
//       fontSize: 16,
//     );
//   }
// }
//
// class AnalysisViewState extends ChangeNotifier {
//   bool loading;
//   bool mensesLoading;
//
//   List<Period> periods;
//   List<Period> abnormals;
//
//   Map<Period, Map<int, Record>> menses;
//
//   AnalysisViewState() {
//     loading = true;
//     mensesLoading = false;
//     periods = [];
//     abnormals = [];
//     menses = {};
//     initData();
//   }
//
//   initData() async {
//     final list = await RecordRepository().findAllAsc();
//
//     for (var record in list) {
//       if (record.type == RecordType.MENSES) {
//         if (periods.length > 0) {
//           var prev = periods.last;
//           prev.finish(record.date - Duration(days: 1));
//           if (prev.abnormal) abnormals.add(prev);
//         }
//         periods.add(Period()..add(record));
//       } else {
//         periods.last.add(record);
//       }
//     }
//
//     loading = false;
//     notifyListeners();
//   }
//
//   loadMenses(Period period) async {
//     final result = await period.menses;
//     menses[period] = {};
//     result.forEach((record) {
//       menses[period][record.date.daySign] = record;
//     });
//     notifyListeners();
//   }
// }

class AnalysisView extends StatelessWidget {
  const AnalysisView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text("Analysis View"),
    );
  }
}
