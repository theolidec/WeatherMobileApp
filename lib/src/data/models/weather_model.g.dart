// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherModel _$WeatherModelFromJson(Map<String, dynamic> json) => WeatherModel(
  latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
  longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
  temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
  apparentTemperature:
      (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
  precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
  rain: (json['rain'] as num?)?.toDouble() ?? 0.0,
  showers: (json['showers'] as num?)?.toDouble() ?? 0.0,
  snowfall: (json['snowfall'] as num?)?.toDouble() ?? 0.0,
  weatherCode: (json['weathercode'] as num?)?.toInt() ?? 0,
  cloudCover: (json['cloudcover'] as num?)?.toInt() ?? 0,
  windSpeed: (json['windspeed_10m'] as num?)?.toDouble() ?? 0.0,
  windDirection: (json['winddirection_10m'] as num?)?.toInt() ?? 0,
  windGusts: (json['windgusts_10m'] as num?)?.toDouble() ?? 0.0,
  relativeHumidity: (json['relativehumidity_2m'] as num?)?.toInt() ?? 0,
  uvIndex: (json['uv_index'] as num?)?.toInt() ?? 0,
  time: WeatherModel._dateTimeFromJson(json['time'] as String),
  locationName: json['locationName'] as String?,
);

Map<String, dynamic> _$WeatherModelToJson(WeatherModel instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'temperature': instance.temperature,
      'apparent_temperature': instance.apparentTemperature,
      'precipitation': instance.precipitation,
      'rain': instance.rain,
      'showers': instance.showers,
      'snowfall': instance.snowfall,
      'weathercode': instance.weatherCode,
      'cloudcover': instance.cloudCover,
      'windspeed_10m': instance.windSpeed,
      'winddirection_10m': instance.windDirection,
      'windgusts_10m': instance.windGusts,
      'relativehumidity_2m': instance.relativeHumidity,
      'uv_index': instance.uvIndex,
      'time': WeatherModel._dateTimeToJson(instance.time),
      'locationName': instance.locationName,
    };
