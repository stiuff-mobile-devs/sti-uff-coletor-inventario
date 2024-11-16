import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stiuffcoletorinventario/core/models/inventory_item.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'inventory.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE inventory (
          barcode INTEGER PRIMARY KEY,
          name TEXT,
          description TEXT,
          packageId TEXT,
          location TEXT,
          geolocation TEXT,
          observations TEXT,
          date TEXT,
          images TEXT
        )
      ''');
    });
  }

  static Future<void> insertInventoryItem(InventoryItem item) async {
    final db = await database;

    final List<Map<String, dynamic>> existingItems = await db.query(
      'inventory',
      where: 'barcode = ?',
      whereArgs: [item.barcode],
    );

    if (existingItems.isNotEmpty) {
      throw Exception('Um item com este barcode já existe.');
    }

    await db.insert(
      'inventory',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    final db = await database;
    try {
      await db.update(
        'inventory',
        item.toMap(),
        where: 'barcode = ?',
        whereArgs: [item.barcode],
      );
      debugPrint('Item de inventário atualizado com sucesso!');
    } catch (e) {
      debugPrint('Erro ao atualizar item: $e');
    }
  }

  Future<void> saveInventoryItemLocally(InventoryItem item) async {
    try {
      await DatabaseHelper.insertInventoryItem(item);
      debugPrint('Item de inventário salvo localmente!');
    } catch (e) {
      debugPrint('Erro ao salvar item: $e');
    }
  }

  Future<List<InventoryItem>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('inventory');

    return List.generate(maps.length, (i) {
      final imagesData = maps[i]['images'];

      List<String>? images;
      if (imagesData is String) {
        images = imagesData.isNotEmpty ? imagesData.split(',') : null;
      } else {
        debugPrint(
            'Tipo inesperado em "images": $imagesData (${imagesData.runtimeType})');
        _clearDatabaseIfNeeded(db);
        images = null;
      }

      return InventoryItem(
        barcode: maps[i]['barcode'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        packageId: maps[i]['packageId'],
        location: maps[i]['location'],
        geolocation: maps[i]['geolocation'],
        observations: maps[i]['observations'],
        date: DateTime.parse(maps[i]['date']),
        images: images,
      );
    });
  }

  Future<void> _clearDatabaseIfNeeded(Database db) async {
    await db.delete('inventory');
    debugPrint('Dados corrompidos detectados. Tabela "inventory" limpa.');
  }

  Future<void> clearItems() async {
    final db = await database;
    await db.delete('inventory');
  }
}
