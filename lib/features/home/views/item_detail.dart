import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/core/models/inventory_item.dart';

class ItemDetail extends StatelessWidget {
  final InventoryItem item;

  const ItemDetail({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text(item.description ?? ''),
    );
  }
}
