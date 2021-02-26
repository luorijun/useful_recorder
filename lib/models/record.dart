import 'package:useful_recorder/utils/datetime_extension.dart';

enum Type {
  // 持久化时使用
  MensesStart,
  MensesEnd,
  // 内存中使用
  Menses,
  Ovulation,
  OvulationDay,
  Normal,
}

class Record {
  // 当天日期
  DateTime date;

  // 当天类型
  Type type;

  // 痛感
  int pain;

  // 流量
  int flow;

  // 心情
  int mood;

  Record(
    DateTime date, [
    this.type = Type.Normal,
    this.pain = 0,
    this.flow = 0,
    this.mood = 0,
  ]) {
    this.date = DateTime(date.year, date.month, date.day);
  }

  get isEmpty => (type != Type.MensesStart && type != Type.MensesEnd) && pain == 0 && flow == 0 && mood == 0;

  get isMenses => type == Type.MensesStart || type == Type.Menses || type == Type.MensesEnd;

  Record.fromMap(map)
      : date = DateTimeExtension.fromDaySign(map['date']),
        type = Type.values[map['type']],
        pain = map['pain'],
        flow = map['flow'],
        mood = map['mood'];

  Map<String, dynamic> toMap() => {
        'date': date.daySign,
        'type': type.index,
        'pain': pain,
        'flow': flow,
        'mood': mood,
      };

  @override
  String toString() {
    return 'Record{'
        'date: $date, '
        'type: $type, '
        'pain: $pain, '
        'flow: $flow, '
        'mood: $mood}';
  }
}
