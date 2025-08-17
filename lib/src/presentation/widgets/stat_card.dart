import 'package:flutter/material.dart';

/// A single statistic card showing a weather metric.
/// 
/// [label] The name of the statistic (e.g., 'Humidity').
/// [value] The value to display (e.g., '68%').
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? gradientStartColor;
  final Color? gradientEndColor;
  final double? width;
  final double? height;
  final double borderRadius;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
    this.gradientStartColor = const Color(0xFF6B8DB8),
    this.gradientEndColor = const Color(0xFF6BC5F8),
    this.width,
    this.height,
    this.borderRadius = 18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Expanded makes the card take equal width in a row
    return Container(
      width: width,
      height: height,
      // Horizontal margin between cards
      margin: const EdgeInsets.symmetric(horizontal: 4),
      // Vertical padding for content
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      // Card styling with gradient background
      decoration: BoxDecoration(
        // Gradient background with null-coalescing for default colors
        gradient: LinearGradient(
          colors: [
            gradientStartColor ?? const Color(0xFF6B8DB8), 
            gradientEndColor ?? const Color(0xFF6BC5F8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // Rounded corners
        borderRadius: BorderRadius.circular(borderRadius),
        // Subtle shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Vertical stack of value and label
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon (if provided) above the value
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
          ],
          // Large, bold value (e.g., '75%')
          Text(
            value, 
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white, // White text for better contrast on gradient
            ),
          ),
          
          const SizedBox(height: 6), // Slightly more spacing between value and label
          
          // Smaller, dimmed label (e.g., 'Rain Chance')
          Text(
            label.toUpperCase(), // Uppercase for labels to match design
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withOpacity(0.9), // White with slight transparency
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
