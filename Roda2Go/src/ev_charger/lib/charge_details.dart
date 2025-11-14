import 'dart:async';
import 'package:flutter/material.dart';

class ChargeDetailsScreen extends StatefulWidget {
  const ChargeDetailsScreen({super.key});

  @override
  State<ChargeDetailsScreen> createState() => _ChargeDetailsScreenState();
}

class _ChargeDetailsScreenState extends State<ChargeDetailsScreen> {
  int _stage = 0; // 0 = identified, 1 = charging complete, 2 = thank you
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _startStageTransitions();
  }

  void _startStageTransitions() {
    Timer(const Duration(minutes: 2), () => _changeStage(1));
    Timer(const Duration(minutes: 3), () => _changeStage(2));
  }

  void _changeStage(int newStage) {
    setState(() => _opacity = 0.0);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _stage = newStage;
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String imagePath;
    String message;

    switch (_stage) {
      case 0:
        imagePath = 'assets/start_charging.jpg';
        message = "Charger identified.\nEnjoy charging!";
        break;
      case 1:
        imagePath = 'assets/return_plug.jpg';
        message = "Charging complete.\nPlease return the plug!";
        break;
      case 2:
      default:
        imagePath = 'assets/finish_charging.png';
        message = "Thank you.\nYou are good to go!";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
        title: const Text(
          "Charging Details",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(imagePath, height: 200),
                const SizedBox(height: 30),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 40),
                if (_stage == 2)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                    ),
                    child: const Text("Back to Home"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
