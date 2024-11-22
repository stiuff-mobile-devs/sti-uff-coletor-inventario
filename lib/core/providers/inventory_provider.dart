import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/core/models/inventory_item.dart';
import 'package:stiuffcoletorinventario/core/models/package_model.dart';
import 'package:stiuffcoletorinventario/core/services/local_storage_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

class InventoryProvider with ChangeNotifier {
  List<InventoryItem> _items = [];
  List<PackageModel> _packages = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<InventoryItem> get items => _items;
  List<PackageModel> get packages => _packages;

  final _random = Random();

  Future<String> uploadImageToStorage(String path, String storagePath) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final file = File(path);
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      debugPrint('Imagem enviada com sucesso: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Erro ao enviar imagem para o Firebase Storage: $e');
      throw Exception('Erro ao enviar imagem');
    }
  }

  Future<String> getImageUrl(String storagePath) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final downloadUrl = await storageRef.getDownloadURL();
      debugPrint('URL da imagem recuperada: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Erro ao recuperar URL da imagem: $e');
      throw Exception('Erro ao recuperar imagem');
    }
  }

  // Future<void> deleteImageFromStorage(String storagePath) async {
  //   try {
  //     final storageRef = FirebaseStorage.instance.ref().child(storagePath);
  //     await storageRef.delete();
  //     debugPrint('Imagem deletada com sucesso: $storagePath');
  //   } catch (e) {
  //     debugPrint('Erro ao deletar imagem do Firebase Storage: $e');
  //     throw Exception('Erro ao deletar imagem');
  //   }
  // }

  Future<int> sendPackageToFirebase(
      List<PackageModel> selectedPackages, List<InventoryItem> allItems) async {
    try {
      for (var package in selectedPackages) {
        final packageItems =
            allItems.where((item) => item.packageId == package.id).toList();

        if (package.id == 0) {
          int newId;
          do {
            newId = _random.nextInt(90000000) + 10000000;
          } while (_packages.any((p) => p.id == newId));

          package.id = newId;
        }

        final packageRef =
            _firestore.collection('packages').doc(package.id.toString());
        await packageRef.set(package.toMap());

        for (var item in packageItems) {
          item.packageId = package.id;

          if (item.images != null && item.images!.isNotEmpty) {
            List<String> uploadedUrls = [];
            for (var imagePath in item.images!) {
              try {
                final imageUrl = await uploadImageToStorage(
                  imagePath,
                  'items/${package.id}/${item.barcode}/${DateTime.now().millisecondsSinceEpoch}.jpg',
                );
                uploadedUrls.add(imageUrl);
              } catch (e) {
                debugPrint(
                    'Erro ao fazer upload de imagem do item ${item.barcode}: $e');
                return 502;
              }
            }
            item.images = uploadedUrls;
          }

          await packageRef
              .collection('items')
              .doc(item.barcode)
              .set(item.toMap());
        }

        await clearItemsForPackage(package.id);
        return 200;
      }
    } catch (e) {
      debugPrint('Erro ao enviar para o Firebase: $e');
    }
    return 500;
  }

  Future<void> clearItemsForPackage(int packageId) async {
    final localStorageService = DatabaseHelper();

    try {
      await localStorageService.removeItemsByPackageId(packageId).then((value) {
        _items.removeWhere((item) => item.packageId == packageId);
        notifyListeners();
      });
      debugPrint('Itens do pacote #$packageId limpos com sucesso.');
    } catch (e) {
      debugPrint('Erro ao limpar itens do pacote #$packageId: $e');
    }
  }

  Future<void> loadPackages() async {
    final localStorageService = DatabaseHelper();
    _packages = await localStorageService.getAllPackages();
    notifyListeners();
  }

  Future<void> updatePackage(PackageModel package) async {
    final localStorageService = DatabaseHelper();

    try {
      await localStorageService.updatePackage(package);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar pacote: $e');
    }
  }

  Future<int> addPackage(PackageModel package) async {
    final localStorageService = DatabaseHelper();

    final existingPackages = await localStorageService.getAllPackages();
    final existingPackage = existingPackages.firstWhere(
      (existingPackage) => existingPackage.id == package.id,
      orElse: () => PackageModel(id: 1, name: '', tags: []),
    );

    if (existingPackage.id != 1) {
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
      await localStorageService.removePackage(packageId);

      for (var item in _items) {
        if ((item.packageId) == packageId) {
          item.packageId = 0;
        }
      }

      _packages.removeWhere((package) => package.id == packageId);

      notifyListeners();
      debugPrint('Pacote removido com sucesso! #$packageId');
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
        packageId: 0,
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
