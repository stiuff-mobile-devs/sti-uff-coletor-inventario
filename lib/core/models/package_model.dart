class PackageModel {
  final int? id;
  final String name;
  final List<String> tags;

  PackageModel({
    this.id,
    required this.name,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tags': tags.join(','),
    };
  }

  static PackageModel fromMap(Map<String, dynamic> map) {
    return PackageModel(
      id: map['id'],
      name: map['name'],
      tags: (map['tags'] as String).split(','),
    );
  }
}
