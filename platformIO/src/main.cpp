#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <Keypad.h>
#include <ESP32Servo.h>
#include <NewPing.h>
#include <DHT.h>
#include <WiFi.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>

// MQTT credentials and server settings
const char* mqtt_username = "Basmala";  // MQTT username
const char* mqtt_password = "Basmala7";  // MQTT password
const char* mqtt_server_secure = "1c09250875864dfdbf3ac2d89c79a141.s1.eu.hivemq.cloud";  // MQTT server address
const int mqtt_port_secure = 8883;  // MQTT secure port

WiFiClientSecure espClient;  // Secure WiFi client for MQTT
PubSubClient client(espClient);  // MQTT client

// Root CA for secure MQTT connection
static const char *root_ca PROGMEM =
 R"EOF(
-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
-----END CERTIFICATE-----
)EOF";
// LCD and Keypad setup
LiquidCrystal_I2C lcd(0x27, 16, 2);  // Initialize the LCD with I2C address 0x27 and 16x2 display
const byte ROWS = 4;  // Number of rows in the keypad
const byte COLS = 4;  // Number of columns in the keypad
char keys[ROWS][COLS] = {
  {'1', '2', '3', 'A'},  // Keypad layout
  {'4', '5', '6', 'B'},
  {'7', '8', '9', 'C'},
  {'*', '0', '#', 'D'}
};
byte rowPins[ROWS] = {19, 18, 5, 17};  // Pins connected to the rows of the keypad
byte colPins[COLS] = {16, 4, 0, 2};  // Pins connected to the columns of the keypad
Keypad keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);  // Initialize the keypad

// Servo setup
Servo myServo;  // Servo object for flame detection
Servo secondServo;  // Servo object for rain detection
const int servoPin = 14;  // Pin connected to the flame detection servo
const int rainServoPin = 15;  // Pin connected to the rain detection servo

// Relay setup
const int relayPin = 13;  // Pin connected to the relay

// Buzzer setup
const int buzzerPin = 12;  // Pin connected to the buzzer
const int buzzerFrequency = 1000;  // Frequency for the buzzer
const int maxAttempts = 3;  // Maximum number of password attempts allowed
int attemptCount = 0;  // Counter for the number of attempts

// LDR setup
const int ldrPin = 34;  // Pin connected to the LDR (Light Dependent Resistor)
const int ldrThreshold = 500;  // Threshold value for LDR to detect flame

// LED setup
const int ledPin = 25;  // Pin connected to the LED

// Ultrasonic Sensor setup
const int triggerPin = 27;  // Pin connected to the trigger of the ultrasonic sensor
const int echoPin = 33;  // Pin connected to the echo of the ultrasonic sensor
const int maxDistance = 200;  // Maximum distance to measure with the ultrasonic sensor
NewPing sonar(triggerPin, echoPin, maxDistance);  // Initialize the ultrasonic sensor

// DHT11 setup
#define DHTPIN 23  // Pin connected to the DHT11 sensor
#define DHTTYPE DHT11  // Type of DHT sensor
DHT dht(DHTPIN, DHTTYPE);  // Initialize the DHT11 sensor

// NTP Client setup
const char* ssid = "Wokwi-GUEST";  // WiFi network SSID
const char* wifiPassword = "";  // WiFi network password
WiFiUDP ntpUDP;  // UDP object for NTP
NTPClient timeClient(ntpUDP, "asia.pool.ntp.org", 3600 * 2);  // NTP client to fetch the time

// Flame Sensor setup
const int flamePin = 35;  // Pin connected to the flame sensor
const int flameThreshold = 300;  // Threshold value for flame detection
const unsigned long flameDelayTime = 2000;  // Delay time after detecting a flame

// Rain Sensor setup
const int rainSensorPin = 32;  // Pin connected to the rain sensor
const int rainThreshold = 300;  // Threshold value for rain detection
bool rainDetected = false;  // Flag to indicate if rain is detected

// Password
const String correctPassword = "1234";  // Correct password for accessing the system
String enteredPassword = "";  // String to store the entered password

// Flags
bool passwordEntered = false;  // Flag to indicate if the correct password is entered
unsigned long passwordEntryTime = 0;  // Time when the password was entered
const unsigned long displayDuration = 5000;  // Duration to display a message after entering the password

// Keypad timing
unsigned long lastKeypadCheck = 0;  // Last time the keypad was checked
const unsigned long keypadInterval = 100;  // Interval to check the keypad (every 100 ms)

// MQTT topics
const char* alarmTopic = "ESP32/alarm";  // MQTT topic for alarm notifications
const char* rainSensorTopic = "sensor/rain";  // MQTT topic for rain sensor data

