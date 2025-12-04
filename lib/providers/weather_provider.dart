import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/gemini_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final GeminiService _geminiService = GeminiService();

  WeatherData? _weatherData;
  String? _aiAnalysis;
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  WeatherData? get weatherData => _weatherData;
  String? get aiAnalysis => _aiAnalysis;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;

  Future<void> loadWeather() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current position
      _currentPosition = await _getCurrentPosition();
      
      if (_currentPosition != null) {
        // Load weather data
        _weatherData = await _weatherService.getAllWeatherData(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );

        // Get AI analysis
        if (_weatherData != null) {
          _aiAnalysis = await _geminiService.analyzeWeather(
            temperature: _weatherData!.current.temp,
            humidity: _weatherData!.current.humidity,
            description: _weatherData!.current.description,
            windSpeed: _weatherData!.current.windSpeed,
          );
        }
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _error = 'Les services de localisation sont désactivés.';
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _error = 'Permission de localisation refusée.';
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _error = 'Permission de localisation définitivement refusée.';
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> refreshWeather() async {
    await loadWeather();
  }

  String getWeatherIconUrl(String iconCode) {
    return _weatherService.getIconUrl(iconCode);
  }
}
