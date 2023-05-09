import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midjourney_app/model/history.dart';
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

    await db.execute('''
CREATE TABLE $tableHistory (
  ${HistoryFields.id} $idType, 
  ${HistoryFields.messageId} $stringType,
  ${HistoryFields.content} $stringType,
  ${HistoryFields.url} $stringType
)
''');
  }

  //Histories
  Future<History> create(History history) async {
    final db = await instance.database;
    final id = await db.insert(tableHistory, history.toJson());
    return history.copy(id: id);
  }

  Future<List<History>> readAllHistories() async {
    final db = await instance.database;
    final result = await db.query(tableHistory);
    return result.map((json) => History.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
