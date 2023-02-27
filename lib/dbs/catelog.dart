// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/catelog.dart';

class CatelogDatabase {
  static final CatelogDatabase instance = CatelogDatabase._init();

  static Database? _database;

  CatelogDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('catelog.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $tableCatelog (
  ${CatelogFields.id} $idType
  , ${CatelogFields.categ_name} $textType
)
''');
  }

  Future<Catelog> create(Catelog catelog) async {
    final db = await instance.database;
    final id = await db.insert(tableCatelog, catelog.toJson());

    return catelog.copy(id: id);
  }

  Future<Catelog> readBook(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableCatelog,
      columns: CatelogFields.values,
      where: '${CatelogFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Catelog.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Catelog>> readAllCatelog() async {
    final db = await instance.database;
    final orderBy = '${CatelogFields.id} DESC';
    final result = await db.query(tableCatelog, orderBy: orderBy);

    return result.map((json) => Catelog.fromJson(json)).toList().reversed.toList();
  }

  Future<int> update(Catelog catelog) async {
    final db = await instance.database;

    return db.update(
      tableCatelog,
      catelog.toJson(),
      where: '${CatelogFields.id} = ?',
      whereArgs: [catelog.id],
    );
  }

  Future<int> updateColumn(Catelog catelog, Map<String, Object?> columns) async {
    final db = await instance.database;
    Map<String, Object?> catelog_json = catelog.toJson();
    for(String key in columns.keys){
      catelog_json.update(key, (value) => columns[key]);
    }

    return db.update(
      tableCatelog,
      catelog_json,
      where: '${CatelogFields.id} = ?',
      whereArgs: [catelog.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return db.delete(
      tableCatelog,
      where: '${CatelogFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final db = await instance.database;
    
    return db.delete(
      tableCatelog,
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

}
