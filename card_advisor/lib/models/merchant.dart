import 'dart:convert';

class Merchant {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String mcc;
  final String category;
  final int visitCount;
  final double? distanceMeters; // Calculated at runtime

  Merchant({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.mcc,
    required this.category,
    this.visitCount = 0,
    this.distanceMeters,
  });

  Merchant copyWith({
    String? id,
    String? name,
    double? lat,
    double? lng,
    String? mcc,
    String? category,
    int? visitCount,
    double? distanceMeters,
  }) {
    return Merchant(
      id: id ?? this.id,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      mcc: mcc ?? this.mcc,
      category: category ?? this.category,
      visitCount: visitCount ?? this.visitCount,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'mcc': mcc,
      'category': category,
      'visit_count': visitCount,
    };
  }

  factory Merchant.fromMap(Map<String, dynamic> map) {
    return Merchant(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      lat: map['lat']?.toDouble() ?? 0.0,
      lng: map['lng']?.toDouble() ?? 0.0,
      mcc: map['mcc'] ?? '',
      category: map['category'] ?? '',
      visitCount: map['visit_count']?.toInt() ?? 0,
      distanceMeters: map['distance_meters']?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Merchant.fromJson(String source) =>
      Merchant.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Merchant(id: $id, name: $name, lat: $lat, lng: $lng, visitCount: $visitCount, distance: $distanceMeters)';
  }
}
