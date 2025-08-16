class LocationResult {
  final double latitude;
  final double longitude;
  final String displayName;
  final String? type;
  final Map<String, dynamic>? address;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    this.type,
    this.address,
  });

  // Convert LocationResult to a Map
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'displayName': displayName,
      'type': type,
      'address': address,
    };
  }

  // Create LocationResult from a Map
  factory LocationResult.fromJson(Map<String, dynamic> json) {
    return LocationResult(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      displayName: json['displayName'] as String,
      type: json['type'] as String?,
      address: json['address'] as Map<String, dynamic>?,
    );
  }

  // Helper method to get a short address (city, country)
  String getShortAddress() {
    if (address == null) return displayName;
    
    final parts = <String>[];
    if (address?['city'] != null) {
      parts.add(address!['city'] as String);
    } else if (address?['town'] != null) {
      parts.add(address!['town'] as String);
    } else if (address?['village'] != null) {
      parts.add(address!['village'] as String);
    }
    
    if (address?['country'] != null) {
      parts.add(address!['country'] as String);
    }
    
    return parts.isNotEmpty ? parts.join(', ') : displayName;
  }
}
