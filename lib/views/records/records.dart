import 'package:flutter/cupertino.dart';
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
          height: top + 128,
          color: theme.primaryColor,
        ),

        // 日历
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              Calendar(
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

              // 数据检视
              Inspector(),
            ]),
          ),
        )
      ]),
    );
  }
}

class RecordsViewState extends ChangeNotifier {
  RecordsViewState();

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate {
    return _selectedDate;
  }

  set selectedDate(DateTime date) {
    this._selectedDate = date;
    notifyListeners();
  }
}
