import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TemperatureUnit { celsius, fahrenheit }
enum SpeedUnit { kmh, mph, ms }

enum RefreshInterval {
  fiveMinutes(5, '5 minutes'),
  fifteenMinutes(15, '15 minutes'),
  thirtyMinutes(30, '30 minutes'),
  oneHour(60, '1 hour'),
  twoHours(120, '2 hours');

  final int minutes;
  final String displayName;
  
  const RefreshInterval(this.minutes, this.displayName);
  
  static RefreshInterval fromMinutes(int minutes) {
    return RefreshInterval.values.firstWhere(
      (interval) => interval.minutes == minutes,
      orElse: () => RefreshInterval.fifteenMinutes,
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  static const String _tempUnitKey = 'temperature_unit';
  static const String _speedUnitKey = 'speed_unit';
  static const String _refreshIntervalKey = 'refresh_interval';
  static const int _defaultRefreshInterval = 15; // minutes
  
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  SpeedUnit _speedUnit = SpeedUnit.kmh;
  int _refreshInterval = _defaultRefreshInterval;

  TemperatureUnit get temperatureUnit => _temperatureUnit;
  SpeedUnit get speedUnit => _speedUnit;
  int get refreshIntervalMinutes => _refreshInterval;
  RefreshInterval get refreshInterval => RefreshInterval.fromMinutes(_refreshInterval);

  bool get isCelsius => _temperatureUnit == TemperatureUnit.celsius;
  bool get isKmh => _speedUnit == SpeedUnit.kmh;
  bool get isMph => _speedUnit == SpeedUnit.mph;
  bool get isMs => _speedUnit == SpeedUnit.ms;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _temperatureUnit = TemperatureUnit.values[
      prefs.getInt(_tempUnitKey) ?? TemperatureUnit.celsius.index
    ];
    _speedUnit = SpeedUnit.values[
      prefs.getInt(_speedUnitKey) ?? SpeedUnit.kmh.index
    ];
    _refreshInterval = prefs.getInt(_refreshIntervalKey) ?? _defaultRefreshInterval;
    notifyListeners();
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    if (_temperatureUnit == unit) return;
    
    _temperatureUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tempUnitKey, unit.index);
    notifyListeners();
  }

  Future<void> setSpeedUnit(SpeedUnit unit) async {
    if (_speedUnit == unit) return;
    
    _speedUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_speedUnitKey, unit.index);
    notifyListeners();
  }

  String formatTemperature(double tempCelsius) {
    if (_temperatureUnit == TemperatureUnit.fahrenheit) {
      return '${(tempCelsius * 9/5 + 32).toStringAsFixed(1)}°F';
    }
    return '${tempCelsius.toStringAsFixed(1)}°C';
  }

  String formatSpeed(double speedKmh) {
    switch (_speedUnit) {
      case SpeedUnit.mph:
        return '${(speedKmh * 0.621371).toStringAsFixed(1)} mph';
      case SpeedUnit.ms:
        return '${(speedKmh / 3.6).toStringAsFixed(1)} m/s';
      case SpeedUnit.kmh:
      default:
        return '${speedKmh.toStringAsFixed(1)} km/h';
    }
  }
  
  Future<void> setRefreshInterval(RefreshInterval interval) async {
    if (_refreshInterval == interval.minutes) return;
    
    _refreshInterval = interval.minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_refreshIntervalKey, _refreshInterval);
    notifyListeners();
  }
}
