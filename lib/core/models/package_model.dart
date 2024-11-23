class PackageModel {
  late int id;
  final String name;
  late List<String> tags;
  DateTime? createdAt;
  String? userId;

  PackageModel({
    required this.id,
    required this.name,
    required this.tags,
    this.createdAt,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'tags': tags.join(','),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toLocalMap() {
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
      tags: (map['tags'] as String?)?.split(',') ?? [],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }
}
