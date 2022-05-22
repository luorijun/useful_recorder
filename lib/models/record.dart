import 'package:sqflite/sqflite.dart';

import '../utils/repository.dart';

// ==============================
// region 数据表
// TODO 有空从 repository 中改过来
// ==============================

const version = 8;

const drop = '''
drop table if exists record;
''';

const create = '''
create table record (
  id integer primary key autoincrement,
  date integer not null,
  type integer not null,
  pain integer,
  flow integer,
  emotion integer,
  weather integer,
  note text,
  title text
);
''';

final onCreate = (Database db, int version) {
  db.execute(create);
  db.setVersion(version);
};

final onUpgrade = (Database db, int oldVersion, int newVersion) {
  db.execute(drop);
  onCreate(db, newVersion);
};

// endregion

// ==============================
// region 模型
// ==============================

enum RecordType {
  MENSES_START,
  MENSES_END,
  NORMAL,
}

enum RecordEmotion {
  HAPPY,
  EXCITED,
  CALM,
  SAD,
  ANGRY,
}

enum RecordWeather {
  SUN,
  CLOUD,
  WIND,
  RAIN,
  SNOW,
}

class Record {
  int? id;

  DateTime? date;
  RecordType? type;

  int? pain;
  int? flow;

  RecordEmotion? emotion;
  RecordWeather? weather;

  String? note;
  String? title;

  Record(
    this.date, {
    this.type = RecordType.NORMAL,
    this.pain,
    this.flow,
    this.emotion,
    this.weather,
    this.note,
    this.title,
  });

  Record.fromMap(Map<String, dynamic> map) {
    date = DateTime.fromMillisecondsSinceEpoch(map['date']);
    type = map['type'] == -1 ? null : RecordType.values[map['type']];
    pain = map['pain'];
    flow = map['flow'];
    emotion = map['emotion'];
    weather = map['weather'];
    note = map['note'];
    title = map['title'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date?.millisecondsSinceEpoch,
      'type': type?.index ?? -1,
      'pain': pain,
      'flow': flow,
      'emotion': emotion?.index,
      'weather': weather?.index,
      'note': note,
      'title': title,
    };
  }

  @override
  String toString() {
    return 'Record{'
        'id: $id, '
        'date: $date, '
        'type: $type, '
        'pain: $pain, '
        'flow: $flow, '
        'emotion: $emotion, '
        'weather: $weather, '
        'note: $note, '
        'title: $title}';
  }
}

// endregion

// ==============================
// region 仓库
// ==============================

class RecordRepository extends Repository {
  RecordRepository._() : super(table: "record");

  static final RecordRepository _instance = RecordRepository._();

  factory RecordRepository() => _instance;

  Future<Record?> findFirstMensesAfterDate(DateTime date) async {
    final result = await findFirst(
      conditions: {
        'date': Condition('${date.millisecondsSinceEpoch}', Operator.GT),
        'type': Condition([RecordType.MENSES_START.index, RecordType.MENSES_END.index], Operator.IN),
      },
      orders: ['date asc'],
    );

    return _mapToRecord(result);
  }

  Future<Record?> findLastMensesBeforeDate(DateTime date) async {
    final result = await findFirst(
      conditions: {
        'date': Condition('${date.millisecondsSinceEpoch}', Operator.LT),
        'type': Condition([RecordType.MENSES_START.index, RecordType.MENSES_END.index], Operator.IN),
      },
      orders: ['date desc'],
    );

    return _mapToRecord(result);
  }

  Future<Record?> findByDate(DateTime date) async {
    final result = await findFirst(
      conditions: {'date': Condition('${date.millisecondsSinceEpoch}')},
    );
    return _mapToRecord(result);
  }

  Record? _mapToRecord(Map<String, dynamic>? map) {
    return map == null ? null : Record.fromMap(map);
  }
}

// endregion
