import 'package:flutter/material.dart';

class Item {
  final String name;
  final String description;

  Item({
    required this.name,
    required this.description,
  });
}

class ItemDetail extends StatelessWidget {
  final Item item;

  const ItemDetail({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text(item.description),
    );
  }
}
