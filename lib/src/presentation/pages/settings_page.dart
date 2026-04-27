import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/theme_provider.dart';
import '../../data/providers/settings_provider.dart';
import '../widgets/language_selector.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('settings').tr(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('language'.tr()),
          const LanguageSelector(),
          const Divider(height: 32),
          _buildSectionHeader('units'.tr()),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return _buildUnitSelectionTile(
                context: context,
                title: 'temperature_unit'.tr(),
                currentValue: settings.temperatureUnit == TemperatureUnit.celsius 
                    ? 'celsius_c'.tr()
                    : settings.temperatureUnit == TemperatureUnit.fahrenheit
                        ? 'fahrenheit_f'.tr()
                        : 'kelvin_k'.tr(),
                options: [
                  'celsius_c'.tr(),
                  'fahrenheit_f'.tr(),
                  'kelvin_k'.tr(),
                ],
                onSelected: (value) {
                  TemperatureUnit unit;
                  if (value == 'celsius_c'.tr()) {
                    unit = TemperatureUnit.celsius;
                  } else if (value == 'fahrenheit_f'.tr()) {
                    unit = TemperatureUnit.fahrenheit;
                  } else {
                    unit = TemperatureUnit.kelvin;
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
                title: 'precipitation_unit'.tr(),
                currentValue: settings.precipitationUnit == PrecipitationUnit.mm 
                    ? 'millimeters_mm'.tr() 
                    : 'inches_in'.tr(),
                options: [
                  'millimeters_mm'.tr(),
                  'inches_in'.tr(),
                ],
                onSelected: (value) {
                  settings.setPrecipitationUnit(
                    value == 'millimeters_mm'.tr()
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
                    return 'kmh'.tr();
                  case SpeedUnit.mph:
                    return 'mph'.tr();
                  case SpeedUnit.ms:
                    return 'ms'.tr();
                }
              }
              
              return _buildUnitSelectionTile(
                context: context,
                title: 'speed_unit'.tr(),
                currentValue: getSpeedUnitText(),
                options: [
                  'kmh'.tr(),
                  'mph'.tr(),
                  'ms'.tr(),
                ],
                onSelected: (value) {
                  SpeedUnit unit;
                  if (value == 'kmh'.tr()) {
                    unit = SpeedUnit.kmh;
                  } else if (value == 'mph'.tr()) {
                    unit = SpeedUnit.mph;
                  } else {
                    unit = SpeedUnit.ms;
                  }
                  settings.setSpeedUnit(unit);
                },
              );
            },
          ),
          
          const SizedBox(height: 16),
          _buildSectionHeader('appearance'.tr()),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              String getThemeModeName(ThemeMode mode) {
                switch (mode) {
                  case ThemeMode.system:
                    return 'system_theme'.tr();
                  case ThemeMode.light:
                    return 'light_theme'.tr();
                  case ThemeMode.dark:
                    return 'dark_theme'.tr();
                  default:
                    return 'system_theme'.tr();
                }
              }
              
              return _buildUnitSelectionTile(
                context: context,
                title: 'theme'.tr(),
                currentValue: getThemeModeName(themeProvider.themeMode),
                options: [
                  'system_theme'.tr(),
                  'light_theme'.tr(),
                  'dark_theme'.tr(),
                ],
                onSelected: (value) {
                  ThemeMode mode;
                  if (value == 'light_theme'.tr()) {
                    mode = ThemeMode.light;
                  } else if (value == 'dark_theme'.tr()) {
                    mode = ThemeMode.dark;
                  } else {
                    mode = ThemeMode.system;
                  }
                  themeProvider.setThemeMode(mode);
                },
              );
            },
          ),
          
          const SizedBox(height: 16),
          _buildSectionHeader('data_privacy'.tr()),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              String getRefreshIntervalText() {
                final interval = settings.refreshInterval;
                if (interval.minutes < 60) {
                  return '${interval.minutes} ${interval.minutes == 1 ? 'minute'.tr() : 'minutes'.tr()}';
                } else if (interval.minutes == 60) {
                  return 'hour'.tr();
                } else {
                  final hours = interval.minutes ~/ 60;
                  return '$hours ${hours == 1 ? 'hour'.tr() : 'hours'.tr()}';
                }
              }
              
              return _buildUnitSelectionTile(
                context: context,
                title: 'refresh_interval'.tr(),
                currentValue: getRefreshIntervalText(),
                options: RefreshInterval.values.map((e) {
                  if (e.minutes < 60) {
                    return '${e.minutes} ${e.minutes == 1 ? 'minute'.tr() : 'minutes'.tr()}';
                  } else if (e.minutes == 60) {
                    return 'hour'.tr();
                  } else {
                    final hours = e.minutes ~/ 60;
                    return '$hours ${hours == 1 ? 'hour'.tr() : 'hours'.tr()}';
                  }
                }).toList(),
                onSelected: (value) {
                  // Find the matching RefreshInterval by comparing the display text
                  final selectedInterval = RefreshInterval.values.firstWhere(
                    (interval) {
                      String displayText;
                      if (interval.minutes < 60) {
                        displayText = '${interval.minutes} ${interval.minutes == 1 ? 'minute'.tr() : 'minutes'.tr()}';
                      } else if (interval.minutes == 60) {
                        displayText = 'hour'.tr();
                      } else {
                        final hours = interval.minutes ~/ 60;
                        displayText = '$hours ${hours == 1 ? 'hour'.tr() : 'hours'.tr()}';
                      }
                      return displayText == value;
                    },
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
