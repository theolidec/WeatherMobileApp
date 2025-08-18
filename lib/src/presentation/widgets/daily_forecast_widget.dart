import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/weather_model.dart';
import '../../data/providers/settings_provider.dart';

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
    
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '7-Day Forecast',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 140,
              child: forecastDays == null || forecastDays!.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today, size: 32, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No forecast data available', 
                              style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            isToday ? 'Today' : dayName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4.0),
          day.weatherCode != null 
              ? Icon(
                  _getWeatherIcon(day.weatherCode!), 
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                )
              : const Text('--', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 4.0),
          Text(
            formatTemp(day.maxTemperature),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            formatTemp(day.minTemperature),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTemperature(double temp, TemperatureUnit unit) {
    final value = unit == TemperatureUnit.fahrenheit 
        ? (temp * 9/5) + 32 
        : temp;
    return value.toStringAsFixed(0);
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
        return Icons.wb_cloudy;
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
        return Icons.beach_access; // Umbrella with rain
      
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
