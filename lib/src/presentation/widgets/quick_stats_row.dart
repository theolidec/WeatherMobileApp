import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/settings_provider.dart';
import 'stat_card.dart';

/// A horizontal row of weather statistics (rain chance, wind speed, humidity).
class QuickStatsRow extends StatelessWidget {
  final int uvIndex;
  final double windSpeed;
  final String humidity;
  final Color? gradientStartColor;
  final Color? gradientEndColor;
  final double cardBorderRadius;
  final double spacing;

  const QuickStatsRow({
    Key? key,
    required this.uvIndex,
    required this.windSpeed,
    required this.humidity,
    this.gradientStartColor,
    this.gradientEndColor,
    this.cardBorderRadius = 18,
    this.spacing = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // UV index stat card
        Expanded(
          child: StatCard(
            label: 'UV Index',
            value: '$uvIndex of 11',
            icon: Icons.light_mode_outlined,
            gradientStartColor: gradientStartColor,
            gradientEndColor: gradientEndColor,
            borderRadius: cardBorderRadius,
          ),
        ),
        
        SizedBox(width: spacing),
        
        // Wind speed stat card
        Expanded(
          child: StatCard(
            label: 'Wind',
            value: settings.formatSpeed(windSpeed),
            icon: Icons.air_outlined,
            gradientStartColor: gradientStartColor,
            gradientEndColor: gradientEndColor,
            borderRadius: cardBorderRadius,
          ),
        ),
        
        SizedBox(width: spacing),
        
        // Humidity stat card
        Expanded(
          child: StatCard(
            label: 'Humidity',
            value: humidity,
            icon: Icons.water_drop_outlined,
            gradientStartColor: gradientStartColor,
            gradientEndColor: gradientEndColor,
            borderRadius: cardBorderRadius,
          ),
        ),
      ],
    );
  }
}
