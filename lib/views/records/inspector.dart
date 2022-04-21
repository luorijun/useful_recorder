import 'package:flutter/material.dart';
import 'package:useful_recorder/models/record.dart';
import 'package:useful_recorder/widgets/headers.dart';

typedef RecordUpdateEvent(Record record);

class Inspector extends StatelessWidget {
  final Record? record;
  final RecordUpdateEvent? onRecordUpdate;

  const Inspector({this.record, this.onRecordUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader("记录"),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 16),
                height: 128,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 16),
                height: 128,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 16),
                height: 128,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
