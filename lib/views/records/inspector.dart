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
    return SectionHeader("记录");
  }
}
