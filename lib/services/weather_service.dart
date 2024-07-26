import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  // ignore: constant_identifier_names
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<Weather> getWeather(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL?q=$cityName&appid=$apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        final errorBody = jsonDecode(response.body);
        print('Error from API: ${errorBody["cod"]} - ${errorBody["message"]}');
        throw Exception(
            'Error from API: ${errorBody["cod"]} - ${errorBody["message"]}');
      }
    } catch (e) {
      print('Failed to load weather data: $e');
      throw Exception('Failed to load weather data: $e');
    }
  }

  Future<String> getCurrentCity() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      String? city = placemarks[0].locality;
      if (city == null || city.isEmpty) {
        throw Exception('Unable to determine city name from location');
      }

      return city;
    } catch (e) {
      print('Failed to get current city: $e');
      throw Exception('Failed to get current city: $e');
    }
  }
}
