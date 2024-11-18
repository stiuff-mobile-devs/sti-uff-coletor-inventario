// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stiuffcoletorinventario/core/models/inventory_item.dart';
import 'package:stiuffcoletorinventario/core/models/package_model.dart';
import 'package:stiuffcoletorinventario/core/providers/inventory_provider.dart';
import 'package:stiuffcoletorinventario/features/details/views/item_details_page.dart';
import 'package:stiuffcoletorinventario/features/form/views/form_page.dart';
import 'package:stiuffcoletorinventario/shared/components/confirmation_dialog.dart';
import 'package:stiuffcoletorinventario/shared/utils/app_colors.dart';
import 'package:stiuffcoletorinventario/shared/utils/custom_page_router.dart';

class InventoryGrid extends StatefulWidget {
  const InventoryGrid({super.key});

  @override
  InventoryGridState createState() => InventoryGridState();
}

class InventoryGridState extends State<InventoryGrid> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  PackageModel? selectedPackage;

  @override
  void initState() {
    super.initState();
    _loadInventory();
    _loadPackages();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  Future<bool?> _showDeleteCardConfirmationDialog(
      BuildContext context, InventoryItem item) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          onCancel: () {
            Navigator.of(context).pop(false);
          },
          onConfirm: () {
            Navigator.of(context).pop(true);
          },
          title: 'Confirmar Exclusão',
          message:
              'Você tem certeza de que deseja excluir este item (#${item.barcode}) do inventário local?',
          action: 'Apagar Item',
        );
      },
    );
  }

  Future<bool?> _showDeleteAllConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          onCancel: () {
            Navigator.of(context).pop(false);
          },
          onConfirm: () {
            Navigator.of(context).pop(true);
          },
          title: 'Confirmar Exclusão',
          message:
              'Você tem certeza de que deseja deletar permanentemente todos os itens do inventário local?',
          action: 'Apagar Tudo',
        );
      },
    );
  }

  Future<bool?> _showPackageConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          onCancel: () {
            Navigator.of(context).pop(false);
          },
          onConfirm: () {
            Navigator.of(context).pop(true);
          },
          title: 'Confirmar Envio',
          message:
              'Você tem certeza de que deseja enviar este pacote ao servidor?',
          action: 'Enviar',
          onConfirmColor: Colors.blue,
        );
      },
    );
  }

  Future<void> _loadPackages() async {
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);
    await inventoryProvider.loadPackages();
  }

  Future<void> _loadInventory() async {
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);
    await inventoryProvider.loadItems();
  }

  Future<void> _deleteItem(InventoryItem item) async {
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);
    await inventoryProvider.removeItem(item);

    final pathList = item.images ?? [];
    for (var imagePath in pathList) {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> _clearInventory() async {
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);

    final items = inventoryProvider.items;
    int deletedImagesCount = 0;

    for (var item in items) {
      final pathList = item.images ?? [];
      for (var imagePath in pathList) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
          deletedImagesCount++;
        }
      }
    }

    if (deletedImagesCount > 0) {
      debugPrint('$deletedImagesCount imagem(s) deletada(s)');
    } else {
      debugPrint('Nenhuma imagem encontrada para deletar.');
    }

    await inventoryProvider.clearItems();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    final items = inventoryProvider.items;
    var inventoryPackages = inventoryProvider.packages;

    List<PackageModel> packages = inventoryPackages;

    final List<InventoryItem> filteredItems;
    if ((selectedPackage == null)) {
      filteredItems = items;
    } else {
      filteredItems = filteredItems =
          items.where((item) => item.packageId == selectedPackage!.id).toList();
    }

    final List<List<InventoryItem>> pages = [];
    int itemCount = filteredItems.length;

    List<InventoryItem> firstPageItems = [
          InventoryItem(
            name: 'Adicionar Item',
            description: '',
            packageId: 0,
            barcode: '',
            location: '',
            date: DateTime.now(),
          ),
        ] +
        filteredItems.take(8).toList();
    pages.add(firstPageItems);

    for (int i = 8; i < itemCount; i += 9) {
      pages
          .add(filteredItems.sublist(i, i + 9 > itemCount ? itemCount : i + 9));
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackgroundColor,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Inventário Local',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.shadowColor,
                  ),
                ),
                const SizedBox(
                  width: 16.0,
                ),
                DropdownButton<PackageModel>(
                  value: packages.contains(selectedPackage)
                      ? selectedPackage
                      : null,
                  hint: const Text('Selecione um Pacote'),
                  onChanged: (PackageModel? newValue) {
                    setState(() {
                      selectedPackage = newValue;
                    });
                  },
                  items: packages.map<DropdownMenuItem<PackageModel>>(
                      (PackageModel value) {
                    return DropdownMenuItem<PackageModel>(
                      value: value,
                      child: Text(value.name),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SizedBox(
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                itemBuilder: (context, pageIndex) {
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemCount: pages[pageIndex].length,
                    itemBuilder: (context, index) {
                      if (pageIndex == 0 && index == 0) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(CustomPageRoute(
                              page: const FormPage(),
                            ));
                          },
                          child: const Card(
                            color: AppColors.appBarColor,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.add,
                                size: 40,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      } else {
                        final item = pages[pageIndex][index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(CustomPageRoute(
                              page: ItemDetailsPage(item: item),
                            ));
                          },
                          child: Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Card(
                                  color: AppColors.appBarColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.description ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.grey),
                                  onPressed: () async {
                                    bool? shouldDelete =
                                        await _showDeleteCardConfirmationDialog(
                                            context, item);
                                    if (shouldDelete ?? false) {
                                      _deleteItem(item);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${item.name} deletado com sucesso!'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 205, 205, 205),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          bool? shouldDeleteAll =
                              await _showDeleteAllConfirmationDialog(context);
                          if (shouldDeleteAll ?? false) {
                            _clearInventory();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Os dados do inventário local foram deletados.'),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(4),
                        splashColor: Colors.red.withOpacity(0.3),
                        hoverColor: Colors.red.withOpacity(0.1),
                        highlightColor: Colors.red.withOpacity(0.2),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_sweep,
                                color: Colors.red,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Limpar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        bool? shouldDeleteAll =
                            await _showPackageConfirmationDialog(context);
                        if (shouldDeleteAll ?? false) {
                          _clearInventory();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('O pacote foi enviado.'),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(4),
                      splashColor: Colors.blue.withOpacity(0.3),
                      hoverColor: Colors.blue.withOpacity(0.1),
                      highlightColor: Colors.blue.withOpacity(0.2),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.send,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Enviar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildPageIndicators(pages.length),
        ],
      ),
    );
  }

  Widget _buildPageIndicators(int pageCount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index
                  ? AppColors.orangeSelectionColor
                  : Colors.grey,
            ),
          );
        }),
      ),
    );
  }
}
