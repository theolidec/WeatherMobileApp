import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/settings_provider.dart';
import 'stat_card.dart';

/// A horizontal row of weather statistics (rain chance, wind speed, humidity).
class QuickStatsRow extends StatelessWidget {
  final String rainChance;
  final double windSpeed;
  final String humidity;
  final Color? gradientStartColor;
  final Color? gradientEndColor;
  final double cardBorderRadius;
  final double spacing;

  const QuickStatsRow({
    Key? key,
    this.rainChance = '75%',
    this.windSpeed = 12.0,
    this.humidity = '68%',
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
        // Rain chance stat card
        Expanded(
          child: StatCard(
            label: 'Rain Chance',
            value: rainChance,
            gradientStartColor: gradientStartColor,
            gradientEndColor: gradientEndColor,
            borderRadius: cardBorderRadius,
          ),
        ),
        
        SizedBox(width: spacing),
        
        // Wind speed stat card
        Expanded(
          child: StatCard(
            label: 'Wind Speed',
            value: settings.formatSpeed(windSpeed),
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
            gradientStartColor: gradientStartColor,
            gradientEndColor: gradientEndColor,
            borderRadius: cardBorderRadius,
          ),
        ),
      ],
    );
  }
}
