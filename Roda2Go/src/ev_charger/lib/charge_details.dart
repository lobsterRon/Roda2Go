import 'dart:async';
import 'package:flutter/material.dart';

class ChargeDetailsScreen extends StatefulWidget {
  final double initialBalance;
  const ChargeDetailsScreen({super.key, required this.initialBalance});

  @override
  State<ChargeDetailsScreen> createState() => _ChargeDetailsScreenState();
}

class _ChargeDetailsScreenState extends State<ChargeDetailsScreen> {
  int _stage = 0;
  double _opacity = 1.0;
  late double _balance;

  @override
  void initState() {
    super.initState();
    _balance = widget.initialBalance;
    _startStageTransitions();
  }

  void _startStageTransitions() {
    Timer(const Duration(seconds: 30), () => _changeStage(1));
    Timer(const Duration(seconds: 60), () => _changeStage(2));
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
        message =
        "Thank you for using Roda2Go!\nTotal charge amount for this session: RM50.00\nYou are good to go!";
        break;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Return updated balance when going back
            Navigator.pop(context, _balance - 50.0);
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
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 40),
                if (_stage == 2)
                  ElevatedButton(
                    onPressed: () {
                      // Return updated balance to HomePage
                      Navigator.pop(context, _balance - 50.0);
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
