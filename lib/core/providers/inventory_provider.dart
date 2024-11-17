import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/core/models/inventory_item.dart';
import 'package:stiuffcoletorinventario/core/models/package_model.dart';
import 'package:stiuffcoletorinventario/core/services/local_storage_service.dart';

class InventoryProvider with ChangeNotifier {
  List<InventoryItem> _items = [];
  List<PackageModel> _packages = [];

  List<InventoryItem> get items => _items;
  List<PackageModel> get packages => _packages;

  Future<void> loadPackages() async {
    final localStorageService = DatabaseHelper();
    _packages = await localStorageService.getAllPackages();
    notifyListeners();
  }

  Future<int> addPackage(PackageModel package) async {
    final localStorageService = DatabaseHelper();

    final existingPackages = await localStorageService.getAllPackages();
    final existingPackage = existingPackages.firstWhere(
      (existingPackage) => existingPackage.id == package.id,
      orElse: () => PackageModel(id: -1, name: '', tags: []),
    );

    if (existingPackage.id != -1) {
      debugPrint('Erro: Já existe um pacote com o mesmo id.');
      return 1;
    }

    try {
      await localStorageService.insertPackage(package);
      _packages.add(package);
      notifyListeners();
      return 0;
    } catch (e) {
      debugPrint('Erro ao adicionar pacote: $e');
      return 1;
    }
  }

  Future<void> removePackage(int packageId) async {
    final localStorageService = DatabaseHelper();

    try {
      // Remover o pacote do banco de dados
      await localStorageService.removePackage(
          packageId); // Método no DatabaseHelper para remover pacotes

      // Atualizar os itens relacionados ao pacote, colocando como pacote default (ID = 0)
      for (var item in _items) {
        if (int.parse(item.packageId ?? '0') == packageId) {
          item.packageId = '0'; // Altera os itens para o pacote default
        }
      }

      // Remover o pacote da lista local
      _packages.removeWhere((package) => package.id == packageId);

      notifyListeners();
      debugPrint('Pacote removido com sucesso!');
    } catch (e) {
      debugPrint('Erro ao remover pacote: $e');
    }
  }

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

  Future<void> removeItem(InventoryItem item) async {
    final localStorageService = DatabaseHelper();

    try {
      await localStorageService.removeItem(item);

      _items
          .removeWhere((existingItem) => existingItem.barcode == item.barcode);

      notifyListeners();

      debugPrint('Item de inventário removido com sucesso!');
    } catch (e) {
      debugPrint('Erro ao remover item: $e');
    }
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
