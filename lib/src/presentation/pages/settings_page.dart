import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../theme/theme_provider.dart';
import '../../data/providers/settings_provider.dart';

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
                    : 'Fahrenheit (°F)',
                options: const ['Celsius (°C)', 'Fahrenheit (°F)'],
                onSelected: (value) {
                  settings.setTemperatureUnit(
                    value == 'Celsius (°C)' 
                        ? TemperatureUnit.celsius 
                        : TemperatureUnit.fahrenheit,
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
              return ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
                onTap: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          
          const SizedBox(height: 16),
          _buildSectionHeader('Data'),
          _buildListTile(
            title: 'Refresh Interval',
            subtitle: '15 minutes',
            onTap: () {},
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
      child: ListTile(
        title: Text(title),
        subtitle: Text(currentValue),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.arrow_drop_down),
          onSelected: onSelected,
          itemBuilder: (BuildContext context) {
            return options.map<PopupMenuItem<String>>((String value) {
              return PopupMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList();
          },
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
