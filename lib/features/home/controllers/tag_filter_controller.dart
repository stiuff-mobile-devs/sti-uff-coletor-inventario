import 'package:flutter/material.dart';

class TagFilterController extends ChangeNotifier {
  final List<String> _selectedTags = [];

  List<String> get selectedTags => List.from(_selectedTags);

  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  void clearTags() {
    _selectedTags.clear();
    notifyListeners();
  }

  bool isTagSelected(String tag) => _selectedTags.contains(tag);
}
