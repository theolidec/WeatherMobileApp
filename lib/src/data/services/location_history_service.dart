import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/src/data/models/location_result.dart';
import 'dart:convert';

class LocationHistoryService {
  static const String _prefsKey = 'recent_locations';
  static const int _maxLocations = 5;

  Future<List<LocationResult>> getRecentLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final locationsJson = prefs.getStringList(_prefsKey) ?? [];
    
    return locationsJson
        .map((json) => LocationResult.fromJson(jsonDecode(json)))
        .toList();
  }

  /// Returns the most recent location, or null if no locations exist
  Future<LocationResult?> getMostRecentLocation() async {
    final locations = await getRecentLocations();
    return locations.isNotEmpty ? locations.first : null;
  }

  Future<void> addToHistory(LocationResult location) async {
    final prefs = await SharedPreferences.getInstance();
    final locations = await getRecentLocations();
    
    // Remove if already exists to avoid duplicates
    locations.removeWhere((l) => l.displayName == location.displayName);
    
    // Add to the beginning of the list
    locations.insert(0, location);
    
    // Trim to max size
    if (locations.length > _maxLocations) {
      locations.removeRange(_maxLocations, locations.length);
    }
    
    // Save back to prefs
    final locationsJson = locations
        .map((loc) => jsonEncode(loc.toJson()))
        .toList();
        
    await prefs.setStringList(_prefsKey, locationsJson);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
