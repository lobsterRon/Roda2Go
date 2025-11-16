import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ev_charger/websocket_service.dart';

class ChargerDetailsPage extends StatefulWidget {
  final String location;
  const ChargerDetailsPage({super.key, required this.location});

  @override
  State<ChargerDetailsPage> createState() => _ChargerDetailsPageState();
}

class _ChargerDetailsPageState extends State<ChargerDetailsPage> {
  bool _isCharging = false;
  int? _selectedIndex;
  int? _queuedIndex;             // NEW: which charger is queued
  Timer? _queueTimer;            // NEW: countdown timer

  @override
  void initState() {
    super.initState();

    WebSocketService().stream.listen((data) {
      if (data["chargerId"] == "GENTARI_UTP01") {

        setState(() {
          chargers[0]["status"] = data["status"];
          chargers[0]["queueTime"] = data["status"] == "Charging" ? "≈ 2 hrs" : "-";
        });
      }
    });
  }


  final List<Map<String, dynamic>> chargers = [
    {
      "id": "GENTARI_UTP01",
      "power": "22.1 kW max",
      "type": "Type 2",
      "status": "Charging",
      "price": "RM 1.15 / kWh",
      "extra": "+ RM 1.00 / min (after 4 hours)",
      "queueTime": "≈ 2 hrs",
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
  void dispose() {
    _queueTimer?.cancel();
    super.dispose();
  }

  // 🔄 Start the queue countdown (1 minute)
  void _startQueueTimer() {
    _queueTimer?.cancel(); // safety

    _queueTimer = Timer(const Duration(minutes: 1), () {
      Navigator.pushNamed(context, "/yourTurn");
    });
  }

  // ❌ Cancel Queue
  void _cancelQueue() {
    _queueTimer?.cancel();
    setState(() {
      _queuedIndex = null;
      _selectedIndex = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Queue cancelled."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 🔌 Handle Queue Press
  void _handleQueue() {
    if (_queuedIndex == null) {
      // Starting new queue
      setState(() => _queuedIndex = _selectedIndex);
      _startQueueTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You have joined the queue. You will be notified shortly."),
        ),
      );
    } else {
      // Cancel existing queue
      _cancelQueue();
    }
  }

  // ⚡ Handle Charge Button
  Future<void> _handleChargeButton(BuildContext context) async {
    if (_isCharging) {
      Navigator.pushNamed(context, "/chargeDetails");
    } else {
      Navigator.pushNamed(context, "/qrScanner");
      setState(() => _isCharging = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            _queueTimer?.cancel();
            Navigator.pop(context);
          },
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
                final isSelected = _selectedIndex == index;
                final queueLocked = _queuedIndex != null && _queuedIndex != index;

                return GestureDetector(
                  onTap: queueLocked
                      ? null
                      : () => setState(() => _selectedIndex = index),
                  child: Opacity(
                    opacity: queueLocked ? 0.4 : 1.0,
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

                            Row(
                              children: [
                                const Icon(Icons.ev_station,
                                    color: Colors.green, size: 18),
                                const SizedBox(width: 6),
                                Text(charger['type']),
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
                  ),
                );
              },
            ),
          ),

          // 🟢 Bottom Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Charge Button
                _buildActionButton(
                  context,
                  _isCharging ? "Charging Details" : "Charge",
                  Colors.green,
                  enabled: _selectedIndex != null &&
                      _queuedIndex == null && // disable when queued
                      (_isCharging
                          ? chargers[_selectedIndex!]["status"] == "Charging"
                          : chargers[_selectedIndex!]["status"] == "Available"),
                  onPressed: () => _handleChargeButton(context),
                ),

                // Queue Button
                _buildActionButton(
                  context,
                  _queuedIndex != null ? "Cancel Queue" : "Queue",
                  _queuedIndex != null ? Colors.red : Colors.orange,
                  enabled: _selectedIndex != null &&
                      (_queuedIndex == null ||
                          _queuedIndex == _selectedIndex) &&
                      chargers[_selectedIndex!]["status"] == "Charging",
                  onPressed: _handleQueue,
                ),

                // Book Slot button
                _buildActionButton(
                  context,
                  "Book Slot",
                  Colors.blue,
                  enabled: _selectedIndex != null && _queuedIndex == null,
                  onPressed: () {
                    Navigator.pushNamed(context, "/slotBooking", arguments: chargers[_selectedIndex!]["id"]);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BUTTON BUILDER
  Widget _buildActionButton(BuildContext context, String label, Color color,
      {required bool enabled, required VoidCallback onPressed}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: ElevatedButton(
            onPressed: enabled ? onPressed : null,
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
      ),
    );
  }
}
