import 'package:ev_charger/charge_details.dart';
import 'package:ev_charger/charger_details_page.dart';
import 'package:ev_charger/qr_scanner.dart';
import 'package:ev_charger/websocket_service.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  WebSocketService().connect();
  runApp(const Roda2GoApp());
}

class Roda2GoApp extends StatelessWidget {
  const Roda2GoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roda2Go',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const HomePage(),
      routes: {
        '/qrScanner': (context) => const QRScannerScreen(),
        '/chargerDetails': (context) => const ChargerDetailsPage(location: 'Gentari UTP'),
        '/chargeDetails': (context) => const ChargeDetailsScreen(),
      }
    );
  }
}
