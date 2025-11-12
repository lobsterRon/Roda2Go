import 'package:flutter/material.dart';

class ChargerDetailsPage extends StatefulWidget {
  final String location;
  const ChargerDetailsPage({super.key, required this.location});

  @override
  State<ChargerDetailsPage> createState() => _ChargerDetailsPageState();
}

class _ChargerDetailsPageState extends State<ChargerDetailsPage> {
  bool _isCharging = false; // Track whether the user is currently charging

  @override
  Widget build(BuildContext context) {
    final chargers = [
      {
        "id": "GENTARI_UTP01",
        "power": "22.1 kW max",
        "type": "Type 2",
        "status": "Charging",
        "price": "RM 1.15 / kWh",
        "extra": "+ RM 1.00 / min (after 4 hours)"
      },
      {
        "id": "GENTARI_UTP02",
        "power": "22.1 kW max",
        "type": "Type 2",
        "status": "Available",
        "price": "RM 1.15 / kWh",
        "extra": "+ RM 1.00 / min (after 4 hours)"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.location,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chargers.length,
              itemBuilder: (context, index) {
                final charger = chargers[index];
                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(charger['id']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(charger['power']!,
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.ev_station,
                                color: Colors.green, size: 18),
                            const SizedBox(width: 6),
                            Text(charger['type']!,
                                style:
                                const TextStyle(color: Colors.black87)),
                            const Spacer(),
                            Text(charger['status']!,
                                style: TextStyle(
                                  color: charger['status'] == "Charging"
                                      ? Colors.orange
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text("${charger['price']}"),
                        Text("${charger['extra']}",
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 🟢 Bottom Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(context,
                    _isCharging ? "Charging Details" : "Charge", Colors.green),
                _buildActionButton(context, "Queue", Colors.orange),
                _buildActionButton(context, "Book Slot", Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            if (label == "Charge" || label == "Charging Details") {
              _handleChargeButton(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$label action triggered")),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Future<void> _handleChargeButton(BuildContext context) async {

    if (_isCharging) {
      // Already charging → Go to Charge Details
      Navigator.pushNamed(context, "/chargeDetails");
    } else {
      /*
      // Start charging → Go to QR scanner
      final result = await Navigator.pushNamed(context, "/qrScanner");

      if (result == true) {
        // QR scan succeeded → user started charging
        setState(() => _isCharging = true);

        // Navigate to Charge Details screen
        Navigator.pushNamed(context, "/chargeDetails");
       */

      ElevatedButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/chargeDetails');
        },
        child: const Text("Simulate Scan"),
      )

    }
    }
  }
}
