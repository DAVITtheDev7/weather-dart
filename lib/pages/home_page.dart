import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_weather_app/models/weather_model.dart';
import 'package:simple_weather_app/services/weather_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _weatherService = WeatherService('0cb2332fb9b4a1dfa724d08492caf21d');
  Weather? _weather;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      String cityName = await _weatherService.getCurrentCity();
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching weather data";
      });
      print(
          'Error fetching weather: $e'); // Add more detailed logging if needed
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloudy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thundery.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }

  Color _getBackgroundColor() {
    final now = DateTime.now();
    final sunrise = DateTime(now.year, now.month, now.day, 6);
    final sunset = DateTime(now.year, now.month, now.day, 19);

    return now.isAfter(sunrise) && now.isBefore(sunset)
        ? const Color.fromARGB(255, 190, 190, 190)
        : const Color.fromARGB(255, 28, 28, 28);
  }

  Color _getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _getBackgroundColor();
    Color textColor = _getTextColor(backgroundColor);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            if (_weather != null) ...[
              Text(
                _weather!.cityName,
                style: TextStyle(fontSize: 28, color: textColor),
              ),
              Lottie.asset(
                getWeatherAnimation(_weather!.mainCondition),
                width: 220,
                height: 220,
              ),
              Text(
                "${_weather!.temperature.round()}°C",
                style: TextStyle(fontSize: 48, color: textColor),
              ),
              Text(
                _weather!.mainCondition,
                style: TextStyle(fontSize: 18, color: textColor),
              ),
            ] else ...[
              const SizedBox(
                height: 30,
              ),
              CircularProgressIndicator(color: textColor),
            ],
          ],
        ),
      ),
    );
  }
}
