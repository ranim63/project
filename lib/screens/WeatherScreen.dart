// Import necessary libraries and packages.
import 'package:a/mqtt_m.dart';
import 'package:a/screens/homescreen.dart';
import 'package:flutter/material.dart';

// Define a StatefulWidget to handle weather data visualization.
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Initialize MQTT client wrapper.
  final MQTTClientWrapper _mqttClient = MQTTClientWrapper();
  // Variable to hold the current temperature reading.
  double _currentTemperature = 0;
  // Variable to hold the weather status.
  String _weatherStatus = 'loading';
  // Variable to hold the path of the weather image.
  String _imagePath = 'assets/images/Weather.png'; 

  @override
  void initState() {
    super.initState();
    _initializeMqttClient(); // Initialize the MQTT client.
  }

  // Method to initialize MQTT client and subscribe to a topic.
  Future<void> _initializeMqttClient() async {
    try {
      await _mqttClient.prepareMqttClient();
      _mqttClient.subscribeToTopic('ESP32/temperature'); 
      _mqttClient.onMessageReceived = (message) {
        try {
          final double reading = double.parse(message); 
          setState(() {
            _currentTemperature = reading; 
            _weatherStatus = _getWeatherStatus(_currentTemperature); 
            _imagePath = _getImagePath(_weatherStatus); 
          });
        } catch (e) {
          print('Error parsing message: $e');
        }
      };
    } catch (e) {
      print('Error initializing MQTT client: $e');
    }
  }

  // Method to determine the weather status based on the temperature.
  String _getWeatherStatus(double temperature) {
    if (temperature < 15) {
      return 'Cold';
    } else if (temperature < 25) {
      return 'Warm';
    } else {
      return 'Hot';
    }
  }

  // Method to get the image path based on the weather status.
  String _getImagePath(String weatherStatus) {
    switch (weatherStatus) {
      case 'Cold':
        return 'assets/images/cold.png';
      case 'Warm':
        return 'assets/images/warm.png';
      case 'Hot':
        return 'assets/images/hot.png';
      default:
        return 'assets/images/Weather.png'; 
    }
  }
  // Build method to define the UI of the WeatherScreen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'), 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(_imagePath, width: 300, height: 300), 
            SizedBox(height: 20),
            Text(
              'Current Temperature: $_currentTemperature°C',
              style: TextStyle(fontSize: 24), 
            ),
            SizedBox(height: 20),
            Text(
              'Weather Status: $_weatherStatus',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), 
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: const Text('Go to HomePage View'),
            ),
          ],
        ),
      ),
    );
  }
}
