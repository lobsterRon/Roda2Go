import 'package:flutter/material.dart';
import 'package:ev_charger/websocket_service.dart';

class ChargerDetailsPage extends StatefulWidget {
  final String location;
  const ChargerDetailsPage({super.key, required this.location});

  @override
  State<ChargerDetailsPage> createState() => _ChargerDetailsPageState();
}

class _ChargerDetailsPageState extends State<ChargerDetailsPage> {
  bool _isCharging = false;      // Track whether user is charging
  int? _selectedIndex;           // Track selected charger index

  final List<Map<String, dynamic>> chargers = [
    {
      "id": "GENTARI_UTP01",
      "power": "22.1 kW max",
      "type": "Type 2",
      "status": "Charging",
      "price": "RM 1.15 / kWh",
      "extra": "+ RM 1.00 / min (after 4 hours)",
      "queueTime": "≈ 10 mins",
    },
    {
      "id": "GENTARI_UTP02",
      "power": "22.1 kW max",
      "type": "Type 2",
      "status": "Available",
      "price": "RM 1.15 / kWh",
      "extra": "+ RM 1.00 / min (after 4 hours)",
      "queueTime": "-",
    },
  ];

  @override
  void initState() {
    super.initState();

    // 🔌 Listen for real-time WebSocket updates
    WebSocketService().stream.listen((data) {
      if (data["type"] == "status_update" &&
          data["chargerId"] == "GENTARI_UTP01") {
        setState(() {
          chargers[0]["status"] = data["status"];
          chargers[0]["queueTime"] =
          data["status"] == "Charging" ? "≈ 10 mins" : "-";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          // Charger List UI
          Expanded(
            child: ListView.builder(
              itemCount: chargers.length,
              itemBuilder: (context, index) {
                final charger = chargers[index];
                final isSelected = _selectedIndex == index;

                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.green : Colors.transparent,
                        width: 2,
                      ),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(charger['id'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(charger['power'],
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Type & status row
                          Row(
                            children: [
                              const Icon(Icons.ev_station,
                                  color: Colors.green, size: 18),
                              const SizedBox(width: 6),
                              Text(charger['type'],
                                  style: const TextStyle(color: Colors.black87)),
                              const Spacer(),
                              Text(
                                charger['status'],
                                style: TextStyle(
                                    color: charger['status'] == "Charging"
                                        ? Colors.orange
                                        : Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Queue time if charging
                          if (charger['status'] == "Charging")
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined,
                                    size: 16, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text(
                                  "Est. Queue Time: ${charger['queueTime']}",
                                  style: const TextStyle(
                                      color: Colors.orange, fontSize: 13),
                                ),
                              ],
                            ),

                          const SizedBox(height: 6),
                          Text(charger['price']),
                          Text(charger['extra'],
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildActionButton(
                  context,
                  _isCharging ? "Charging Details" : "Charge",
                  Colors.green,
                  enabled: _selectedIndex != null &&
                      (_isCharging
                          ? chargers[_selectedIndex!]['status'] == "Charging"
                          : chargers[_selectedIndex!]['status'] == "Available"),
                ),

                _buildActionButton(
                  context, "Queue", Colors.orange,
                  enabled: _selectedIndex != null,
                ),

                _buildActionButton(
                  context, "Book Slot", Colors.blue,
                  enabled: _selectedIndex != null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, Color color,
      {bool enabled = true}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: ElevatedButton(
            onPressed: enabled
                ? () {
              if (label == "Charge" || label == "Charging Details") {
                _handleChargeButton(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$label action triggered")),
                );
              }
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Future<void> _handleChargeButton(BuildContext context) async {
    if (_isCharging) {
      Navigator.pushNamed(context, "/chargeDetails");
    } else {
      Navigator.pushNamed(context, "/qrScanner");
      setState(() => _isCharging = true);
    }
  }
}