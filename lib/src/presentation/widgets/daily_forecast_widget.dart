import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/weather_model.dart';
import '../../data/providers/settings_provider.dart';

class _WeatherIconInfo {
  final IconData icon;
  final String description;

  const _WeatherIconInfo(this.icon, this.description);
}

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast>? forecastDays;
  
  const DailyForecastWidget({
    Key? key,
    this.forecastDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    // Debug information
    debugPrint('DailyForecastWidget - Building with ${forecastDays?.length ?? 0} forecast days');
    if (forecastDays != null && forecastDays!.isNotEmpty) {
      debugPrint('First forecast day: ${forecastDays!.first.date} - ${forecastDays!.first.weatherCode}');
      debugPrint('Last forecast day: ${forecastDays!.last.date} - ${forecastDays!.last.weatherCode}');
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A6FA5), Color(0xFF6BC5F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and info icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '7-Day Forecast',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 20, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    _showWeatherIconsInfo(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 2),
            
            // Daily forecast list
            SizedBox(
              height: 160, // Slightly taller to accommodate the new layout
              child: forecastDays == null || forecastDays!.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today, size: 32, color: Colors.white70),
                          SizedBox(height: 8),
                          Text(
                            'No forecast data available',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: forecastDays!.length,
                      itemBuilder: (context, index) {
                        final day = forecastDays![index];
                        return _buildForecastItem(context, day, settings);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItem(BuildContext context, DailyForecast day, SettingsProvider settings) {
    final dayName = DateFormat('E').format(day.date);
    final isToday = day.date.day == DateTime.now().day;
    
    String formatTemp(double? temp) {
      if (temp == null) return '--';
      return '${_formatTemperature(temp, settings.temperatureUnit)}°';
    }
    
    return Container(
      width: 90, // Slightly wider for better content fit
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: isToday
            ? Border.all(
                color: Colors.white,
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Day and date
          Column(
            children: [
              Text(
                isToday ? 'Today' : dayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                DateFormat('d MMM').format(day.date),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          // Weather icon in a circle
          if (day.weatherCode != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getWeatherIcon(day.weatherCode!),
                size: 24,
                color: Colors.white,
              ),
            ),
          ],
          
          // Temperature range
          Column(
            children: [
              // Max temperature
              Text(
                formatTemp(day.maxTemperature),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              // Min temperature
              Text(
                formatTemp(day.minTemperature),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          // Precipitation chance if available
          if (day.precipitationSum > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.water_drop,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${day.precipitationSum.toStringAsFixed(1)}mm',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ].whereType<Widget>().toList(),
      ),
    );
  }

  String _formatTemperature(double temp, TemperatureUnit unit) {
    final value = unit == TemperatureUnit.fahrenheit 
        ? (temp * 9/5) + 32 
        : temp;
    return value.toStringAsFixed(0);
  }

  void _showWeatherIconsInfo(BuildContext context) {
    final weatherIcons = [
      _WeatherIconInfo(Icons.wb_sunny, 'Clear sky'),
      _WeatherIconInfo(Icons.cloud_queue, 'Partly cloudy'),
      _WeatherIconInfo(Icons.cloud, 'Overcast'),
      _WeatherIconInfo(Icons.foggy, 'Fog or rime fog'),
      _WeatherIconInfo(Icons.grain, 'Drizzle/Freezing drizzle'),
      _WeatherIconInfo(Icons.water_drop, 'Rain/Showers'),
      _WeatherIconInfo(Icons.ac_unit, 'Freezing rain/Snow'),
      _WeatherIconInfo(Icons.thunderstorm, 'Thunderstorm'),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weather Icons Guide'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...weatherIcons.map((info) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(info.icon, size: 32, color: Colors.blue),
                    const SizedBox(width: 16),
                    Expanded(child: Text(info.description)),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(int weatherCode) {
    // WMO Weather interpretation codes (https://open-meteo.com/en/docs)
    switch (weatherCode) {
      // Clear sky
      case 0:
        return Icons.wb_sunny;
      
      // Mainly clear, partly cloudy, and overcast
      case 1: // Mainly clear
      case 2: // Partly cloudy
        return Icons.cloud_queue;
      case 3: // Overcast
        return Icons.cloud;
      
      // Fog and depositing rime fog
      case 45: // Fog
      case 48: // Depositing rime fog
        return Icons.foggy;
      
      // Drizzle: Light, moderate, and dense intensity
      case 51: // Light drizzle
      case 53: // Moderate drizzle
      case 55: // Dense drizzle
      case 56: // Light freezing drizzle
      case 57: // Dense freezing drizzle
        return Icons.grain;
      
      // Rain: Slight, moderate and heavy intensity
      case 61: // Slight rain
      case 63: // Moderate rain
      case 65: // Heavy rain
      case 80: // Slight rain showers
      case 81: // Moderate rain showers
      case 82: // Violent rain showers
        return Icons.water_drop; // Umbrella with rain
      
      // Freezing rain
      case 66: // Light freezing rain
      case 67: // Heavy freezing rain
        return Icons.ac_unit;
      
      // Snow fall: Slight, moderate, and heavy intensity
      case 71: // Slight snow fall
      case 73: // Moderate snow fall
      case 75: // Heavy snow fall
      case 77: // Snow grains
      case 85: // Slight snow showers
      case 86: // Heavy snow showers
        return Icons.ac_unit;
      
      // Thunderstorm: Slight or moderate
      case 95: // Thunderstorm: Slight or moderate
      case 96: // Thunderstorm with slight hail
      case 99: // Thunderstorm with heavy hail
        return Icons.thunderstorm;
      
      // Default icon for any unhandled codes
      default:
        return Icons.wb_sunny;
    }
  }
}