import 'package:flutter/material.dart';

class PackageFilterDialog extends StatefulWidget {
  final List<String> allTags;
  final List<String> selectedTags;

  const PackageFilterDialog({
    super.key,
    required this.allTags,
    required this.selectedTags,
  });

  @override
  PackageFilterDialogState createState() => PackageFilterDialogState();
}

class PackageFilterDialogState extends State<PackageFilterDialog> {
  late List<String> selectedTagsTemp;

  @override
  void initState() {
    super.initState();
    selectedTagsTemp = List<String>.from(widget.selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecione as Tags'),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              children: widget.allTags.map((tag) {
                return FilterChip(
                  label: Text(tag),
                  selected: selectedTagsTemp.contains(tag),
                  onSelected: (bool selected) {
                    setState(() {
                      selected
                          ? selectedTagsTemp.add(tag)
                          : selectedTagsTemp.remove(tag);
                    });
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context, null),
        ),
        ElevatedButton(
          child: const Text('Aplicar'),
          onPressed: () => Navigator.pop(context, selectedTagsTemp),
        ),
      ],
    );
  }
}
