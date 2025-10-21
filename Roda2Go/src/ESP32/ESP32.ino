#include <WiFi.h>
#include <WebSocketsClient.h>

WebSocketsClient webSocket;

// const char* ssid = "r.singh@unifi";
const char* ssid = "HUAWEI P20 Pro";
// const char* password = "17243476";
const char* password = "ron041228";
const char* serverHost = "192.168.43.33";  // Replace with your server’s IP
const int serverPort = 3000;

// The BOOT button is connected to GPIO0
const int buttonPin = 9;
bool lastState = HIGH;  // BOOT button is HIGH by default

void setup() {
  Serial.begin(115200);
  pinMode(buttonPin, INPUT_PULLUP);

  Serial.println("Connecting to WiFi...");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi!");
  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.localIP());

  // Connect to WebSocket server
  webSocket.begin(serverHost, serverPort, "/");
  webSocket.onEvent(webSocketEvent);
  Serial.println("Connecting to WebSocket server...");
}

void loop() {
  webSocket.loop();

  bool currentState = digitalRead(buttonPin);

  // Detect button press/release
  if (currentState != lastState) {
    lastState = currentState;

    String status = currentState == LOW ? "in_use" : "available";
    String json = "{\"charger_id\":\"EV001\",\"status\":\"" + status + "\"}";
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
