import 'package:easy_localization/easy_localization.dart';

class WeatherUtils {
  static String getWeatherCondition(int code, {bool isDay = true}) {
    switch (code) {
      // Clear
      case 0:
        return isDay ? 'weather_clear_sky'.tr() : 'weather_clear_night'.tr();
      // Mainly clear, partly cloudy, and overcast
      case 1:
        return isDay ? 'weather_mostly_clear'.tr() : 'weather_mostly_clear_night'.tr();
      case 2:
        return 'weather_partly_cloudy'.tr();
      case 3:
        return 'weather_overcast'.tr();
      // Fog and depositing rime fog
      case 45:
      case 48:
        return 'weather_fog'.tr();
      // Drizzle
      case 51:
      case 53:
      case 55:
        return 'weather_drizzle'.tr();
      // Freezing Drizzle
      case 56:
      case 57:
        return 'weather_freezing_drizzle'.tr();
      // Rain
      case 61:
      case 63:
      case 65:
        return 'weather_rain'.tr();
      // Freezing Rain
      case 66:
      case 67:
        return 'weather_freezing_rain'.tr();
      // Snow fall
      case 71:
      case 73:
      case 75:
        return 'weather_snow'.tr();
      // Snow grains
      case 77:
        return 'weather_snow_grains'.tr();
      // Rain showers
      case 80:
      case 81:
      case 82:
        return 'weather_rain_showers'.tr();
      // Snow showers
      case 85:
      case 86:
        return 'weather_snow_showers'.tr();
      // Thunderstorm
      case 95:
        return 'weather_thunderstorm'.tr();
      // Thunderstorm with hail
      case 96:
      case 99:
        return 'weather_thunderstorm_hail'.tr();
      default:
        return 'weather_unknown'.tr();
    }
  }
}
