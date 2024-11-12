import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/features/home/models/item.dart';
import 'package:stiuffcoletorinventario/features/home/models/package_item.dart';

class HomeController {
  final TextEditingController searchController = TextEditingController();
  Map<String, List<Package>> groupedPackages = {};
  Map<String, List<Package>> filteredPackages = {};
  List<String> selectedTags = [];

  HomeController() {
    groupedPackages = _getGroupedPackages();
    filteredPackages = Map.from(groupedPackages);
    searchController.addListener(filterPackages);
  }

  void dispose() {
    searchController.removeListener(filterPackages);
    searchController.dispose();
  }

  void filterPackages() {
    final query = searchController.text.toLowerCase();
    filteredPackages = {};

    groupedPackages.forEach((key, packages) {
      final filteredList = packages.where((package) {
        final matchesName = package.name.toLowerCase().contains(query);
        final matchesTags = selectedTags.isEmpty ||
            selectedTags.any((tag) => package.tags.contains(tag));
        return matchesName && matchesTags;
      }).toList();

      if (filteredList.isNotEmpty) {
        filteredPackages[key] = filteredList;
      }
    });
  }

  List<String> getAllTags() {
    final tags = <String>{};
    for (var packages in groupedPackages.values) {
      for (var package in packages) {
        tags.addAll(package.tags);
      }
    }
    return tags.toList();
  }

  Map<String, List<Package>> _getGroupedPackages() {
    return {
      'Outubro 2024': [
        Package(
          id: '123',
          name: 'Pacote A',
          description: 'Descrição do Pacote A',
          dateSent: DateTime(2024, 10, 10),
          tags: ['PV', 'RE', 'STI'],
          items: [
            Item(name: 'Item 1', description: 'Descrição do Item 1'),
            Item(name: 'Item 2', description: 'Descrição do Item 2'),
          ],
        ),
        Package(
          id: '124',
          name: 'Pacote B',
          description: 'Descrição do Pacote B',
          dateSent: DateTime(2024, 10, 11),
          tags: ['HUAP', 'VE', 'DCC'],
          items: [
            Item(name: 'Item 1', description: 'Descrição do Item 1'),
            Item(name: 'Item 2', description: 'Descrição do Item 2'),
          ],
        ),
      ],
      'Janeiro 2024': [
        Package(
          id: '642',
          name: 'Pacote C',
          description: 'Descrição do Pacote C',
          dateSent: DateTime(2024, 01, 10),
          tags: ['PV', 'RE'],
          items: [
            Item(name: 'Item 1', description: 'Descrição do Item 1'),
            Item(name: 'Item 2', description: 'Descrição do Item 2'),
          ],
        ),
        Package(
          id: '875',
          name: 'Pacote D',
          description: 'Descrição do Pacote D',
          dateSent: DateTime(2024, 01, 11),
          tags: ['HUAP', 'VE'],
          items: [
            Item(name: 'Item 1', description: 'Descrição do Item 1'),
            Item(name: 'Item 2', description: 'Descrição do Item 2'),
          ],
        ),
      ],
    };
  }
}
