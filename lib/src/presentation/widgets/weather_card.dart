import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/providers/settings_provider.dart';
import '../../utils/weather_utils.dart';

/// A large card displaying current weather conditions including temperature, weather state,
/// wind speed, and humidity.
class WeatherCard extends StatelessWidget {
  final double temperature;
  final String condition;
  final String lastUpdated;
  final IconData icon;
  final double windSpeed;
  final int windDirection;
  final String humidity;

  const WeatherCard({
    Key? key,
    required this.temperature,
    required this.condition,
    required this.lastUpdated,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    this.icon = Icons.cloud,
  }) : super(key: key);
  
  String _getWindDirection(int degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'N';
    if (degrees < 67.5) return 'NE';
    if (degrees < 112.5) return 'E';
    if (degrees < 157.5) return 'SE';
    if (degrees < 202.5) return 'S';
    if (degrees < 247.5) return 'SW';
    if (degrees < 292.5) return 'W';
    return 'NW';
  }
  
  String _formatTemperature(double temp, bool isCelsius) {
    if (isCelsius) {
      return '${temp.toStringAsFixed(0)}°C';
    } else {
      // Convert to Fahrenheit
      final fahrenheit = (temp * 9/5) + 32;
      return '${fahrenheit.toStringAsFixed(0)}°F';
    }
  }
  
  // Format wind speed using the settings provider to ensure consistent units
  // This method is kept for backward compatibility but the main card uses SettingsProvider directly

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Container(
      // Card styling with gradient background
      decoration: BoxDecoration(
        // Gradient from dark blue to light blue
        gradient: const LinearGradient(
          colors: [Color(0xFF4A6FA5), Color(0xFF6BC5F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20), // Rounded corners
      ),
      padding: const EdgeInsets.all(20), // Internal spacing
      
      // Main content row
      child: Row(
        children: [
          // Weather Icon in a circular container
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15), // Semi-transparent white
              shape: BoxShape.circle, // Circular shape
            ),
            padding: const EdgeInsets.all(16), // Space around the icon
            child: Icon(
              icon, 
              color: Colors.white, 
              size: 40, // Large icon size
            ),
          ),
          
          const SizedBox(width: 28), // Spacing between icon and text
          
          // Temperature and confidence section
          Expanded( // Takes remaining width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
              children: [
                // Large temperature display
                Text(
                  settings.formatTemperature(temperature),
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 48, 
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  )
                ),
                
                const SizedBox(height: 4), // Vertical spacing
                
                // Weather condition with translation
                Text(
                  WeatherUtils.getWeatherCondition(int.tryParse(condition) ?? 0, isDay: true),
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Last updated time
                const SizedBox(height: 2),
                Text(
                  lastUpdated,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                
                // Wind and humidity rows
                const SizedBox(height: 8),
                // Wind speed row
                Row(
                  children: [
                    const Icon(Icons.air, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${'wind_speed'.tr()}: ${settings.formatSpeed(windSpeed)} ${_getWindDirection(windDirection)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Humidity row
                Row(
                  children: [
                    const Icon(Icons.water_drop_outlined, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${'humidity'.tr()}: $humidity',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
