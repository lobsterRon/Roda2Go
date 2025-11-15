import 'package:ev_charger/charge_details.dart';
import 'package:ev_charger/charger_details_page.dart';
import 'package:ev_charger/qr_scanner.dart';
import 'package:ev_charger/slot_booking.dart';
import 'package:ev_charger/websocket_service.dart';
import 'package:ev_charger/your_turn.dart';
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
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/qrScanner':
              final walletBalance = settings.arguments as double?;
              return MaterialPageRoute(
                builder: (context) => QRScannerScreen(walletBalance: walletBalance ?? 0),
              );

            case '/chargeDetails':
              final initialBalance = settings.arguments as double?;
              return MaterialPageRoute(
                builder: (context) => ChargeDetailsScreen(initialBalance: initialBalance ?? 0),
              );

            case '/chargerDetails':
              final location = settings.arguments as String?;
              return MaterialPageRoute(
                builder: (context) => ChargerDetailsPage(location: location ?? 'Unknown'),
              );

            case '/slotBooking':
              final chargerId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => SlotBookingPage(chargerId: chargerId),
              );

            case '/yourTurn':
              return MaterialPageRoute(
                builder: (context) => const YourTurnScreen(),
              );

            default:
              return null;
          }
      }
    );
  }
}
