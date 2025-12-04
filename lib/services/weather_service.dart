import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../config/constants.dart';

class WeatherService {
  final String _apiKey = AppConstants.openWeatherApiKey;
  final String _baseUrl = AppConstants.openWeatherBaseUrl;

  // Current Weather
  Future<CurrentWeather> getCurrentWeather(double lat, double lon) async {
    final url = '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=fr';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return CurrentWeather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors du chargement de la météo');
    }
  }

  // 5-Day Forecast
  Future<List<ForecastItem>> getForecast(double lat, double lon) async {
    final url = '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=fr';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> list = data['list'];
      return list.map((item) => ForecastItem.fromJson(item)).toList();
    } else {
      throw Exception('Erreur lors du chargement des prévisions');
    }
  }

  // Air Pollution
  Future<AirPollution> getAirPollution(double lat, double lon) async {
    final url = '$_baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$_apiKey';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return AirPollution.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors du chargement de la qualité de l\'air');
    }
  }

  // UV Index (via One Call API 3.0)
  Future<UVIndex?> getUVIndex(double lat, double lon) async {
    // Note: UV Index requires One Call API 3.0 subscription
    // This is a simplified version
    try {
      final url = 'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,daily&appid=$_apiKey';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['current'] != null && data['current']['uvi'] != null) {
          return UVIndex(
            value: (data['current']['uvi'] as num).toDouble(),
            dateTime: DateTime.now(),
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Weather Alerts (via One Call API 3.0)
  Future<List<WeatherAlert>> getWeatherAlerts(double lat, double lon) async {
    try {
      final url = 'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude=minutely,hourly,daily,current&appid=$_apiKey';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['alerts'] != null) {
          return (data['alerts'] as List)
              .map((alert) => WeatherAlert.fromJson(alert))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get City Name from coordinates
  Future<Map<String, String>> getCityName(double lat, double lon) async {
    final url = 'https://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lon&limit=1&appid=$_apiKey';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        return {
          'city': data[0]['name'] ?? 'Inconnu',
          'country': data[0]['country'] ?? '',
        };
      }
    }
    return {'city': 'Inconnu', 'country': ''};
  }

  // Get All Weather Data
  Future<WeatherData> getAllWeatherData(double lat, double lon) async {
    final results = await Future.wait([
      getCurrentWeather(lat, lon),
      getForecast(lat, lon),
      getAirPollution(lat, lon),
      getUVIndex(lat, lon),
      getWeatherAlerts(lat, lon),
      getCityName(lat, lon),
    ]);

    return WeatherData(
      current: results[0] as CurrentWeather,
      forecast: results[1] as List<ForecastItem>,
      airPollution: results[2] as AirPollution,
      uvIndex: results[3] as UVIndex?,
      alerts: results[4] as List<WeatherAlert>,
      cityName: (results[5] as Map<String, String>)['city']!,
      country: (results[5] as Map<String, String>)['country']!,
    );
  }

  // Get weather icon URL
  String getIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@4x.png';
  }
}