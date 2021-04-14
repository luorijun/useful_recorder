import 'package:sqflite/sqflite.dart';

import 'package:useful_recorder/models/record.dart';
import 'package:useful_recorder/utils/datetime_extension.dart';

const table = "record";
const version = 9;

const creator = """
create table $table (
  date integer not null primary key,
  type integer not null,
  pain integer,
  flow integer,
  mood integer
)
""";

const dropper = """
drop table $table;
""";

class RecordRepository {
  RecordRepository._();

  static final RecordRepository _instance = RecordRepository._();

  factory RecordRepository() => _instance;

  Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;

    final dir = await getDatabasesPath();
    _db = await openDatabase(
      "$dir/$table.db",
      version: version,
      onCreate: (database, version) {
        return database.execute(creator);
      },
      onUpgrade: (database, oldVersion, newVersion) {
        if (newVersion > oldVersion) {
          database.execute(dropper);
          database.execute(creator);
        }
      },
    );

    return _db;
  }

  Future<List<Record>> findAllDesc() async {
    final db = await this.db;
    final result = await db.query(table, orderBy: "date DESC");
    return result.map((map) => Record.fromMap(map)).toList();
  }

  Future<List<Record>> findAllAsc() async {
    final db = await this.db;
    final result = await db.query(table, orderBy: "date ASC");
    return result.map((map) => Record.fromMap(map)).toList();
  }

  Future<List<Record>> findAllByDateBetween(
    DateTime start,
    DateTime end, [
    String order = "date ASC",
  ]) async {
    final db = await this.db;
    final result = await db.query(
      table,
      where: "date >= ? and date <= ?",
      whereArgs: [
        start.daySign,
        end.daySign,
      ],
      orderBy: order,
    );
    return result.map((item) => Record.fromMap(item)).toList();
  }

  Future<Record> findByDate(DateTime date) async {
    final db = await this.db;
    final result = await db.query(
      table,
      where: "date=?",
      whereArgs: [date.daySign],
    );
    if (result.isEmpty) return null;
    return Record.fromMap(result.first);
  }

  Future<bool> save(Record record) async {
    final db = await this.db;
    final result = await findByDate(record.date);
    if (result == null) {
      if (!record.isEmpty) {
        db.insert(table, record.toMap());
      }
    } else {
      if (record.isEmpty) {
        removeByDate(record.date);
      } else {
        db.update(
          table,
          record.toMap(),
          where: "date=?",
          whereArgs: [record.date.daySign],
        );
      }
    }
    return true;
  }

  Future<bool> removeByDate(DateTime date) async {
    final db = await this.db;
    db.delete(table, where: "date=?", whereArgs: [date.daySign]);
    return true;
  }
}
