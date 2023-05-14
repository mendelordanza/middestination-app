import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midjourney_app/model/history.dart';
import 'package:midjourney_app/model/pending.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final localStorageProvider =
    Provider<DeeperDatabase>((ref) => DeeperDatabase._init());

class DeeperDatabase {
  static final DeeperDatabase instance = DeeperDatabase._init();

  static Database? _database;

  DeeperDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB("middestination.dp");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
    final stringType = "TEXT NOT NULL";
    final stringNullType = "TEXT";

    await db.execute('''
CREATE TABLE $tableHistory (
  ${HistoryFields.id} $idType, 
  ${HistoryFields.messageId} $stringType,
  ${HistoryFields.content} $stringType,
  ${HistoryFields.url} $stringNullType,
  ${HistoryFields.createdAt} $stringType
)
''');

    await db.execute('''
CREATE TABLE $tablePending (
  ${PendingFields.id} $idType, 
  ${PendingFields.messageId} $stringNullType,
  ${PendingFields.prevMessageId} $stringType,
  ${PendingFields.content} $stringType,
  ${PendingFields.url} $stringNullType,
  ${PendingFields.createdAt} $stringType
)
''');
  }

  //Histories
  Future<bool> checkIfExistsComplete(String value) async {
    final db = await instance.database;
    final result = await db.query(tableHistory,
        where: '${HistoryFields.messageId} = ?', whereArgs: [value]);
    return result.isNotEmpty;
  }

  Future<History> create(History history) async {
    final ifExist = await checkIfExistsComplete(history.messageId);
    if (!ifExist) {
      final db = await instance.database;
      final id = await db.insert(tableHistory, history.toJson());
      return history.copy(id: id);
    }
    return history;
  }

  Future<List<History>> readAllHistories() async {
    final db = await instance.database;
    final result = await db.query(tableHistory, orderBy: 'createdAt DESC');
    return result.map((json) => History.fromJson(json)).toList();
  }

  //Pending
  Future<bool> checkIfExistsPending(String value) async {
    final db = await instance.database;
    final result = await db.query(tablePending,
        where: '${PendingFields.content} = ?', whereArgs: [value]);
    return result.isNotEmpty;
  }

  Future<Pending> createPending(Pending pending) async {
    final db = await instance.database;
    final id = await db.insert(tablePending, pending.toJson());
    return pending.copy(id: id);
  }

  Future<List<Pending>> readAllPending() async {
    final db = await instance.database;
    final result = await db.query(tablePending, orderBy: 'createdAt DESC');
    return result.map((json) => Pending.fromJson(json)).toList();
  }

  Future<int> deletePending(int id) async {
    final db = await instance.database;
    final result = await db.delete(tablePending,
        where: '${HistoryFields.id} = ?', whereArgs: [id]);
    return result;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
