import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/core/models/inventory_item.dart';
import 'package:stiuffcoletorinventario/core/services/local_storage_service.dart';

class InventoryProvider with ChangeNotifier {
  List<InventoryItem> _items = [];

  List<InventoryItem> get items => _items;

  Future<void> loadItems() async {
    final localStorageService = DatabaseHelper();
    _items = await localStorageService.getAllItems();
    notifyListeners();
  }

  Future<void> addItem(InventoryItem item) async {
    final localStorageService = DatabaseHelper();
    await localStorageService.saveInventoryItemLocally(item);
    _items.add(item);
    notifyListeners();
  }

  Future<void> clearItems() async {
    final localStorageService = DatabaseHelper();
    await localStorageService.clearItems();
    _items.clear();
    notifyListeners();
  }
}
