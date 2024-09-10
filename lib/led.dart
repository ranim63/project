//import the important packages
import 'package:a/mqtt_m.dart';
import 'package:flutter/material.dart';

class LedControlPage extends StatefulWidget {
  const LedControlPage({super.key});

  @override
  _LedControlPage createState() => _LedControlPage();
}

class _LedControlPage extends State<LedControlPage> {
  final MQTTClientWrapper mqttClientWrapper = MQTTClientWrapper();

  @override
  void initState() {
    super.initState();
    mqttClientWrapper.prepareMqttClient();//to intialize the connection with mqtt
  }

  @override
  void dispose() {
    mqttClientWrapper.client.disconnect(); // Disconnect when the widget is disposed
    super.dispose();
  }
//when pressing the led button publish the message to mqtt
  void publishMessage(String message) {
    mqttClientWrapper.publishMessage('home/led', message);
    print('Published message: $message');
  }


  @override

// This widget builds the main screen of the LED Control app.
// The body of the Scaffold contains a Container that takes up the full width and height of the screen.
// The Container has a gradient background decoration.

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 235, 199, 228),
        title: const Text('LED Control'),
      ),
      body: Container(
         width: MediaQuery.of(context).size.width,
      height:  MediaQuery.of(context).size.height,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  publishMessage('1');
                },
                child: const Text('Turn LED On'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  publishMessage('0');
                },
                child: const Text('Turn LED Off'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
