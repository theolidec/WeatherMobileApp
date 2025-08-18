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
import '../widgets/quick_stats_row.dart';
import '../widgets/location_search_dialog.dart';
import '../widgets/daily_forecast_widget.dart';
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
                        
                        const SizedBox(width: 12),
                        
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
                    icon: _getWeatherIcon(weather.weatherCode),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Quick stats row (UV index, wind, humidity)
                  QuickStatsRow(
                    uvIndex: weather.uvIndex,
                    windSpeed: weather.windSpeed,
                    humidity: '${weather.relativeHumidity}%',
                    cardBorderRadius: 16,
                    spacing: 8,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Daily forecast section
                  if (weather.dailyForecast != null && weather.dailyForecast!.isNotEmpty)
                    DailyForecastWidget(forecastDays: weather.dailyForecast!),
                    
                  // Show loading indicator at the bottom when refreshing
                  if (weatherProvider.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ] else ...[
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
                
                const SizedBox(height: 24),
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
    // Map weather codes to appropriate icons
    if (weatherCode == 0) return Icons.wb_sunny; // Clear sky
    if (weatherCode <= 3) return Icons.wb_cloudy; // Partly cloudy
    if (weatherCode <= 19) return Icons.foggy; // Fog
    if (weatherCode <= 29) return Icons.grain; // Drizzle
    if (weatherCode <= 69) return Icons.umbrella; // Rain
    if (weatherCode <= 79) return Icons.ac_unit; // Snow
    if (weatherCode <= 99) return Icons.thunderstorm; // Thunderstorm
    return Icons.help_outline; // Unknown
  }
}
