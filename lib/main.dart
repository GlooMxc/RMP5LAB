import 'package:flutter/material.dart';
import 'weather_api.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String selectedCity = 'Москва';
  late Future<Map<String, dynamic>> currentWeather;
  late Future<Map<String, dynamic>> forecastWeather;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru', null);
    _updateWeatherData();
  }

  void _updateWeatherData() {
    currentWeather = WeatherApi().getCurrentWeather(selectedCity);
    forecastWeather = WeatherApi().getForecast(selectedCity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Прогноз погоды'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: selectedCity,
                decoration: InputDecoration(
                  labelText: 'Выберите город',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                items: ['Москва', 'Сургут', 'Екатеринбург', 'Ханты-Мансийск', 'Токио','Берлин']
                    .map<DropdownMenuItem<String>>((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (String? newCity) {
                  setState(() {
                    selectedCity = newCity!;
                    _updateWeatherData();
                  });
                },
              ),
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: currentWeather,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  var weatherData = snapshot.data!;
                  var temperature = weatherData['current']['temp_c'];
                  var condition = weatherData['current']['condition']['text'];
                  var iconUrl = 'https:${weatherData['current']['condition']['icon']}';

                  return Card(
                    margin: EdgeInsets.all(16.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Текущая погода в $selectedCity',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Image.network(iconUrl, width: 80),
                          SizedBox(height: 10),
                          Text(
                            '$temperature°C',
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            condition,
                            style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(child: Text('Нет информации'));
                }
              },
            ),
            FutureBuilder<Map<String, dynamic>>(
              future: forecastWeather,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  var forecastData = snapshot.data!['forecast']['forecastday'];
                  var today = DateTime.now();

                  // Исключаем текущий день
                  var filteredForecast = forecastData.where((forecast) {
                    var forecastDate = DateTime.parse(forecast['date']);
                    return forecastDate.isAfter(today);
                  }).toList();

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: filteredForecast.map<Widget>((forecast) {
                        var date = DateFormat.yMMMMd('ru').format(DateTime.parse(forecast['date']));
                        var maxTemp = forecast['day']['maxtemp_c'];
                        var minTemp = forecast['day']['mintemp_c'];
                        var condition = forecast['day']['condition']['text'];
                        var iconUrl = 'https:${forecast['day']['condition']['icon']}';

                        return Card(
                          margin: EdgeInsets.only(bottom: 12.0),
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            leading: Image.network(iconUrl, width: 50),
                            title: Text(
                              date,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '$condition\nМакс: $maxTemp°C / Мин: $minTemp°C',
                              style: TextStyle(height: 1.5),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                } else {
                  return Center(child: Text('Нет информации о прогнозе'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