// Function to publish alarm notifications to the MQTT broker
void publishAlarmNotification() {
  String alarmMessage = "Too many incorrect password attempts!Alarm!!!";
  if (client.publish(alarmTopic, alarmMessage.c_str())) {
    Serial.println("Alarm notification sent successfully.");
  } else {
    Serial.println("Failed to send alarm notification.");
  }
}

// Function to trigger the alarm (activate buzzer)
void triggerAlarm() {
  Serial.println("Triggering alarm!");  // Debug print to check if function is called
  digitalWrite(buzzerPin, HIGH);  // Turn on the buzzer
  tone(buzzerPin, buzzerFrequency);  // Start the buzzer at the specified frequency
  delay(1000);  // Keep the buzzer on for the specified delay time
  noTone(buzzerPin);  // Stop the buzzer after the delay
  digitalWrite(buzzerPin, LOW);  // Ensure buzzer is off after delay
}

// Function to check the keypad for password entry
void checkKeypad() {
  if (millis() - lastKeypadCheck >= keypadInterval) {
    lastKeypadCheck = millis();
    
    char key = keypad.getKey();  // Get the key pressed on the keypad
    
    if (key) {
      Serial.println(key);  // Print the pressed key for debugging
      if (key == '#') {  // '#' is used to submit the entered password
        if (enteredPassword == correctPassword) {
          passwordEntered = true;
          attemptCount = 0;
          lcd.clear();
          lcd.print("Access Granted");
          myServo.write(90);  // Open the door or perform some action
          delay(2000);  // You could replace this with millis-based timing
          myServo.write(0);
        } else {
          lcd.clear();
          lcd.print("Wrong Password");
          attemptCount++;
          if (attemptCount >= maxAttempts) {
            triggerAlarm();  // Trigger alarm if maximum attempts are exceeded
            Serial.println("Too many attempts");
            publishAlarmNotification();  // Send alarm notification
          }
        }
        enteredPassword = "";  // Reset the entered password
      } else if (key == '*') {  // '*' is used to clear the entered password
        enteredPassword = "";  // Clear the entered password
        lcd.clear();
      } else {
        enteredPassword += key;  // Append the key to the entered password
        lcd.clear();
        lcd.print("Enter Password:");
        lcd.setCursor(0, 1);
        for (int i = 0; i < enteredPassword.length(); i++) {
          lcd.print('*');  // Display '*' for each character in the password
        }
      }
    }
  }
}

// Function to check the flame sensor and take action if flame is detected
void checkFlameSensor() {
  int flameValue = analogRead(flamePin);  // Read the flame sensor value
        
  if (flameValue < flameThreshold) {
    tone(buzzerPin, 1000);  // Start the buzzer at 1000 Hz
    secondServo.write(0);  // Perform the action, e.g., closing a window
    digitalWrite(relayPin, HIGH);  // Activate the relay
    delay(flameDelayTime);  // Keep the buzzer on for the specified delay time
    void triggerAlarm();  // Call triggerAlarm function
    digitalWrite(relayPin, LOW);  // Deactivate the relay
  } else {
    noTone(buzzerPin);  // Stop the buzzer if no flame is detected
    digitalWrite(relayPin, LOW);  // Ensure the relay is off
  }
}

void checkMotionAndLDR() {
  int distance = sonar.ping_cm();  // Get distance from ultrasonic sensor
  int ldrValue = analogRead(ldrPin);  // Read LDR sensor value

  if (distance > 0 && distance < 100) { // Detect motion within 100 cm
    if (ldrValue >ldrThreshold) {  // If LDR value is below the threshold
      digitalWrite(ledPin, HIGH); // Turn on the light
    } else {
      digitalWrite(ledPin, LOW); // Turn off the light
    }
  } else {
    digitalWrite(ledPin, LOW); // Turn off the light if no motion is detected
  }
}

