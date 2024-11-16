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

  Future<int> addItem(InventoryItem item) async {
    final localStorageService = DatabaseHelper();

    final existingItems = await localStorageService.getAllItems();
    final existingItem = existingItems.firstWhere(
      (existingItem) => existingItem.barcode == item.barcode,
      orElse: () => InventoryItem(
        barcode: "-1",
        name: '',
        description: '',
        packageId: '',
        location: '',
        geolocation: '',
        observations: '',
        date: DateTime.now(),
        images: [],
      ),
    );

    if (existingItem.barcode != "-1") {
      debugPrint('Erro: Já existe um item com o mesmo barcode.');
      return 1;
    }

    try {
      await localStorageService.saveInventoryItemLocally(item);
      _items.add(item);
      notifyListeners();
      return 0;
    } catch (e) {
      debugPrint('Erro ao adicionar item: $e');
    }
    return 1;
  }

  Future<int> updateItem(InventoryItem item) async {
    final localStorageService = DatabaseHelper();
    try {
      await localStorageService.updateInventoryItem(item);

      final index = _items
          .indexWhere((existingItem) => existingItem.barcode == item.barcode);
      if (index != -1) {
        _items[index] = item;
        notifyListeners();
        return 0;
      } else {
        debugPrint(
            'Item com barcode ${item.barcode} não encontrado na lista local.');
      }
    } catch (e) {
      debugPrint('Erro ao atualizar item: $e');
      return 1;
    }
    return 1;
  }

  Future<void> clearItems() async {
    final localStorageService = DatabaseHelper();
    await localStorageService.clearItems();
    _items.clear();
    notifyListeners();
  }
}
