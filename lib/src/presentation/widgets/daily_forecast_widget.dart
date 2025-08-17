import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/mock/mock_weather_data.dart';
import '../../data/models/weather_model.dart';
import '../../data/providers/settings_provider.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<WeatherModel>? forecastDays;
  
  const DailyForecastWidget({
    Key? key,
    this.forecastDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                scrollDirection: Axis.horizontal,
                itemCount: (forecastDays ?? MockWeatherData.generateDailyForecast()).length,
                itemBuilder: (context, index) {
                  final day = (forecastDays ?? MockWeatherData.generateDailyForecast())[index];
                  return _buildForecastItem(context, day, settings);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastItem(BuildContext context, WeatherModel day, SettingsProvider settings) {
    final date = day.time;
    final dayName = DateFormat('E').format(date);
    final isToday = date.day == DateTime.now().day;
    
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
          // Weather icon would go here
          Icon(
            _getWeatherIcon(day.weatherCode),
            size: 28,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 4.0),
          Text(
            '${_formatTemperature(day.temperature, settings.temperatureUnit)}°',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
    // Simplified weather icon mapping
    if (weatherCode < 1) return Icons.wb_sunny;
    if (weatherCode < 3) return Icons.wb_cloudy;
    if (weatherCode < 50) return Icons.foggy;
    if (weatherCode < 70) return Icons.grain;
    if (weatherCode < 80) return Icons.umbrella;
    if (weatherCode < 90) return Icons.ac_unit;
    return Icons.thunderstorm;
  }
}
