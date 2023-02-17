import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/inventory_line.dart';

class InventoryLineDatabase {
  static final InventoryLineDatabase instance = InventoryLineDatabase._init();

  static Database? _database;

  InventoryLineDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory_line.db');
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
CREATE TABLE $tableInventoryLine (
  ${InventoryLineFields.id} $idType
  , ${InventoryLineFields.item_name} $textType
  , ${InventoryLineFields.item_desc} $textType
  , ${InventoryLineFields.in_stock} $integerType
  , ${InventoryLineFields.image_path} $textType
)
''');
  }

  Future<InventoryLine> create(InventoryLine inventory_line) async {
    final db = await instance.database;
    final id = await db.insert(tableInventoryLine, inventory_line.toJson());

    return inventory_line.copy(id: id);
  }

  Future<InventoryLine> readBook(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableInventoryLine,
      columns: InventoryLineFields.values,
      where: '${InventoryLineFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return InventoryLine.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<InventoryLine>> readAllInventoryLine() async {
    final db = await instance.database;
    final orderBy = '${InventoryLineFields.id} DESC';
    final result = await db.query(tableInventoryLine, orderBy: orderBy);

    return result.map((json) => InventoryLine.fromJson(json)).toList();
  }

  Future<int> update(InventoryLine inventory_line) async {
    final db = await instance.database;

    return db.update(
      tableInventoryLine,
      inventory_line.toJson(),
      where: '${InventoryLineFields.id} = ?',
      whereArgs: [inventory_line.id],
    );
  }

  Future<int> updateColumn(InventoryLine inventory_line, Map<String, Object?> columns) async {
    final db = await instance.database;
    Map<String, Object?> inventory_line_json = inventory_line.toJson();
    for(String key in columns.keys){
      inventory_line_json.update(key, (value) => columns[key]);
    }

    return db.update(
      tableInventoryLine,
      inventory_line_json,
      where: '${InventoryLineFields.id} = ?',
      whereArgs: [inventory_line.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return db.delete(
      tableInventoryLine,
      where: '${InventoryLineFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final db = await instance.database;
    
    return db.delete(
      tableInventoryLine,
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

}
