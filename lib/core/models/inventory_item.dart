import 'dart:convert';
import 'package:intl/intl.dart';

class InventoryItem {
  final String barcode;
  final String name;
  final String? description;
  late int packageId;
  final String location;
  final List<String>? images;
  final String? geolocation;
  final String? observations;
  final DateTime date;

  InventoryItem({
    required this.barcode,
    required this.name,
    this.description,
    required this.packageId,
    required this.location,
    this.images,
    this.geolocation,
    this.observations,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'description': description,
      'packageId': packageId,
      'location': location,
      'images': images?.join(','),
      'geolocation': geolocation,
      'observations': observations,
      'date': DateFormat('yyyy-MM-dd').format(date),
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      barcode: map['barcode'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      packageId: map['packageId'],
      location: map['location'] ?? '',
      images: map['images'] != null ? map['images'].split(',') : [],
      geolocation: map['geolocation'],
      observations: map['observations'],
      date: DateFormat('yyyy-MM-dd')
          .parse(map['date'] ?? DateTime.now().toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory InventoryItem.fromJson(String source) {
    return InventoryItem.fromMap(json.decode(source));
  }
}
