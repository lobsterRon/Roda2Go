#include <WiFi.h>
#include <WebSocketsClient.h>

WebSocketsClient webSocket;

const char* ssid = "HUAWEI P20 Pro";
const char* password = "ron041228";
const char* serverHost = "192.168.43.33";  // Node.js server IP
const int serverPort = 3000;

const int buttonPin = 9;  // BOOT button on ESP32 (GPIO0)

volatile bool buttonPressed = false;
volatile int currentState = HIGH;
unsigned long lastInterrupt = 0;

void IRAM_ATTR handleButton() {
  unsigned long now = millis();
  if (now - lastInterrupt > 150) {
    currentState = digitalRead(buttonPin);
    buttonPressed = true;
    lastInterrupt = now;
  }
}

void setup() {
  Serial.begin(115200);

  pinMode(buttonPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(buttonPin), handleButton, CHANGE);

  WiFi.begin(ssid, password);
  Serial.println("Connecting to WiFi...");

  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(".");
  }

  Serial.println("\nWiFi connected!");
  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.localIP());

  // Connect to WebSocket server
  webSocket.begin(serverHost, serverPort, "/");
  webSocket.onEvent(webSocketEvent);
  webSocket.setReconnectInterval(5000);
}

void loop() {
  webSocket.loop();

  if (buttonPressed) {
    buttonPressed = false;

    String status = (currentState == LOW) ? "Charging" : "Available";

    String json = "{\"chargerId\":\"GENTARI_UTP01\",\"status\":\"" + status + "\"}";

    webSocket.sendTXT(json);
    Serial.println("Sent: " + json);
  }
}

void webSocketEvent(WStype_t type, uint8_t *payload, size_t length) {
  switch(type) {
    case WStype_CONNECTED:
      Serial.println("WebSocket Connected!");
      break;

    case WStype_DISCONNECTED:
      Serial.println("WebSocket Disconnected!");
      break;

    case WStype_TEXT:
      Serial.printf("Received from server: %s\n", payload);
      break;
  }
}