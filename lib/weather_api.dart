import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApi {
  final String apiKey = '619a5c54a4834ff687a203701241812';
  final String baseUrl = 'http://api.weatherapi.com/v1/';

  Future<Map<String, dynamic>> getCurrentWeather(String city) async {
    final response = await http.get(Uri.parse('$baseUrl/current.json?key=$apiKey&q=$city'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
  Future<Map<String, dynamic>> getForecast(String city) async {
    final response = await http.get(Uri.parse('$baseUrl/forecast.json?key=$apiKey&q=$city&days=4'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
}
