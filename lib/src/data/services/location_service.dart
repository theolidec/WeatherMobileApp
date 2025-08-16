import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/location_result.dart';

extension LocationResultExt on LocationResult {
  static LocationResult fromNominatimJson(Map<String, dynamic> json) {
    return LocationResult(
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
      displayName: json['display_name'] ?? 'Unknown Location',
      type: json['type'],
      address: json['address'] is Map<String, dynamic> 
          ? Map<String, dynamic>.from(json['address'] as Map)
          : null,
    );
  }
}

class LocationService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = 'weather_app/1.0';

  Future<List<LocationResult>> searchLocation(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/search?q=$query&format=json&addressdetails=1&limit=5'),
        headers: {
          'User-Agent': _userAgent,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<LocationResult>((item) => 
          LocationResultExt.fromNominatimJson(Map<String, dynamic>.from(item))
        ).toList();
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (e) {
      throw Exception('Failed to search locations: $e');
    }
  }

  Future<LocationResult> getReverseGeocoding(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reverse?lat=$lat&lon=$lon&format=json'),
        headers: {
          'User-Agent': _userAgent,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LocationResult.fromJson(data);
      } else {
        throw Exception('Failed to get location name');
      }
    } catch (e) {
      throw Exception('Failed to get reverse geocoding: $e');
    }
  }
}
