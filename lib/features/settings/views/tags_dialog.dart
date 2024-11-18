import 'package:flutter/material.dart';

class TagsDialog extends StatefulWidget {
  final List<String> allTags;
  final List<String> selectedTags;
  final Function(List<String>) onTagsSelected;

  const TagsDialog({
    super.key,
    required this.allTags,
    required this.selectedTags,
    required this.onTagsSelected,
  });

  @override
  TagsDialogState createState() => TagsDialogState();
}

class TagsDialogState extends State<TagsDialog> {
  late List<String> selectedTagsTemp;
  final TextEditingController _newTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedTagsTemp = List<String>.from(widget.selectedTags);
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecione as Tags'),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
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
                const SizedBox(height: 12),
                TextField(
                  controller: _newTagController,
                  decoration: const InputDecoration(
                    labelText: 'Criar nova tag',
                    border: OutlineInputBorder(),
                    hintText: 'Digite o nome da nova tag',
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        widget.allTags.add(value);
                      });
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Aplicar'),
          onPressed: () {
            widget.onTagsSelected(selectedTagsTemp);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("As alterações em tags foram salvas.")),
            );
          },
        ),
      ],
    );
  }
}
