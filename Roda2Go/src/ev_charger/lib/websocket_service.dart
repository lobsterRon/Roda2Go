import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  WebSocketService._internal();

  WebSocketChannel? _channel;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  bool _isConnected = false;

  void connect() {
    if (_isConnected) return;

    print("🔌 Connecting to WebSocket...");
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse("ws://192.168.43.33:3000"),
      );
      _isConnected = true;

      _channel!.stream.listen(
            (event) {
          print("📥 WS RECEIVED: $event");

          if (event is List<int>) {
            // Convert bytes → string
            final text = String.fromCharCodes(event);
            print("📥 WS TEXT: $text");

            try {
              final jsonData = jsonDecode(text);
              _controller.add(jsonData);
            } catch (e) {
              print("❌ JSON decode failed: $e");
            }
          }
        },
        onDone: () {
          print("⚠️ WebSocket connection closed. Retrying in 3 seconds...");
          _isConnected = false;
          Future.delayed(const Duration(seconds: 3), connect);
        },
        onError: (err) {
          print("❌ WebSocket error: $err");
          _isConnected = false;
          Future.delayed(const Duration(seconds: 3), connect);
        },
      );
    } catch (e) {
      print("❌ WebSocket connection failed: $e");
      Future.delayed(const Duration(seconds: 3), connect);
    }
  }

  void sendMessage(Map<String, dynamic> data) {
    try {
      if (_channel != null) {
        _channel!.sink.add(json.encode(data));
      }
    } catch (e) {
      print("❌ Failed to send WebSocket message: $e");
    }
  }

  void dispose() {
    _channel?.sink.close(status.goingAway);
    _controller.close();
  }
}
