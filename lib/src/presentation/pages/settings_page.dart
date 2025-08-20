import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../theme/theme_provider.dart';
import '../../data/providers/settings_provider.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Units'),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return _buildUnitSelectionTile(
                context: context,
                title: 'Temperature Unit',
                currentValue: settings.temperatureUnit == TemperatureUnit.celsius 
                    ? 'Celsius (°C)' 
                    : settings.temperatureUnit == TemperatureUnit.fahrenheit
                        ? 'Fahrenheit (°F)'
                        : 'Kelvin (°K)',
                options: const ['Celsius (°C)', 'Fahrenheit (°F)', 'Kelvin (°K)'],
                onSelected: (value) {
                  TemperatureUnit unit;
                  switch (value) {
                    case 'Celsius (°C)':
                      unit = TemperatureUnit.celsius;
                      break;
                    case 'Fahrenheit (°F)':
                      unit = TemperatureUnit.fahrenheit;
                      break;
                    case 'Kelvin (°K)':
                      unit = TemperatureUnit.kelvin;
                      break;
                    default:
                      unit = TemperatureUnit.celsius;
                  }
                  settings.setTemperatureUnit(unit);
                },
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return _buildUnitSelectionTile(
                context: context,
                title: 'Precipitation Unit',
                currentValue: settings.precipitationUnit == PrecipitationUnit.mm 
                    ? 'Millimeters (mm)' 
                    : 'Inches (in)',
                options: const ['Millimeters (mm)', 'Inches (in)'],
                onSelected: (value) {
                  settings.setPrecipitationUnit(
                    value == 'Millimeters (mm)' 
                        ? PrecipitationUnit.mm 
                        : PrecipitationUnit.inches,
                  );
                },
              );
            },
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              String getSpeedUnitText() {
                switch (settings.speedUnit) {
                  case SpeedUnit.kmh:
                    return 'km/h';
                  case SpeedUnit.mph:
                    return 'mph';
                  case SpeedUnit.ms:
                    return 'm/s';
                }
              }
              
              return _buildUnitSelectionTile(
                context: context,
                title: 'Wind Speed Unit',
                currentValue: getSpeedUnitText(),
                options: const ['km/h', 'mph', 'm/s'],
                onSelected: (value) {
                  SpeedUnit unit;
                  switch (value) {
                    case 'km/h':
                      unit = SpeedUnit.kmh;
                      break;
                    case 'mph':
                      unit = SpeedUnit.mph;
                      break;
                    case 'm/s':
                      unit = SpeedUnit.ms;
                      break;
                    default:
                      unit = SpeedUnit.kmh;
                  }
                  settings.setSpeedUnit(unit);
                },
              );
            },
          ),
          
          const SizedBox(height: 16),
          _buildSectionHeader('Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              String getThemeModeName(ThemeMode mode) {
                switch (mode) {
                  case ThemeMode.system:
                    return 'System';
                  case ThemeMode.light:
                    return 'Light';
                  case ThemeMode.dark:
                    return 'Dark';
                }
              }
              
              return _buildUnitSelectionTile(
                context: context,
                title: 'Theme',
                currentValue: getThemeModeName(themeProvider.themeMode),
                options: const ['System', 'Light', 'Dark'],
                onSelected: (value) {
                  ThemeMode mode;
                  switch (value) {
                    case 'System':
                      mode = ThemeMode.system;
                      break;
                    case 'Light':
                      mode = ThemeMode.light;
                      break;
                    case 'Dark':
                      mode = ThemeMode.dark;
                      break;
                    default:
                      mode = ThemeMode.system;
                  }
                  themeProvider.setThemeMode(mode);
                },
              );
            },
          ),
          
          const SizedBox(height: 16),
          _buildSectionHeader('Data'),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return _buildRefreshIntervalTile(
                context: context,
                currentValue: settings.refreshInterval.displayName,
                options: RefreshInterval.values.map((e) => e.displayName).toList(),
                onSelected: (value) {
                  final selectedInterval = RefreshInterval.values.firstWhere(
                    (interval) => interval.displayName == value,
                    orElse: () => RefreshInterval.fifteenMinutes,
                  );
                  settings.setRefreshInterval(selectedInterval);
                },
              );
            },
          ),
          
          const SizedBox(height: 24),
          _buildAppVersion(),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
  
  Widget _buildUnitSelectionTile({
    required BuildContext context,
    required String title,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      child: GestureDetector(
        onTap: () {
          // Show the menu when the row is tapped
          final RenderBox button = context.findRenderObject() as RenderBox;
          final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
          final RelativeRect position = RelativeRect.fromRect(
            Rect.fromPoints(
              button.localToGlobal(Offset.zero, ancestor: overlay),
              button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
            ),
            Offset.zero & overlay.size,
          );
          
          showMenu<String>(
            context: context,
            position: position,
            items: options.map<PopupMenuItem<String>>((String value) {
              return PopupMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ).then((value) {
            if (value != null) {
              onSelected(value);
            }
          });
        },
        child: ListTile(
          title: Text(title),
          subtitle: Text(currentValue),
          trailing: const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }
  
  Widget _buildRefreshIntervalTile({
    required BuildContext context,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      child: GestureDetector(
        onTap: () {
          // Show the menu when the row is tapped
          final RenderBox button = context.findRenderObject() as RenderBox;
          final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
          final RelativeRect position = RelativeRect.fromRect(
            Rect.fromPoints(
              button.localToGlobal(Offset.zero, ancestor: overlay),
              button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
            ),
            Offset.zero & overlay.size,
          );
          
          showMenu<String>(
            context: context,
            position: position,
            items: options.map<PopupMenuItem<String>>((String value) {
              return PopupMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ).then((value) {
            if (value != null) {
              onSelected(value);
            }
          });
        },
        child: ListTile(
          title: const Text('Refresh Interval'),
          subtitle: Text(currentValue),
          trailing: const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }
  
  Widget _buildListTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
  
  Widget _buildAppVersion() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '1.0.0';
        final buildNumber = snapshot.data?.buildNumber ?? '0';
        return Center(
          child: Text(
            'v$version+$buildNumber',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        );
      },
    );
  }
}
