#include <WiFi.h>
#include <WebSocketsClient.h>

WebSocketsClient webSocket;

const char* ssid = "HUAWEI P20 Pro";
const char* password = "ron041228";
const char* serverHost = "192.168.43.33";   // Your Node.js server IP
const int serverPort = 3000;

const int buttonPin = 9;  // BOOT button on ESP32 = GPIO0

volatile bool buttonPressed = false;
volatile bool currentState = HIGH;  // Default state (unpressed)
volatile unsigned long lastInterruptTime = 0;

void IRAM_ATTR handleButtonInterrupt() {
  unsigned long currentTime = millis();
  // Basic debounce: ignore interrupts within 150ms
  if (currentTime - lastInterruptTime > 150) {
    currentState = digitalRead(buttonPin);
    buttonPressed = true;
    lastInterruptTime = currentTime;
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(buttonPin, INPUT_PULLUP);

  // Attach interrupt on state change (press or release)
  attachInterrupt(digitalPinToInterrupt(buttonPin), handleButtonInterrupt, CHANGE);

  Serial.println("Connecting to WiFi...");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi!");
  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.localIP());

  webSocket.begin(serverHost, serverPort, "/");
  webSocket.onEvent(webSocketEvent);
  Serial.println("Connecting to WebSocket server...");
}

void loop() {
  webSocket.loop();

  // Check if interrupt occurred
  if (buttonPressed) {
    buttonPressed = false;

    // Determine charger status based on button state
    String status = currentState == LOW ? "in_use" : "available";
    String json = "{\"charger_id\":\"EV001\",\"status\":\"" + status + "\"}";

    // Send JSON message to WebSocket
    webSocket.sendTXT(json);
    Serial.println("Sent: " + json);
  }
}

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
  switch(type) {
    case WStype_CONNECTED:
      Serial.println("Connected to server!");
      break;
    case WStype_DISCONNECTED:
      Serial.println("Disconnected from server!");
      break;
    case WStype_TEXT:
      Serial.printf("Received from server: %s\n", payload);
      break;
  }
}
