import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/item_detail.dart';

class Package {
  final String id;
  final String name;
  final String description;
  final DateTime dateSent;
  final List<String> tags;
  final List<Item> items;

  Package({
    required this.id,
    required this.name,
    required this.description,
    required this.dateSent,
    required this.tags,
    required this.items,
  });
}

class PackageItem extends StatelessWidget {
  final Package package;

  const PackageItem({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              package.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(package.description),
            const SizedBox(height: 8),
            Text(
              'Data de envio: ${package.dateSent.toLocal()}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Wrap(
              spacing: 6,
              children:
                  package.tags.map((tag) => Chip(label: Text(tag))).toList(),
            ),
            ExpansionTile(
              title: const Text('Itens'),
              children:
                  package.items.map((item) => ItemDetail(item: item)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
