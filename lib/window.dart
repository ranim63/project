import 'package:a/mqtt_m.dart';
import 'package:flutter/material.dart';
//create the page to control the window screen
class Servo2ControlPage extends StatefulWidget {
  const Servo2ControlPage({super.key});

  @override
  _Servo2ControlPageState createState() => _Servo2ControlPageState();
}

class _Servo2ControlPageState extends State<Servo2ControlPage> {
  final MQTTClientWrapper mqttClientWrapper = MQTTClientWrapper();

  @override
  void initState() {
    super.initState();
    mqttClientWrapper.prepareMqttClient();//to connect with the mqtt
  }

  @override
  void dispose() {
    mqttClientWrapper.client.disconnect(); // Disconnect when the widget is disposed
    super.dispose();
  }
//publish the message to mqtt when pressing the open and close buttons to control the window
  void publishMessage(String message) {
    mqttClientWrapper.publishMessage('ESP32/servo2', message);
    print('Published message: $message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 181, 253),
        title: const Text('window control'),
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
                publishMessage('open');
              },
              child: const Text('Open window'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                publishMessage('close');
              },
              child: const Text('Close window'),
            ),
          ],
        ),
      ),
    ));
  }
}
