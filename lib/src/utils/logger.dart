import 'dart:developer' as dev;

class AppLogger {
  static void info(String message, {String? name, dynamic error, StackTrace? stackTrace}) {
    dev.log(
      message,
      name: name ?? 'WeatherApp',
      level: 800, // INFO level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void debug(String message, {String? name}) {
    dev.log(
      message,
      name: name ?? 'WeatherApp',
      level: 500, // DEBUG level
    );
  }

  static void error(
    String message, {
    String? name,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      name: name ?? 'WeatherApp',
      level: 1200, // ERROR level
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void api(
    String message, {
    String? name,
    dynamic request,
    dynamic response,
    dynamic error,
  }) {
    dev.log(
      'API ${request != null ? 'Request' : 'Response'}: $message',
      name: name ?? 'WeatherApp.API',
      level: 800, // INFO level
      error: error,
    );
    
    if (request != null) {
      dev.log('Request: $request', name: 'WeatherApp.API');
    }
    if (response != null) {
      dev.log('Response: $response', name: 'WeatherApp.API');
    }
  }
}
