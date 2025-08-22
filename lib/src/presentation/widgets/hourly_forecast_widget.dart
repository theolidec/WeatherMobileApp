import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/hourly_forecast_model.dart';
import '../../data/models/weather_model.dart';
import '../../data/providers/settings_provider.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> hourlyForecasts;
  final ScrollController? scrollController;

  const HourlyForecastWidget({
    Key? key,
    required this.hourlyForecasts,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    
    // Debug information
    debugPrint('Building HourlyForecastWidget with ${hourlyForecasts.length} forecasts');
    if (hourlyForecasts.isNotEmpty) {
      debugPrint('First forecast time: ${hourlyForecasts.first.time}');
      debugPrint('Last forecast time: ${hourlyForecasts.last.time}');
    } else {
      debugPrint('No hourly forecasts available to display');
    }
    
    final settings = Provider.of<SettingsProvider>(context);
    
    return Container(
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
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title
            const Text(
              '12-Hour Forecast',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Hourly forecast list
            SizedBox(
              height: 120,
              child: hourlyForecasts.isEmpty
                  ? const Center(
                      child: Text(
                        'No hourly forecast available',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: hourlyForecasts.length,
                      itemBuilder: (context, index) {
                        final forecast = hourlyForecasts[index];
                        final time = forecast.time;
                        final isNow = _isSameHour(time, now);
                        
                        return Container(
                          width: 75, // Reduced from 80
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: isNow
                                ? Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Time
                              Text(
                                _formatTime(time, isNow),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11, // Slightly smaller font
                                ),
                              ),
                              
                              // Weather icon
                              Container(
                                padding: const EdgeInsets.all(4), // Reduced padding
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getWeatherIcon(forecast.weatherCode),
                                  size: 20, // Slightly smaller icon
                                  color: Colors.white,
                                ),
                              ),
                              
                              // Temperature
                              Text(
                                '${settings.formatTemperature(forecast.temperature)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15, // Slightly smaller font
                                ),
                              ),
                              
                              // Wind and precipitation in a column to save horizontal space
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Wind
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.air,
                                        size: 10,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 1),
                                      Text(
                                        settings.formatSpeed(forecast.windSpeed),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Precipitation if any
                                  if (forecast.precipitation > 0) 
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.water_drop,
                                          size: 10,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 1),
                                        Text(
                                          settings.formatPrecipitation(forecast.precipitation),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  bool _isSameHour(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour;
  }
  
  String _formatTime(DateTime time, bool isNow) {
    if (isNow) return 'Now';
    final now = DateTime.now();
    if (time.day == now.day) {
      return DateFormat('h a').format(time);
    } else if (time.day == now.day + 1) {
      return '${DateFormat('h a').format(time)}';
    } else {
      return '${DateFormat('h a').format(time)}\n${DateFormat('MMM d').format(time)}';
    }
  }
  
  IconData _getWeatherIcon(int weatherCode) {
    // WMO Weather interpretation codes (https://open-meteo.com/docs)
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
        return Icons.water_drop;
      
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
