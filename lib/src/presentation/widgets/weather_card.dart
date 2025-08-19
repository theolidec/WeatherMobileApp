import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/settings_provider.dart';

/// A large card displaying current weather conditions including temperature, weather state,
/// wind speed, and humidity.
class WeatherCard extends StatelessWidget {
  final double temperature;
  final String condition;
  final String lastUpdated;
  final IconData icon;
  final double windSpeed;
  final String humidity;

  const WeatherCard({
    Key? key,
    required this.temperature,
    required this.condition,
    required this.lastUpdated,
    required this.windSpeed,
    required this.humidity,
    this.icon = Icons.cloud,
  }) : super(key: key);

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
                
                // Weather condition
                Text(
                  condition, 
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
                
                // Wind and humidity row
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Wind speed
                    Row(
                      children: [
                        const Icon(Icons.air, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${settings.formatSpeed(windSpeed)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Humidity
                    Row(
                      children: [
                        const Icon(Icons.water_drop_outlined, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          humidity,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
