class CurrentWeather {
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final String description;
  final String icon;
  final String main;
  final int visibility;
  final int clouds;
  final DateTime sunrise;
  final DateTime sunset;

  CurrentWeather({
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.description,
    required this.icon,
    required this.main,
    required this.visibility,
    required this.clouds,
    required this.sunrise,
    required this.sunset,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temp: (json['main']['temp'] ?? 0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      pressure: json['main']['pressure'] ?? 0,
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      main: json['weather'][0]['main'] ?? '',
      visibility: json['visibility'] ?? 0,
      clouds: json['clouds']['all'] ?? 0,
      sunrise: DateTime.fromMillisecondsSinceEpoch(
          (json['sys']['sunrise'] ?? 0) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(
          (json['sys']['sunset'] ?? 0) * 1000),
    );
  }
}

class ForecastItem {
  final DateTime dateTime;
  final double temp;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final String description;
  final String icon;
  final double windSpeed;
  final double pop; // Probability of precipitation

  ForecastItem({
    required this.dateTime,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.pop,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      temp: (json['main']['temp'] ?? 0).toDouble(),
      tempMin: (json['main']['temp_min'] ?? 0).toDouble(),
      tempMax: (json['main']['temp_max'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '01d',
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      pop: (json['pop'] ?? 0).toDouble(),
    );
  }
}

class AirPollution {
  final int aqi;
  final double co;
  final double no;
  final double no2;
  final double o3;
  final double so2;
  final double pm2_5;
  final double pm10;
  final double nh3;

  AirPollution({
    required this.aqi,
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm2_5,
    required this.pm10,
    required this.nh3,
  });

  factory AirPollution.fromJson(Map<String, dynamic> json) {
    final list = json['list'][0];
    final components = list['components'];
    return AirPollution(
      aqi: list['main']['aqi'] ?? 1,
      co: (components['co'] ?? 0).toDouble(),
      no: (components['no'] ?? 0).toDouble(),
      no2: (components['no2'] ?? 0).toDouble(),
      o3: (components['o3'] ?? 0).toDouble(),
      so2: (components['so2'] ?? 0).toDouble(),
      pm2_5: (components['pm2_5'] ?? 0).toDouble(),
      pm10: (components['pm10'] ?? 0).toDouble(),
      nh3: (components['nh3'] ?? 0).toDouble(),
    );
  }

  String get aqiText {
    switch (aqi) {
      case 1:
        return 'Bon';
      case 2:
        return 'Correct';
      case 3:
        return 'Modéré';
      case 4:
        return 'Mauvais';
      case 5:
        return 'Très mauvais';
      default:
        return 'Inconnu';
    }
  }

  String get healthAdvice {
    switch (aqi) {
      case 1:
        return 'Qualité de l\'air idéale pour les activités extérieures.';
      case 2:
        return 'Qualité acceptable. Les personnes sensibles devraient limiter les efforts prolongés.';
      case 3:
        return 'Les personnes sensibles peuvent ressentir des effets. Limitez les activités intenses.';
      case 4:
        return 'Risques pour la santé. Évitez les activités extérieures prolongées.';
      case 5:
        return 'Alerte sanitaire. Restez à l\'intérieur autant que possible.';
      default:
        return '';
    }
  }
}

class UVIndex {
  final double value;
  final DateTime dateTime;

  UVIndex({
    required this.value,
    required this.dateTime,
  });

  factory UVIndex.fromJson(Map<String, dynamic> json) {
    return UVIndex(
      value: (json['value'] ?? 0).toDouble(),
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['date'] ?? 0)),
    );
  }

  String get level {
    if (value <= 2) return 'Faible';
    if (value <= 5) return 'Modéré';
    if (value <= 7) return 'Élevé';
    if (value <= 10) return 'Très élevé';
    return 'Extrême';
  }

  String get advice {
    if (value <= 2) {
      return 'Protection minimale requise.';
    } else if (value <= 5) {
      return 'Portez des lunettes de soleil. Utilisez une crème SPF 30+.';
    } else if (value <= 7) {
      return 'Réduisez l\'exposition entre 10h et 16h. Crème SPF 30+, chapeau et lunettes.';
    } else if (value <= 10) {
      return 'Évitez le soleil entre 10h et 16h. Protection maximale nécessaire.';
    }
    return 'Évitez toute exposition. Le soleil est dangereux.';
  }
}

class WeatherAlert {
  final String event;
  final String senderName;
  final DateTime start;
  final DateTime end;
  final String description;

  WeatherAlert({
    required this.event,
    required this.senderName,
    required this.start,
    required this.end,
    required this.description,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      event: json['event'] ?? '',
      senderName: json['sender_name'] ?? '',
      start: DateTime.fromMillisecondsSinceEpoch((json['start'] ?? 0) * 1000),
      end: DateTime.fromMillisecondsSinceEpoch((json['end'] ?? 0) * 1000),
      description: json['description'] ?? '',
    );
  }
}

class WeatherData {
  final CurrentWeather current;
  final List<ForecastItem> forecast;
  final AirPollution? airPollution;
  final UVIndex? uvIndex;
  final List<WeatherAlert> alerts;
  final String cityName;
  final String country;

  WeatherData({
    required this.current,
    required this.forecast,
    this.airPollution,
    this.uvIndex,
    this.alerts = const [],
    required this.cityName,
    required this.country,
  });
}