// Function to publish DHT11 data to MQTT
void publishDHT11Data() {
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  if (isnan(humidity) || isnan(temperature)) {  // Check if readings are valid
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  // Map temperature to servo angle and publish temperature, humidity, and weather condition to MQTT
  int angle = map(temperature, 0, 50, 0, 180);
  client.publish("ESP32/temperature", String(temperature).c_str());
  client.publish("ESP32/humidity", String(humidity).c_str());

  String weatherCondition;
  if (temperature > 30) {
    weatherCondition = "Hot";
  } else if (temperature > 20) {
    weatherCondition = "Warm";
  } else {
    weatherCondition = "Cold";
  }
  client.publish("ESP32/weather", weatherCondition.c_str());
}

// Function to publish rain sensor data to MQTT
void publishRainSensorData() {
  int rainValue = analogRead(rainSensorPin);  // Read the rain sensor value
  String message = String(rainValue);  // Convert the rain value to a string

  // Publish the rain detection message to the MQTT broker
  if (client.publish(rainSensorTopic, message.c_str())) {
    // Success handling can be added here if needed
  } else {
    Serial.println("Failed to publish Rain sensor data.");
  }
}

// Function to publish flame sensor data to MQTT
void publishFlameSensorData() {
  int flameValue = analogRead(flamePin);  // Read the flame sensor value
  String flameData = String(flameValue);  // Convert the flame value to a string
  client.publish("sensor/flame", flameData.c_str());
}

// Function to reconnect to MQTT broker
void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection… ");
    String clientId = "ESP32Client";
    if (client.connect(clientId.c_str(), mqtt_username, mqtt_password)) {
      Serial.println("connected!");

      // Resubscribe to necessary topics and publish initial sensor data
      client.subscribe("home/led"); 
      client.subscribe("ESP32/servo");
      client.subscribe("ESP32/servo2");
      publishDHT11Data();
      publishFlameSensorData();
      publishRainSensorData();
    } else {
      Serial.print("failed, rc = ");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

// MQTT callback function to handle incoming messages
void callback(char* topic, byte* message, unsigned int length) {
  String msg;
  for (int i = 0; i < length; i++) {
    msg += (char)message[i];
  }
  Serial.print("Message received: ");
  Serial.println(msg);

  // Handle the received messages and control devices accordingly
  if (strcmp(topic, "home/led") == 0) {
    digitalWrite(ledPin, (message[0] == '1') ? HIGH : LOW);
  } 
  else if (strcmp(topic, "ESP32/servo") == 0) {
    myServo.write((strncmp((char*)message, "open", length) == 0) ? 180 : 0);
  } 
  else if (strcmp(topic, "ESP32/servo2") == 0) {
    secondServo.write((strncmp((char*)message, "open", length) == 0) ? 180 : 0);
  }
}

// Function to publish rain detection data
void publishRainDetection(int rainValue) {
  String rainData = String(rainValue);
  client.publish(rainSensorTopic, rainData.c_str());
}

// Function to check the rain sensor and take appropriate action
void checkRainSensor() {
  int rainValue = analogRead(rainSensorPin);

  if (rainValue < rainThreshold && !rainDetected) {
    // If rain is detected and not yet flagged, publish data and activate servo/relay
    publishRainDetection(rainValue);
    secondServo.write(90); // Perform the action like closing a window
    digitalWrite(relayPin, HIGH); // Activate the relay
    rainDetected = true;   // Set the flag to true to prevent further movement
  } else if (rainValue >= rainThreshold && rainDetected) {
    // Reset the servo and the flag only if rain is not detected anymore
    secondServo.write(0);
    digitalWrite(relayPin, LOW); // Deactivate the relay
  }
}

// Setup function to initialize the system
void setup() {
  Serial.begin(115200);  // Start the serial communication
  lcd.init();  // Initialize the LCD
  lcd.backlight();  // Turn on the LCD backlight
  
  myServo.attach(servoPin);  // Attach the servo motor to the pin
  myServo.write(0);  // Set the initial position

  secondServo.attach(rainServoPin);  // Attach the second servo motor to the pin
  secondServo.write(0);  // Set the initial position

  pinMode(buzzerPin, OUTPUT);  // Set buzzer pin as output
  digitalWrite(buzzerPin, LOW);  // Turn off the buzzer

  pinMode(ledPin, OUTPUT);  // Set LED pin as output
  digitalWrite(ledPin, LOW);  // Turn off the LED

  dht.begin();  // Start the DHT11 sensor

  // Connect to WiFi
  WiFi.begin(ssid, wifiPassword);
  Serial.print("Connecting");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("Connected to WiFi");

  // Setup MQTT client
  espClient.setCACert(root_ca);
  client.setServer(mqtt_server_secure, mqtt_port_secure);
  client.setCallback(callback);

  // Subscribe to topics for controlling devices
  client.subscribe("ESP32/servo");
  client.subscribe("ESP32/servo2");
  client.subscribe("home/led");

  timeClient.begin();  // Start the time client
}

// Main loop function

void loop() {
  // Reconnect to MQTT broker if disconnected
  if (!client.connected()) {
    reconnect();
  }
  client.loop();  // Maintain MQTT connection

  // Check input from the keypad and various sensors
  checkKeypad();
  checkFlameSensor();
  checkRainSensor();
  checkMotionAndLDR();

  // Publish sensor data to MQTT topics
  publishDHT11Data();      // Publish DHT11 sensor data (Temperature & Humidity)
  publishFlameSensorData(); // Publish Flame sensor data
}




