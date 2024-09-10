import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';//imort mqtt service
import 'notification.dart'; // Import the notification service

class MQTTClientWrapper {
  late MqttServerClient client;
  Function(String)? onMessageReceived;

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  Future<void> prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();
    initializeNotifications(); // Initialize notifications
  }
// checking the username and password of the mqtt server
  Future<void> _connectClient() async {
    try {
      print('client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      await client.connect('Basmala', 'Basmala7');
    } on Exception catch (e) {
      print('client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
    //showing the user the state of the connection

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      print('client connected');
    } else {
      print(
          'ERROR client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }
//setting the cluster and user name
  void _setupMqttClient() {
    client = MqttServerClient.withPort(
        '1c09250875864dfdbf3ac2d89c79a141.s1.eu.hivemq.cloud',
        'Basmala',
        8883);
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }
//a function to subscribe a message from the mqtt
  void subscribeToTopic(String topicName) {
    print('Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      var message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('YOU GOT A NEW MESSAGE:');
      print(message);

      if (onMessageReceived != null) {
        onMessageReceived!(message);
      }

      // Filter messages before showing notifications
      _handleMessage(c[0].topic, message);
    });
  }
//making sure that the value published from this topic is less than 300 to send a notification 
//because this will indicate that there is a fire
  void _handleMessage(String topic, String message) {
    print('Handling message from topic: $topic');
    if (topic == 'sensor/flame') {
      final value = int.tryParse(message);
      if (value != null) {
        print('Parsed value: $value');
        if (value < 300) {
          print('Triggering fire alarm notification');
          showNotification('Fire detected! Alarm!!');
        }
      } else {
        print('Failed to parse value from payload: $message');
      }
    } else if (topic == 'ESP32/alarm' && message == 'Too many incorrect password attempts!Allarm!!!') {
      print('Triggering incorrect password notification');
      showNotification('Incorrect password entered more than three times!');
    } else {
      print('Ignoring message from topic: $topic');
    }
  }

  void publishMessage(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    print('Publishing message "$message" to topic $topic');
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  void _onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void _onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print('OnConnected client callback - Client connection was successful');
  }
}

// Enum representing the current connection state of the MQTT client
enum MqttCurrentConnectionState {
  IDLE,                
  CONNECTING,          
  CONNECTED,           
  DISCONNECTED,        
  ERROR_WHEN_CONNECTING // An error occurred while attempting to connect
}

// Enum representing the subscription state of the MQTT client
enum MqttSubscriptionState {
  IDLE,                // The client is not subscribed to any topics
  SUBSCRIBED           // The client is subscribed to one or more topics
}
