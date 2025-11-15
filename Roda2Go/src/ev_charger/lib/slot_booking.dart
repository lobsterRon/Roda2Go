import 'package:flutter/material.dart';

class SlotBookingPage extends StatefulWidget {
  final String chargerId;

  const SlotBookingPage({super.key, required this.chargerId});

  @override
  State<SlotBookingPage> createState() => _SlotBookingPageState();
}

class _SlotBookingPageState extends State<SlotBookingPage> {
  DateTime now = DateTime.now();
  int dayOffset = 0;

  List<String> selectedSlots = [];

  @override
  Widget build(BuildContext context) {
    DateTime selectedDay = now.add(Duration(days: dayOffset));

    List<DateTime> timeSlots = List.generate(
      24,
          (i) => DateTime(selectedDay.year, selectedDay.month, selectedDay.day, i),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Charging Slot"),
        backgroundColor: Colors.green,
        actions: [
          if (selectedSlots.isNotEmpty)
            TextButton(
              onPressed: _cancelBooking,
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          ToggleButtons(
            isSelected: [dayOffset == 0, dayOffset == 1],
            onPressed: (index) {
              setState(() {
                dayOffset = index;
                selectedSlots.clear();
              });
            },
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            fillColor: Colors.green,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Today"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text("Tomorrow"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                DateTime slot = timeSlots[index];
                String label = "${slot.hour.toString().padLeft(2, '0')}:00";

                bool isPast = slot.isBefore(now);
                bool isNext5Hours = slot.isBefore(now.add(const Duration(hours: 5)));

                bool isDisabled = (dayOffset == 0 && (isPast || isNext5Hours));
                bool isSelected = selectedSlots.contains(label);

                return GestureDetector(
                  onTap: isDisabled ? null : () => _toggleSlot(label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isDisabled
                          ? Colors.grey[300]
                          : isSelected
                          ? Colors.green
                          : Colors.white,
                      borderRadius: BorderRadius.circular(_radiusForSlot(label)),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.black26,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isDisabled
                            ? Colors.black38
                            : isSelected
                            ? Colors.white
                            : Colors.black87,
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                selectedSlots.isEmpty ? Colors.grey : Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: selectedSlots.isEmpty
                  ? null
                  : () => _confirmBooking(context),
              child: const Text("Confirm Booking"),
            ),
          )
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  //   VISUAL CONTINUOUS BLOCK: Rounded edges only at first / last slot
  // ----------------------------------------------------------------------
  double _radiusForSlot(String label) {
    if (selectedSlots.isEmpty) return 8;

    List<String> sorted = [...selectedSlots]..sort();
    String first = sorted.first;
    String last = sorted.last;

    if (label == first) return 12;
    if (label == last) return 12;

    return 2; // middle of block
  }

  // ----------------------------------------------------------------------
  //   MULTI-SLOT SELECTION (only consecutive hours)
  // ----------------------------------------------------------------------
  void _toggleSlot(String label) {
    setState(() {
      if (selectedSlots.contains(label)) {
        selectedSlots.remove(label);
        return;
      }

      if (selectedSlots.isEmpty) {
        selectedSlots.add(label);
        return;
      }

      List<String> sorted = [...selectedSlots]..sort();
      String first = sorted.first;
      String last = sorted.last;

      int newHour = int.parse(label.split(":")[0]);
      int firstHour = int.parse(first.split(":")[0]);
      int lastHour = int.parse(last.split(":")[0]);

      bool isNext = newHour == lastHour + 1;
      bool isPrevious = newHour == firstHour - 1;

      if (isNext || isPrevious) {
        selectedSlots.add(label);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select consecutive time slots."),
          ),
        );
      }
    });
  }

  // ----------------------------------------------------------------------
  //   CANCEL BOOKING BUTTON
  // ----------------------------------------------------------------------
  void _cancelBooking() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel Booking"),
        content: const Text(
          "Are you sure you want to cancel your selected time slots?",
        ),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Yes, Cancel"),
            onPressed: () {
              Navigator.pop(context);
              setState(() => selectedSlots.clear());
            },
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  //   CONFIRM BOOKING → Push to YourTurn page with countdown
  // ----------------------------------------------------------------------
  void _confirmBooking(BuildContext context) async {
    selectedSlots.sort();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Booking"),
        content: Text(
          "You selected:\n${selectedSlots.join(", ")}\n\nConfirm your booking?",
        ),
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
                    "Slot booked successfully! You will be notified 30 minutes before your turn.",
                  ),
                ),
              );

              Future.delayed(const Duration(seconds: 30), () {
                Navigator.pushNamed(
                  context,
                  "/yourTurn",
                  arguments: {
                    "slots": selectedSlots,
                    "chargerId": widget.chargerId,
                  },
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
