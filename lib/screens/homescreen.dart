// Import necessary libraries and packages.
import 'dart:async';
import 'package:a/screens/deleteacc.dart';
import 'package:a/screens/humidity.dart';
import 'package:a/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "temp.dart";
import 'WeatherScreen.dart';
import 'package:a/led.dart';
import 'package:a/door.dart';
import 'package:a/window.dart';
import 'package:a/mqtt_m.dart';

// Define a StatefulWidget for the HomeScreen which serves as the main screen.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  // Initialize an instance of MQTTClientWrapper to handle MQTT connections.
  final MQTTClientWrapper mqttClient = MQTTClientWrapper();

  // Variables to track the state of warnings and incorrect attempts.
  bool warningShown1 = false;
  bool warningShown2 = false;
  int wrongAttempts = 0;

  // Initialize the Flutter local notifications plugin.
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the state of the screen, setting up notifications and MQTT client.
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _setupMqttClient();
  }

  // Method to initialize notifications.
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    print('Notification channel created');
  }

  // Method to set up the MQTT client and subscribing to topics and handling messages.
  Future<void> _setupMqttClient() async {
    await mqttClient.prepareMqttClient();
    mqttClient.subscribeToTopic('sensor/flame'); 
    mqttClient.subscribeToTopic('ESP32/alarm'); 
    mqttClient.onMessageReceived = (message) {
      print('Received message: $message');
      final parts = message.split(':');
      if (parts.length == 2) {
        final topic = parts[0];
        final payload = parts[1];

        print('Topic: $topic, Payload: $payload');
        if (topic == 'sensor/flame') {
          final value = int.tryParse(payload);
          if (value != null) {
            print('Parsed value: $value');
            
            if (value < 300 && !warningShown1) {
              print('Triggering fire alarm notification');
              _showLocalNotification('Fire detected! Alarm!!');
              setState(() {
                warningShown1 = true;
              });
            } else if (value <= 300 && warningShown1) {
              setState(() {
                warningShown1 = false;
              });
            }
          } else {
            print('Failed to parse value from payload: $payload');
          }
        } 
        else if (topic == 'ESP32/alarm' && payload == 'Too many incorrect password attempts!Allarm!!!') {
          print('Triggering incorrect password notification');
          _showLocalNotification('Incorrect password entered more than three times!');
        }
      } else {
        print('Message format is incorrect: $message');
      }
    };
  }

  // Method to show a local notification with a given message.
  Future<void> _showLocalNotification(String message) async {
    print('Showing notification: $message');
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Warning',
      message,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  // Build method to define the UI of the HomeScreen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(254, 254, 253, 0.659),
              Color.fromARGB(68, 0, 0, 0),
              Color.fromARGB(255, 0, 0, 0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WeatherScreen()),
                );
              },
              child: const Text('Go to Weather Page'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: Text("Navigate to LED"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LedControlPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: Text("Navigate to door"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ServoControlPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Servo2ControlPage()),
                );
              },
              child: const Text('window'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TemperatureScreen()),
                );
              },
              child: const Text('temperature graph'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HumidityScreen()),
                );
              },
              child: const Text('humidity graph'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              child: const Text('LOGOUT'),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DeleteAccountScreen()),
                );
              },
              child: const Text('delete account'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
