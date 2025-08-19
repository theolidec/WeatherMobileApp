import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../data/models/location_result.dart';
import '../../data/services/location_history_service.dart';
import '../../data/services/location_service.dart';
import '../providers/weather_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/location_search_dialog.dart';
import '../widgets/daily_forecast_widget.dart';
import '../widgets/hourly_forecast_widget.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _autoRefreshTimer;
  String _version = '';
  final LocationHistoryService _locationHistoryService = LocationHistoryService();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _setupAutoRefresh();
  }

  void _setupAutoRefresh() {
    // Cancel any existing timer
    _autoRefreshTimer?.cancel();
    
    // Get the current refresh interval from settings
    final settings = context.read<SettingsProvider>();
    final refreshDuration = Duration(minutes: settings.refreshIntervalMinutes);
    
    // Set up the new timer
    _autoRefreshTimer = Timer.periodic(refreshDuration, (timer) {
      if (mounted) {
        _onRefresh();
      }
    });
  }

  Future<void> _initializeApp() async {
    // First try to load the most recent location
    final recentLocation = await _locationHistoryService.getMostRecentLocation();
    
    if (recentLocation != null) {
      // Use the most recent location
      await _loadWeather(
        latitude: recentLocation.latitude,
        longitude: recentLocation.longitude,
        locationName: recentLocation.getShortAddress(),
      );
    } else {
      // Default to a capital city (e.g., London) if no recent location
      await _loadWeather(
        latitude: 51.5074,  // London coordinates
        longitude: -0.1278,
        locationName: 'London, UK',
      );
    }
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'v${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  Future<void> _loadWeather({
    double? latitude,
    double? longitude,
    String? locationName,
    bool forceRefresh = false,
  }) async {
    if (!context.mounted) return;
    
    debugPrint('_loadWeather - forceRefresh: $forceRefresh');
    final weatherProvider = context.read<WeatherProvider>();
    await weatherProvider.fetchWeather(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      forceRefresh: forceRefresh || locationName != null, // Force refresh if location name changes
    );
    
    // Force a rebuild after loading new weather data
    if (context.mounted) {
      setState(() {});
    }
  }

  Future<void> _onRefresh() async {
    try {
      debugPrint('Starting refresh...');
      // Use context.mounted to check if the widget is still in the widget tree
      if (!context.mounted) return;
      
      final weatherProvider = context.read<WeatherProvider>();
      debugPrint('1. Getting most recent location...');
      final location = await _locationHistoryService.getMostRecentLocation();
      
      if (location != null) {
        debugPrint('2. Location found: ${location.getShortAddress()} (${location.latitude}, ${location.longitude})');
        debugPrint('3. Loading weather for location...');
        await _loadWeather(
          latitude: location.latitude,
          longitude: location.longitude,
          locationName: location.getShortAddress(),
          forceRefresh: true,  // Always force refresh on manual refresh
        );
      } else {
        debugPrint('2. No location found, using refreshWeather()');
        await weatherProvider.refreshWeather();
        
        // Force a rebuild after refresh
        if (context.mounted) {
          setState(() {});
        }
      }
      debugPrint('4. Refresh completed successfully');
    } catch (e, stackTrace) {
      debugPrint('Error in _onRefresh: $e');
      debugPrint('Stack trace: $stackTrace');
      if (context.mounted) {
        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh weather: ${e.toString()}')),
        );
      }
      rethrow;
    }
  }

  // Show location search dialog
  void _showLocationSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => const LocationSearchDialog(),
    ).then((location) {
      // This will be called when the dialog is closed with a location
      if (location != null) {
        // Trigger refresh when a new location is selected
        _onRefresh();
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will be called when dependencies change, including when settings are updated
    _setupAutoRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weatherProvider = context.watch<WeatherProvider>();
    final weather = weatherProvider.currentWeather;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    // Show loading indicator when initially loading weather data
    if (weatherProvider.isLoading && weather == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Fetching weather data...',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }
    
    // Show error message if there's an error and no cached data
    if (weatherProvider.error != null && weather == null) {
      return Scaffold(
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load weather data',
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weatherProvider.error!,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Location bar
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        // Location icon with search functionality
                        IconButton(
                          icon: const Icon(Icons.location_on_outlined),
                          onPressed: _showLocationSearchDialog,
                          tooltip: 'Change location',
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        
                        // const SizedBox(width: 5),
                        
                        // Location name with tap to search
                        Expanded(
                          child: InkWell(
                            onTap: _showLocationSearchDialog,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    weather?.locationName ?? 'Search for a location',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 21, // Increased from default 16
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Settings button
                        IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SettingsPage()),
                          ),
                          tooltip: 'Settings',
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),

                // Main weather content
                if (weather != null) ...[
                  // Current weather card
                  WeatherCard(
                    temperature: weather.temperature,
                    condition: weather.condition,
                    lastUpdated: 'Updated: ${_formatTime(weather.time)}',
                    windSpeed: weather.windSpeed,
                    humidity: '${weather.relativeHumidity}%',
                    icon: _getWeatherIcon(weather.weatherCode),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Hourly forecast section
                  if (weather.hourlyForecast?.isNotEmpty ?? false) ...[
                    HourlyForecastWidget(hourlyForecasts: weather.hourlyForecast!),
                    const SizedBox(height: 0),
                  ],
                  
                  // Daily forecast section
                  if (weather.dailyForecast != null && weather.dailyForecast!.isNotEmpty)
                    DailyForecastWidget(forecastDays: weather.dailyForecast!),
                ] else ...[
                  // No weather data available state
                  // No weather data available state
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No weather data available',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed: _onRefresh,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 5),
                // API attribution and version text at the bottom
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
                  child: Text(
                    'Weather Data From Open-Meteo API',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ),
                if (_version.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _version,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
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
