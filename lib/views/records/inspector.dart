import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:useful_recorder/constants.dart';
import 'package:useful_recorder/models/record.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';
import 'package:useful_recorder/utils/nullable.dart';
import 'package:useful_recorder/views/records/records.dart';
import 'package:useful_recorder/widgets/button.dart';
import 'package:useful_recorder/widgets/headers.dart';
import 'package:useful_recorder/widgets/more_list_tile.dart';

class InspectorViewState extends ChangeNotifier {}

typedef RecordUpdateEvent(Record record);

class Inspector extends StatelessWidget {
  final Record? record;
  final RecordUpdateEvent? onRecordUpdate;

  const Inspector({this.record, this.onRecordUpdate});

  @override
  Widget build(BuildContext context) {
    final calendarMode = context.select<RecordsViewState, CalendarMode>((state) => state.calendarMode);
    if (calendarMode != CalendarMode.MONTH) {
      return Container();
    }

    return ChangeNotifierProvider(
      create: (_) => InspectorViewState(),
      child: Column(children: [
        SectionHeader("记录"),
        Expanded(
          child: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: [
              RecordCard([
                MensesManager(),
                Divider(),
                PainManager(),
                FlowManager(),
              ]),
              RecordCard([
                EmotionManager(),
                WeatherManager(),
                Divider(),
                TitleManager(),
                ContentManager(),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}

class RecordCard extends StatelessWidget {
  const RecordCard(
    this.children, {
    Key? key,
  }) : super(key: key);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      child: Column(children: children),
    );
  }
}

class MensesManager extends StatelessWidget {
  const MensesManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Builder(builder: (context) {
        final records = context.read<RecordsViewState>();

        final info = context.select<RecordsViewState, DateInfo>((state) => state.selected);
        final date = info.date;
        final curr = info.curr;
        final prev = info.prev;
        final next = info.next;
        final mode = info.mode;

        final clipLeft = curr?.type != RecordType.MENSES_START && date.isPast;
        final clipRight = date.isPast;
        final remove = prev != null && date.isPast;
        final finish = date.isPast;
        final appendable = prev != null && (next == null || next.date!.difference(date).inDays >= 2) && date.isPast;
        final insertable = next != null && (prev == null || date.difference(prev.date!).inDays >= 2) && date.isPast;
        final mergeable = prev != null && next != null && date.isPast;
        final start = date.isPast;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: mode == DateMode.MENSES
              ? [
                  PrimaryButton.text(
                    "从左剪裁",
                    expand: true,
                    enabled: clipLeft,
                    onPressed: () {
                      records.clipLeft(date, curr, except(prev));
                    },
                  ),
                  SizedBox(width: 16),
                  PrimaryButton.text(
                    "删除",
                    expand: true,
                    enabled: remove,
                    onPressed: () {
                      records.remove(curr, except(prev), next);
                    },
                  ),
                  SizedBox(width: 16),
                  if (next != null)
                    PrimaryButton.text(
                      "从右剪裁",
                      expand: true,
                      enabled: clipRight,
                      onPressed: () {
                        records.clipRight(date, next);
                      },
                    ),
                  if (next == null)
                    PrimaryButton.text(
                      "结束",
                      expand: true,
                      enabled: finish,
                      onPressed: () {
                        records.end(date, curr);
                      },
                    ),
                ]
              : [
                  PrimaryButton.text(
                    "追加",
                    expand: true,
                    enabled: appendable,
                    onPressed: () {
                      records.append(date, except(prev));
                    },
                  ),
                  SizedBox(width: 16),
                  PrimaryButton.text(
                    "提前",
                    expand: true,
                    enabled: insertable,
                    onPressed: () {
                      records.insert(date, curr, except(next));
                    },
                  ),
                  SizedBox(width: 16),
                  PrimaryButton.text(
                    "合并",
                    expand: true,
                    enabled: mergeable,
                    onPressed: () {
                      records.merge(except(prev), except(next));
                    },
                  ),
                  SizedBox(width: 16),
                  if (next != null)
                    FutureBuilder<SharedPreferences>(
                      future: SharedPreferences.getInstance(),
                      builder: (context, future) {
                        var nextDiff;
                        nextDiff = except(next.date).difference(date).inDays;
                        final menses = future.data?.getInt(MENSES_LENGTH) ?? DEFAULT_MENSES_LENGTH;
                        final enabled = nextDiff >= menses + 1;
                        return PrimaryButton.text(
                          "新建",
                          expand: true,
                          enabled: date.isPast && future.connectionState == ConnectionState.done ? enabled : false,
                          onPressed: () {
                            records.add(date, curr);
                          },
                        );
                      },
                    ),
                  if (next == null)
                    PrimaryButton.text(
                      "开始",
                      expand: true,
                      enabled: start,
                      onPressed: () {
                        records.start(date, curr);
                      },
                    ),
                ],
        );
      }),
    );
  }
}

class PainManager extends StatelessWidget {
  const PainManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RatingListTile(
      title: Text("痛感"),
      icon: FontAwesomeIcons.boltLightning,
      max: 5,
    );
  }
}

class FlowManager extends StatelessWidget {
  const FlowManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RatingListTile(
      title: Text("流量"),
      icon: FontAwesomeIcons.droplet,
      max: 5,
    );
  }
}

class EmotionManager extends StatelessWidget {
  const EmotionManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VoteListTile(
      title: Text("心情"),
      icons: [
        FontAwesomeIcons.faceGrinBeam,
        FontAwesomeIcons.faceGrinStars,
        FontAwesomeIcons.faceMehBlank,
        FontAwesomeIcons.faceAngry,
        FontAwesomeIcons.faceSadCry,
      ],
    );
  }
}

class WeatherManager extends StatelessWidget {
  const WeatherManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VoteListTile(
      title: Text("天气"),
      icons: [
        FontAwesomeIcons.sun,
        FontAwesomeIcons.cloud,
        FontAwesomeIcons.wind,
        FontAwesomeIcons.cloudRain,
        FontAwesomeIcons.snowflake,
      ],
    );
  }
}

class TitleManager extends StatelessWidget {
  const TitleManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        style: TextStyle(
          fontSize: 24,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "标题...",
          hintStyle: theme.textTheme.caption!.copyWith(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}

class ContentManager extends StatelessWidget {
  const ContentManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      child: TextField(
        decoration: InputDecoration(
          hintText: "有什么想说的话呢~",
          hintStyle: theme.textTheme.caption!.copyWith(
            fontSize: 16,
          ),
          border: InputBorder.none,
        ),
      ),
      height: 128,
      padding: EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
