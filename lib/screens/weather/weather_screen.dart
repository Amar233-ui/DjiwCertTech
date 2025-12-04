import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/weather_card.dart';
import '../../widgets/loading_widget.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    final weather = Provider.of<WeatherProvider>(context, listen: false);
    if (weather.weatherData == null && !weather.isLoading) {
      weather.loadWeather();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherProvider>(
        builder: (context, weather, child) {
          if (weather.isLoading) {
            return const LoadingWidget(message: 'Chargement de la meteo...');
          }

          if (weather.error != null || weather.weatherData == null) {
            return _buildErrorView(weather);
          }

          return RefreshIndicator(
            onRefresh: () => weather.refreshWeather(),
            color: AppTheme.primaryGreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header with current weather
                  _buildCurrentWeather(weather),
                  
                  // Content
                  Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Weather details
                          FadeInUp(
                            child: _buildWeatherDetails(weather),
                          ),
                          const SizedBox(height: 24),
                          
                          // 5-day forecast
                          FadeInUp(
                            delay: const Duration(milliseconds: 100),
                            child: _buildForecast(weather),
                          ),
                          const SizedBox(height: 24),
                          
                          // Temperature chart
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: _buildTemperatureChart(weather),
                          ),
                          const SizedBox(height: 24),
                          
                          // Air quality
                          if (weather.weatherData!.airPollution != null)
                            FadeInUp(
                              delay: const Duration(milliseconds: 300),
                              child: AirQualityCard(
                                aqi: weather.weatherData!.airPollution!.aqi,
                                status: weather.weatherData!.airPollution!.aqiText,
                                advice: weather.weatherData!.airPollution!.healthAdvice,
                              ),
                            ),
                          const SizedBox(height: 24),
                          
                          // UV Index
                          if (weather.weatherData!.uvIndex != null)
                            FadeInUp(
                              delay: const Duration(milliseconds: 400),
                              child: _buildUVIndex(weather),
                            ),
                          const SizedBox(height: 24),
                          
                          // AI Analysis
                          if (weather.aiAnalysis != null)
                            FadeInUp(
                              delay: const Duration(milliseconds: 500),
                              child: _buildAIAnalysis(weather),
                            ),
                          
                          // Weather alerts
                          if (weather.weatherData!.alerts.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            FadeInUp(
                              delay: const Duration(milliseconds: 600),
                              child: _buildAlerts(weather),
                            ),
                          ],
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(WeatherProvider weather) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 80,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: 24),
            Text(
              weather.error ?? 'Erreur de chargement',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => weather.refreshWeather(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(WeatherProvider weather) {
    final current = weather.weatherData!.current;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppTheme.weatherGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FadeInLeft(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${weather.weatherData!.cityName}, ${weather.weatherData!.country}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, d MMMM', 'fr_FR').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FadeInRight(
                    child: IconButton(
                      onPressed: () => weather.refreshWeather(),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FadeInDown(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      weather.getWeatherIconUrl(current.icon),
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.cloud,
                          size: 100,
                          color: Colors.white,
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${current.temp.round()}°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                        Text(
                          'Ressenti ${current.feelsLike.round()}°',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              FadeInUp(
                child: Text(
                  current.description[0].toUpperCase() + current.description.substring(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetails(WeatherProvider weather) {
    final current = weather.weatherData!.current;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  icon: Icons.water_drop,
                  label: 'Humidite',
                  value: '${current.humidity}%',
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _DetailItem(
                  icon: Icons.air,
                  label: 'Vent',
                  value: '${current.windSpeed.round()} km/h',
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  icon: Icons.compress,
                  label: 'Pression',
                  value: '${current.pressure} hPa',
                  color: Colors.purple,
                ),
              ),
              Expanded(
                child: _DetailItem(
                  icon: Icons.visibility,
                  label: 'Visibilite',
                  value: '${(current.visibility / 1000).round()} km',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  icon: Icons.wb_sunny,
                  label: 'Lever',
                  value: DateFormat('HH:mm').format(current.sunrise),
                  color: Colors.amber,
                ),
              ),
              Expanded(
                child: _DetailItem(
                  icon: Icons.nightlight,
                  label: 'Coucher',
                  value: DateFormat('HH:mm').format(current.sunset),
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForecast(WeatherProvider weather) {
    final forecast = weather.weatherData!.forecast;
    
    // Group forecast by day
    final Map<String, List<dynamic>> dailyForecast = {};
    for (var item in forecast) {
      final day = DateFormat('yyyy-MM-dd').format(item.dateTime);
      if (!dailyForecast.containsKey(day)) {
        dailyForecast[day] = [];
      }
      dailyForecast[day]!.add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Previsions 5 jours',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dailyForecast.length.clamp(0, 5),
            itemBuilder: (context, index) {
              final day = dailyForecast.keys.elementAt(index);
              final items = dailyForecast[day]!;
              final avgTemp = items.fold<double>(0, (sum, item) => sum + item.temp) / items.length;
              final minTemp = items.fold<double>(100, (min, item) => item.tempMin < min ? item.tempMin : min);
              final maxTemp = items.fold<double>(-100, (max, item) => item.tempMax > max ? item.tempMax : max);
              final icon = items[items.length ~/ 2].icon;
              
              final date = DateTime.parse(day);
              final dayName = index == 0
                  ? "Auj."
                  : DateFormat('E', 'fr_FR').format(date).substring(0, 3);

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ForecastCard(
                  day: dayName,
                  iconUrl: weather.getWeatherIconUrl(icon),
                  tempMax: '${maxTemp.round()}°',
                  tempMin: '${minTemp.round()}°',
                  isSelected: index == 0,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureChart(WeatherProvider weather) {
    final forecast = weather.weatherData!.forecast.take(8).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temperature (24h)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}°',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < forecast.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('HH:mm').format(forecast[value.toInt()].dateTime),
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: forecast.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.temp);
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.primaryGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: AppTheme.primaryGreen,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUVIndex(WeatherProvider weather) {
    final uv = weather.weatherData!.uvIndex!;
    
    Color uvColor;
    if (uv.value <= 2) {
      uvColor = Colors.green;
    } else if (uv.value <= 5) {
      uvColor = Colors.yellow.shade700;
    } else if (uv.value <= 7) {
      uvColor = Colors.orange;
    } else if (uv.value <= 10) {
      uvColor = Colors.red;
    } else {
      uvColor = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: uvColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.wb_sunny,
                  color: uvColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Indice UV',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${uv.value.round()} - ${uv.level}',
                    style: TextStyle(
                      color: uvColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // UV scale
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [
                  Colors.green,
                  Colors.yellow,
                  Colors.orange,
                  Colors.red,
                  Colors.purple,
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('0', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              Text('3', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              Text('6', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              Text('9', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
              Text('11+', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            uv.advice,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysis(WeatherProvider weather) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withOpacity(0.1),
            AppTheme.primaryGreenLight.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Analyse IA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            weather.aiAnalysis!,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts(WeatherProvider weather) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              'Alertes meteo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...weather.weatherData!.alerts.map((alert) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.event,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    alert.description,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}