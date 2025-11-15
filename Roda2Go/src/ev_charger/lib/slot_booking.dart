import 'package:flutter/material.dart';

class SlotBookingPage extends StatefulWidget {
  final String chargerId;
  const SlotBookingPage({super.key, required this.chargerId});

  @override
  State<SlotBookingPage> createState() => _SlotBookingPageState();
}

class _SlotBookingPageState extends State<SlotBookingPage> {
  final Duration slotInterval = const Duration(minutes: 30);

  late DateTime now;
  late DateTime limit;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();                         // Current time
    limit = now.add(const Duration(hours: 5));    // Only allow next 5 hours
  }

  // Generate 30-min slots from 7AM–11PM
  List<DateTime> generateSlots(DateTime date) {
    DateTime start = DateTime(date.year, date.month, date.day, 7, 0);
    DateTime end = DateTime(date.year, date.month, date.day, 23, 0);

    List<DateTime> slots = [];
    DateTime t = start;

    while (t.isBefore(end)) {
      slots.add(t);
      t = t.add(slotInterval);
    }
    return slots;
  }

  bool isSlotAvailable(DateTime slot) {
    // TODAY
    if (slot.day == now.day && slot.month == now.month) {
      if (slot.isBefore(limit)) return false;
      return true;
    }

    // TOMORROW → all future slots allowed
    if (slot.isAfter(now)) return true;

    return false;
  }

  void _confirmBooking(DateTime slot) {
    final slotLabel = formatSlot(slot);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Booking"),
        content: Text("Book the slot at $slotLabel?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Yes"),
            onPressed: () {
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Slot booked successfully. You will be notified 30 minutes before your turn.",
                  ),
                  duration: Duration(seconds: 3),
                ),
              );

              Future.delayed(const Duration(seconds: 1), () {
                Navigator.pushNamed(context, "/yourTurn");
              });
            },
          ),
        ],
      ),
    );
  }

  String formatSlot(DateTime t) {
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildSlotTile(DateTime slot) {
    bool available = isSlotAvailable(slot);
    String label = formatSlot(slot);

    return GestureDetector(
      onTap: available ? () => _confirmBooking(slot) : null,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: available ? Colors.green : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: available ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = today.add(const Duration(days: 1));

    final todaySlots = generateSlots(today);
    final tomorrowSlots = generateSlots(tomorrow);

    return Scaffold(
      appBar: AppBar(
        title: Text("Book Slot - ${widget.chargerId}"),
        backgroundColor: Colors.green,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TODAY
          const Text(
            "Today",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            childAspectRatio: 2.2,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            children: [
              for (var slot in todaySlots) _buildSlotTile(slot),
            ],
          ),

          const SizedBox(height: 30),

          // TOMORROW
          const Text(
            "Tomorrow",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            childAspectRatio: 2.2,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            children: [
              for (var slot in tomorrowSlots) _buildSlotTile(slot),
            ],
          ),
        ],
      ),
    );
  }
}