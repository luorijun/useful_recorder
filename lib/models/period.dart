import 'package:useful_recorder/models/record.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';

class Period {
  final List<Record> records = [];
  DateTime lastDay = DateTime.now().date;
  int mensesLength = 0;

  DateTime get firstDay => records.first?.date;

  int get length {
    if (records.length < 2) return records.length;
    return lastDay.difference(records.first.date).inDays;
  }

  bool get abnormal => length < 21 || length > 35;

  void add(Record record) => records.add(record);

  @override
  String toString() {
    return 'Period{'
        'records: $length, '
        'mensesLength: $mensesLength, '
        'length: $length, '
        'lastDay: $lastDay, '
        'exception: $abnormal}';
  }
}
