// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stiuffcoletorinventario/core/models/package_model.dart';
import 'package:stiuffcoletorinventario/core/providers/inventory_provider.dart';
import 'package:stiuffcoletorinventario/features/settings/views/tags_dialog.dart';
import 'package:stiuffcoletorinventario/shared/components/app_drawer.dart';
import 'package:stiuffcoletorinventario/shared/components/confirmation_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _packageNameController = TextEditingController();
  final Random _random = Random();

  @override
  void dispose() {
    _packageNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryProvider = Provider.of<InventoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: AppDrawer(selectedIndex: 1),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(bottom: 12.0, left: 8.0, right: 8.0),
              child: Text(
                "Pacotes",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                'Adicionar um novo pacote',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _packageNameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Digite o nome do novo pacote",
                  hintStyle: const TextStyle(color: Colors.black38),
                  suffixIcon: IconButton(
                    padding: const EdgeInsets.only(right: 28.0),
                    icon: const Icon(Icons.add, color: Colors.blue),
                    onPressed: () => _addPackage(context, inventoryProvider),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemCount: inventoryProvider.packages.length,
                itemBuilder: (context, index) {
                  final package = inventoryProvider.packages[index];
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 0.0),
                      title: Text(package.name,
                          style: Theme.of(context).textTheme.bodyMedium),
                      trailing: package.id != 0
                          ? SizedBox(
                              width: 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () => _openTagDialog(package),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _confirmDeletePackage(
                                        context, inventoryProvider, package.id),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTagDialog(PackageModel package) async {
    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);
    final allTags = inventoryProvider.packages
        .expand((p) => p.tags.where((tag) => tag.isNotEmpty))
        .toSet()
        .toList();
    final selectedTags = package.tags.where((tag) => tag.isNotEmpty).toList();

    final newTags = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return TagsDialog(
          allTags: allTags,
          selectedTags: selectedTags,
          onTagsSelected: (tags) {
            package.tags = tags;
            inventoryProvider.updatePackage(package);
          },
        );
      },
    );

    if (newTags != null) {
      setState(() {
        package.tags = newTags;
      });
      inventoryProvider.updatePackage(package);
    }
  }

  void _addPackage(BuildContext context, InventoryProvider provider) async {
    final packageName = _packageNameController.text.trim();
    if (packageName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O nome do pacote não pode estar vazio.")),
      );
      return;
    }

    final isDuplicate = provider.packages.any((p) => p.name == packageName);
    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Já existe um pacote com este nome.")),
      );
      return;
    }

    int packageId;
    do {
      packageId = _random.nextInt(90000000) + 10000000;
    } while (provider.packages.any((p) => p.id == packageId));

    final newPackage = PackageModel(id: packageId, name: packageName, tags: []);
    final result = await provider.addPackage(newPackage);

    if (result == 0) {
      _packageNameController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pacote adicionado com sucesso!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao adicionar pacote.")),
      );
    }
  }

  void _confirmDeletePackage(
    BuildContext context,
    InventoryProvider provider,
    int packageId,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          onCancel: () {
            Navigator.of(context).pop(false);
          },
          onConfirm: () async {
            await provider.removePackage(packageId);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Pacote excluído com sucesso!")),
            );
          },
          title: 'Confirmar Exclusão',
          message:
              'Você tem certeza de que deseja apagar este pacote do inventário local?',
          action: 'Excluir',
        );
      },
    );
  }
}
