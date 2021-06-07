import '../utils/repository.dart';

// ==============================
// region 模型
// ==============================

enum RecordType {
  MENSES_START,
  MENSES_END,
  NORMAL,
}

enum RecordEmotion {
  EXCITED,
  HAPPY,
  CALM,
  SAD,
  ANGRY,
  TIRED,
}

class Record {
  int? id;

  DateTime? date;

  RecordType? type;
  int? pain;
  int? flow;
  RecordEmotion? emotion;

  String? note;
  String? title;

  Record(
    this.date, {
    this.type = RecordType.NORMAL,
    this.pain,
    this.flow,
    this.emotion,
    this.note,
    this.title,
  });

  Record.fromMap(map) {
    date = DateTime.fromMillisecondsSinceEpoch(map['date']);
    type = map['type'] == -1 ? null : RecordType.values[map['type']];
    pain = map['pain'];
    flow = map['flow'];
    emotion = map['emotion'];
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
        'note: $note, '
        'title: $title}';
  }
}

// endregion

// ==============================
// region 数据源
// ==============================

class RecordRepository extends Repository {
  RecordRepository() : super(table: "record");
}

// endregion
