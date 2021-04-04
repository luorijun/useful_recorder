import 'package:useful_recorder/models/record.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';

class Period {
  final List<Record> records = [];
  int menses = 0;
  int period = 0;

  bool get abnormal => (menses < 3 || menses > 7 || period > 35 || period < 15) && !processing;

  bool get processing => records.last.type != Type.MensesEnd;

  void add(Record record) {
    if (records.isEmpty) assert(record.type == Type.MensesStart);

    menses = records.isEmpty
        ? DateTimeExtension.diff(DateTime.now(), record.date) + 1
        : record.type == Type.MensesEnd
            ? DateTimeExtension.diff(record.date + 1.day, records.first.date)
            : menses;
    records.add(record);
  }

  void end(DateTime date) {
    period = DateTimeExtension.diff(date, records.first.date);
  }

  @override
  String toString() {
    return 'Period{'
        'records: $records, '
        'abnormal: $abnormal}';
  }
}
