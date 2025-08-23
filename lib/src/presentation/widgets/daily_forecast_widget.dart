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

class DailyForecastWidget extends StatefulWidget {
  final List<DailyForecast>? forecastDays;
  
  const DailyForecastWidget({
    Key? key,
    this.forecastDays,
  }) : super(key: key);

  @override
  State<DailyForecastWidget> createState() => _DailyForecastWidgetState();
}

class _DailyForecastWidgetState extends State<DailyForecastWidget> {
  int? _selectedDayIndex;

  @override
  void initState() {
    super.initState();
    // Select today by default if available
    if (widget.forecastDays != null && widget.forecastDays!.isNotEmpty) {
      final now = DateTime.now();
      final todayIndex = widget.forecastDays!.indexWhere(
        (day) => day.date.year == now.year && 
                day.date.month == now.month && 
                day.date.day == now.day
      );
      _selectedDayIndex = todayIndex >= 0 ? todayIndex : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    // Debug information
    debugPrint('DailyForecastWidget - Building with ${widget.forecastDays?.length ?? 0} forecast days');
    if (widget.forecastDays != null && widget.forecastDays!.isNotEmpty) {
      debugPrint('First forecast day: ${widget.forecastDays!.first.date} - ${widget.forecastDays!.first.weatherCode}');
      debugPrint('Last forecast day: ${widget.forecastDays!.last.date} - ${widget.forecastDays!.last.weatherCode}');
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
                  style: const TextStyle(
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
            
            const SizedBox(height: 10),
            
            // Daily forecast list
            SizedBox(
              height: 170, // Slightly taller to prevent overflow
              child: widget.forecastDays == null || widget.forecastDays!.isEmpty
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
                      itemCount: widget.forecastDays!.length,
                      itemBuilder: (context, index) {
                        final day = widget.forecastDays![index];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDayIndex = index),
                          child: _buildForecastItem(
                            context, 
                            day, 
                            settings,
                            isSelected: _selectedDayIndex == index,
                          ),
                        );
                      },
                    ),
            ),
            
            // Daily conclusion section
            if (_selectedDayIndex != null && widget.forecastDays != null && widget.forecastDays!.isNotEmpty)
              _buildDailyConclusion(widget.forecastDays![_selectedDayIndex!], settings),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyConclusion(DailyForecast day, SettingsProvider settings) {
    String getWindDirection(int degrees) {
      if (degrees >= 337.5 || degrees < 22.5) return 'N';
      if (degrees < 67.5) return 'NE';
      if (degrees < 112.5) return 'E';
      if (degrees < 157.5) return 'SE';
      if (degrees < 202.5) return 'S';
      if (degrees < 247.5) return 'SW';
      if (degrees < 292.5) return 'W';
      return 'NW';
    }

    String formatTemp(double? temp) {
      if (temp == null) return '--';
      final value = _formatTemperature(temp, settings.temperatureUnit);
      switch (settings.temperatureUnit) {
        case TemperatureUnit.kelvin:
          return '${value}°K';
        case TemperatureUnit.fahrenheit:
          return '${value}°F';
        case TemperatureUnit.celsius:
        default:
          return '${value}°C';
      }
    }
    
    String formatSpeed(double? speedKmh) {
      if (speedKmh == null) return '--';
      final value = _formatSpeed(speedKmh, settings.speedUnit);
      return '$value ${_getSpeedUnitSuffix(settings.speedUnit)}';
    }
    
    String formatPrecipitation(double? mm) {
      if (mm == null) return '--';
      final value = _formatPrecipitation(mm, settings.precipitationUnit);
      return '$value ${_getPrecipitationUnitSuffix(settings.precipitationUnit)}';
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Overview - ${DateFormat('EEEE, MMM d').format(day.date)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem(
                Icons.thermostat_outlined,
                'High / Low',
                '${formatTemp(day.maxTemperature)} / ${formatTemp(day.minTemperature)}',
              ),
              if (day.sunrise != null && day.sunset != null) ...[
                _buildDetailItem(
                  Icons.wb_sunny,
                  'Sunrise',
                  DateFormat('h:mm a').format(day.sunrise!),
                ),
                _buildDetailItem(
                  Icons.nights_stay,
                  'Sunset',
                  DateFormat('h:mm a').format(day.sunset!),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem(
                Icons.air,
                'Wind',
                '${_formatSpeed(day.windSpeedMax, settings.speedUnit)} ${_getSpeedUnitSuffix(settings.speedUnit)} ${getWindDirection(day.windDirectionDominant)}',
              ),
              if (day.precipitationSum > 0) ...[
                _buildDetailItem(
                  Icons.water_drop_outlined,
                  'Precipitation',
                  formatPrecipitation(day.precipitationSum),
                ),
                _buildDetailItem(
                  Icons.timer_outlined,
                  'Precip. Hours',
                  '${day.precipitationHours.toStringAsFixed(1)} h',
                ),
              ] else
                // Empty container to maintain layout
                const SizedBox(width: 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastItem(BuildContext context, DailyForecast day, SettingsProvider settings, {bool isSelected = false}) {
    final dayName = DateFormat('E').format(day.date);
    final isToday = day.date.day == DateTime.now().day;
    
    String formatTemp(double? temp) {
      if (temp == null) return '--';
      final value = _formatTemperature(temp, settings.temperatureUnit);
      switch (settings.temperatureUnit) {
        case TemperatureUnit.kelvin:
          return '${value}°K';
        case TemperatureUnit.fahrenheit:
          return '${value}°F';
        case TemperatureUnit.celsius:
        default:
          return '${value}°C';
      }
    }
    
    return Container(
      width: 78, // Further reduced width
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.25) : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14), // Slightly smaller border radius
        border: isToday || isSelected
            ? Border.all(
                color: Colors.white,
                width: isSelected ? 1.5 : 1.0, // Thinner borders
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Day and date
          Column(
            mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getWeatherIcon(day.weatherCode!),
                size: 22, // Slightly smaller icon
                color: Colors.white,
              ),
            ),
          ],
          
          // Temperature range
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Max temperature
                Text(
                  formatTemp(day.maxTemperature),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14, // Slightly smaller font
                  ),
                ),
                // Min temperature
                Text(
                  formatTemp(day.minTemperature),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12, // Slightly smaller font
                  ),
                ),
              ],
            ),
          ),
          
          // Precipitation chance if available
          if (day.precipitationSum > 0) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                    settings.formatPrecipitation(day.precipitationSum),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ].whereType<Widget>().toList(),
      ),
    );
  }

  String _formatTemperature(double tempCelsius, TemperatureUnit unit) {
    switch (unit) {
      case TemperatureUnit.fahrenheit:
        return (tempCelsius * 9/5 + 32).toStringAsFixed(1);
      case TemperatureUnit.kelvin:
        return (tempCelsius + 273.15).toStringAsFixed(1);
      case TemperatureUnit.celsius:
      default:
        return tempCelsius.toStringAsFixed(1);
    }
  }

  String _formatSpeed(double speedKmh, SpeedUnit unit) {
    switch (unit) {
      case SpeedUnit.mph:
        return (speedKmh * 0.621371).toStringAsFixed(1);
      case SpeedUnit.ms:
        return (speedKmh / 3.6).toStringAsFixed(1);
      case SpeedUnit.kmh:
      default:
        return speedKmh.toStringAsFixed(1);
    }
  }

  String _formatPrecipitation(double mm, PrecipitationUnit unit) {
    if (unit == PrecipitationUnit.inches) {
      return (mm * 0.0393701).toStringAsFixed(2);
    }
    return mm.toStringAsFixed(1);
  }

  String _getSpeedUnitSuffix(SpeedUnit unit) {
    switch (unit) {
      case SpeedUnit.mph:
        return 'mph';
      case SpeedUnit.ms:
        return 'm/s';
      case SpeedUnit.kmh:
      default:
        return 'km/h';
    }
  }

  String _getPrecipitationUnitSuffix(PrecipitationUnit unit) {
    return unit == PrecipitationUnit.inches ? 'in' : 'mm';
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