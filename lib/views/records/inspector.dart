import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:useful_recorder/models/record.dart';
import 'package:useful_recorder/widgets/headers.dart';
import 'package:useful_recorder/widgets/more_list_tile.dart';

typedef RecordUpdateEvent(Record record);

class Inspector extends StatelessWidget {
  final Record? record;
  final RecordUpdateEvent? onRecordUpdate;

  const Inspector({this.record, this.onRecordUpdate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SectionHeader("记录"),
        Expanded(
          child: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: [
              // 经期记录块
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Builder(builder: (context) {
                  final double height = 48;
                  final double half = height / 2;
                  final double fontSize = 16;
                  return Column(
                    children: [
                      Row(children: [
                        Container(
                          width: height * 1.5,
                          height: height,
                          alignment: Alignment.center,
                          child: Text(
                            "延长",
                            style: TextStyle(
                              fontSize: fontSize,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(half),
                              bottomRight: Radius.circular(half),
                            ),
                            color: theme.colorScheme.primaryContainer,
                          ),
                        ),
                        SizedBox(width: 16),
                        Flexible(
                          child: Container(
                            height: height,
                            alignment: Alignment.center,
                            child: Text(
                              "新周期",
                              style: TextStyle(
                                fontSize: fontSize,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(half),
                              color: theme.colorScheme.primaryContainer,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          width: height * 1.5,
                          height: height,
                          alignment: Alignment.center,
                          child: Text(
                            "提前",
                            style: TextStyle(
                              fontSize: fontSize,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(half),
                              bottomLeft: Radius.circular(half),
                            ),
                            color: theme.colorScheme.primaryContainer,
                          ),
                        ),
                      ]),
                      RatingListTile(
                        title: Text("痛感"),
                        icon: FontAwesomeIcons.boltLightning,
                        max: 5,
                      ),
                      RatingListTile(
                        title: Text("流量"),
                        icon: FontAwesomeIcons.droplet,
                        max: 5,
                      ),
                    ],
                  );
                }),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
              ),

              // 日记记录块
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(children: [
                  VoteListTile(
                    title: Text("心情"),
                    icons: [
                      FontAwesomeIcons.faceGrinBeam,
                      FontAwesomeIcons.faceGrinStars,
                      FontAwesomeIcons.faceMehBlank,
                      FontAwesomeIcons.faceAngry,
                      FontAwesomeIcons.faceSadCry,
                    ],
                  ),
                  VoteListTile(
                    title: Text("天气"),
                    icons: [
                      FontAwesomeIcons.sun,
                      FontAwesomeIcons.cloud,
                      FontAwesomeIcons.wind,
                      FontAwesomeIcons.cloudRain,
                      FontAwesomeIcons.snowflake,
                    ],
                  ),
                  Divider(),
                  Container(
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
                  ),
                  Container(
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
                  ),
                ]),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
