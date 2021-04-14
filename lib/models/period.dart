import 'package:useful_recorder/models/record.dart';
import 'package:useful_recorder/models/record_repository.dart';

class Period {
  bool mensesEnd = false;
  DateTime mensesEndDate;

  bool periodEnd = false;
  DateTime periodEndDate;

  final List<Record> records = [];

  DateTime get mensesStartDate => records.first.date;

  int get mensesLength => records.length < 2
      ? records.length
      : (mensesEnd ? mensesEndDate : DateTime.now()).difference(mensesStartDate).inDays + 1;

  int get periodLength => records.length < 2
      ? records.length
      : (periodEnd ? periodEndDate : DateTime.now()).difference(mensesStartDate).inDays + 1;

  bool get processing => !(mensesEnd && periodEnd);

  bool get mensesAbnormal => (mensesEnd && mensesLength < 2) || mensesLength > 7;

  // TODO: 周期不一定是在固定时间范围内，只要规律即可
  bool get periodAbnormal => (periodEnd && periodLength < 21) || periodLength > 37;

  bool get abnormal => mensesAbnormal || periodAbnormal;

  Future<List<Record>> get menses async {
    return await RecordRepository().findAllByDateBetween(
      mensesStartDate,
      mensesEndDate,
    );
  }

  /// 时间增量顺序追加记录
  void add(Record record) {
    records.add(record);

    if (records.length == 1) {
      assert(record.type == Type.MensesStart);
      return;
    }

    if (record.type == Type.MensesEnd) {
      mensesEnd = true;
      mensesEndDate = record.date;
    }
  }

  /// 周期结束时间
  void finish(DateTime endDate) {
    periodEnd = true;
    periodEndDate = endDate;
  }
}
