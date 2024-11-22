import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stiuffcoletorinventario/core/models/inventory_item.dart';
import 'package:stiuffcoletorinventario/core/models/package_model.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<void> onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      debugPrint('Atualizando banco para versão $newVersion...');
      await db.execute('''
      CREATE TABLE IF NOT EXISTS packages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        tags TEXT
      )
    ''');
      debugPrint('Tabela packages criada.');
    }
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'inventory.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        debugPrint('Criando tabela packages...');
        await db.execute('''
      CREATE TABLE packages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        tags TEXT
      )
    ''');
        debugPrint('Tabela packages criada.');

        debugPrint('Criando tabela inventory...');
        await db.execute('''
        CREATE TABLE inventory (
          barcode TEXT PRIMARY KEY,
          name TEXT,
          description TEXT,
          packageId INTEGER,
          location TEXT,
          geolocation TEXT,
          observations TEXT,
          date TEXT,
          images TEXT,
          FOREIGN KEY(packageId) REFERENCES packages(id)
        )
        ''');
        debugPrint('Tabela inventory criada.');

        await db.insert(
          'packages',
          {'id': 0, 'name': 'Pacote Default', 'tags': 'Default'},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        debugPrint('Pacote default inserido.');
      },
      onUpgrade: onUpgrade,
    );
  }

  Future<void> insertPackage(PackageModel package) async {
    final db = await database;

    await db.insert(
      'packages',
      package.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePackage(PackageModel package) async {
    final db = await database;

    await db.update(
      'packages',
      package.toMap(),
      where: 'id = ?',
      whereArgs: [package.id],
    );
  }

  Future<void> removePackage(int packageId) async {
    final db = await database;

    try {
      await db.delete(
        'packages',
        where: 'id = ?',
        whereArgs: [packageId],
      );

      await db.update(
        'inventory',
        {'packageId': 0},
        where: 'packageId = ?',
        whereArgs: [packageId],
      );
    } catch (e) {
      debugPrint('Erro ao remover pacote: $e');
    }
  }

  Future<List<PackageModel>> getAllPackages() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('packages');

    return List.generate(maps.length, (i) {
      return PackageModel.fromMap(maps[i]);
    });
  }

  Future<void> removeItemsByPackageId(int packageId) async {
    final db = await database;
    try {
      await db.delete(
        'inventory',
        where: 'packageId = ?',
        whereArgs: [packageId],
      );
      debugPrint('Itens com packageId $packageId removidos do banco de dados.');
    } catch (e) {
      debugPrint('Erro ao remover itens do banco de dados: $e');
      throw Exception('Erro ao remover itens do banco de dados');
    }
  }

  Future<void> removeItem(InventoryItem item) async {
    final db = await database;

    try {
      await db.delete(
        'inventory',
        where: 'barcode = ?',
        whereArgs: [item.barcode],
      );
      debugPrint('Item de inventário deletado com sucesso!');
    } catch (e) {
      debugPrint('Erro ao deletar item: $e');
    }
  }

  Future<void> insertInventoryItem(InventoryItem item) async {
    final db = await database;

    int packageId = (item.packageId);

    if (packageId != 0) {
      final List<Map<String, dynamic>> packageResult = await db.query(
        'packages',
        where: 'id = ?',
        whereArgs: [packageId],
      );

      if (packageResult.isEmpty) {
        debugPrint(
            'Pacote não encontrado. Armazenando no pacote default (ID: 0).');
        packageId = 0;
      }
    }

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
      {
        ...item.toMap(),
        'packageId': packageId,
      },
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
      await insertInventoryItem(item);
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

  Future<void> clearItems() async {
    final db = await database;
    await db.delete('inventory');
  }
}
