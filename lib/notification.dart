import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//instance of FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// to initialize notifications
void initializeNotifications() {
  
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  
  // General initialization settings for all platforms
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // Initialize the plugin with the settings
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Function to show a notification with a given message
Future<void> showNotification(String message) async {
  
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'your_channel_id', 'your_channel_name', 
          channelDescription: 'your_channel_description',
          importance: Importance.max, priority: Priority.high, showWhen: false);

  // General notification details for all platforms
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  // Show the notification with the specified details
  await flutterLocalNotificationsPlugin.show(
    0, 'New MQTT Message', message, platformChannelSpecifics,
    payload: 'item x');
}
