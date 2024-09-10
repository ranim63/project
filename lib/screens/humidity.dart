// Import necessary libraries and packages.
import 'package:a/mqtt_m.dart';
import 'homescreen.dart'; 
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; 
import 'package:intl/intl.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

// Define a StatefulWidget to handle humidity data visualization.
class HumidityScreen extends StatefulWidget {
  const HumidityScreen({super.key});

  @override
  _HumidityScreenState createState() => _HumidityScreenState();
}

class _HumidityScreenState extends State<HumidityScreen> {
  // Initialize MQTT client wrapper.
  final MQTTClientWrapper _mqttClient = MQTTClientWrapper();
  // List to hold chart data.
  List<ChartData> _data = [];
  // Variable to hold the current humidity reading.
  double _currentReading = 0;

  @override
  void initState() {
    super.initState();
    _initializeMqttClient(); // Initialize the MQTT client.
    _loadData(); // Load previously saved data.
  }

  // Method to initialize MQTT client and subscribe to a topic.
  Future<void> _initializeMqttClient() async {
    try {
      await _mqttClient.prepareMqttClient();
      _mqttClient.subscribeToTopic('ESP32/humidity'); 
      _mqttClient.onMessageReceived = (message) {
        try {
          final double reading = double.parse(message); 
          setState(() {
            _currentReading = reading;
            _data.add(ChartData(DateTime.now().toLocal(), _currentReading));
            if (_data.length > 20) _data.removeAt(0);
            _saveData(); 
          });
        } catch (e) {
          print('Error parsing message: $e');
        }
      };
    } catch (e) {
      print('Error initializing MQTT client: $e');
    }
  }

  // Method to save data locally using SharedPreferences.
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> dataStrings = _data
        .map((e) => '${e.time.toIso8601String()},${e.value}')
        .toList();
    await prefs.setStringList('humidity_data', dataStrings);
  }

  // Method to load saved data from local storage.
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? dataStrings = prefs.getStringList('humidity_data');
    if (dataStrings != null) {
      setState(() {
        _data = dataStrings
            .map((e) {
              final parts = e.split(',');
              return ChartData(
                DateTime.parse(parts[0]),
                double.parse(parts[1]),
              );
            })
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Humidity'), 
      ),
      body: Column(
        children: [
          Expanded(
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat('HH:mm:ss'),
              ),
              primaryYAxis: NumericAxis(),
              series: <CartesianSeries>[
                LineSeries<ChartData, DateTime>(
                  dataSource: _data,
                  xValueMapper: (ChartData data, _) => data.time,
                  yValueMapper: (ChartData data, _) => data.value,
                ),
              ],
            ),
          ),
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
    );
  }
}

// Data model class for chart data.
class ChartData {
  ChartData(this.time, this.value);
  final DateTime time;  // Time of the reading.
  final double value;   // Humidity value.
}
