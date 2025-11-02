import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  Map<String, dynamic>? _selectedCharger;

  final List<Map<String, dynamic>> chargers = [
    {
      "id": "EV001",
      "name": "Station A",
      "position": const LatLng(4.397, 100.980),
      "power": "22kW",
      "price": "RM 0.40/kWh",
      "queueTime": "5 mins",
      "available": true,
    },
    {
      "id": "EV002",
      "name": "Station B",
      "position": const LatLng(4.399, 100.982),
      "power": "11kW",
      "price": "RM 0.30/kWh",
      "queueTime": "10 mins",
      "available": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  void _loadMarkers() {
    for (var charger in chargers) {
      _markers.add(
        Marker(
          markerId: MarkerId(charger['id']),
          position: charger['position'],
          infoWindow: InfoWindow(title: charger['name']),
          onTap: () {
            setState(() => _selectedCharger = charger);
          },
        ),
      );
    }
  }

  Future<void> _openGoogleMaps(LatLng position) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not open Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: const CameraPosition(
              target: LatLng(4.397, 100.980),
              zoom: 15,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_selectedCharger != null) _buildChargerInfoSheet(),
        ],
      ),
    );
  }

  Widget _buildChargerInfoSheet() {
    final charger = _selectedCharger!;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(charger['name'],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Power: ${charger['power']}"),
            Text("Price: ${charger['price']}"),
            Text("Estimated Queue: ${charger['queueTime']}"),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  "Charge",
                  charger['available'] ? Colors.green : Colors.grey,
                  charger['available']
                      ? () => _showSnack("Charging started")
                      : null,
                ),
                _buildActionButton("Queue", Colors.orange,
                    () => _showSnack("Queued successfully")),
                _buildActionButton("Book Slot", Colors.blue,
                    () => _showSnack("Slot booked")),
                _buildActionButton("Direction", Colors.black,
                    () => _openGoogleMaps(charger['position'])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String label, Color color, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
