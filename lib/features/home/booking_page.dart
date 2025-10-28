import 'package:district/features/controllers/booking_controller.dart';
import 'package:district/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum BookingType { dining, event, movie, other }

class BookingPage extends ConsumerStatefulWidget {
  final String itemId;
  final String itemName;
  final BookingType bookingType;
  final String? additionalInfo;

  const BookingPage({
    Key? key,
    required this.itemId,
    required this.itemName,
    required this.bookingType,
    this.additionalInfo,
  }) : super(key: key);

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int count = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundColor1, AppColors.backgrondColor2],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 30),
                      _buildCountSelector(),
                      const SizedBox(height: 25),
                      _buildDateSelector(),
                      const SizedBox(height: 25),
                      _buildTimeSelector(),
                      const Spacer(),
                      _buildConfirmButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              _getPageTitle(),
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.itemName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        if (widget.additionalInfo != null) ...[
          const SizedBox(height: 8),
          Text(widget.additionalInfo!, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ],
    );
  }

  Widget _buildCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_getCountLabel(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                onPressed: count > 1 ? () => setState(() => count--) : null,
              ),
              Text('$count ${_getCountUnit()}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: count < 20 ? () => setState(() => count++) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Date', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.green),
                const SizedBox(width: 12),
                Text(
                  selectedDate == null ? 'Choose a date' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  style: TextStyle(color: selectedDate == null ? Colors.grey : Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Time', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectTime(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.green),
                const SizedBox(width: 12),
                Text(
                  selectedTime == null ? 'Choose a time' : selectedTime!.format(context),
                  style: TextStyle(color: selectedTime == null ? Colors.grey : Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: selectedDate != null && selectedTime != null ? () => _confirmBooking() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          disabledBackgroundColor: Colors.grey[800],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Confirm Booking', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Colors.green, surface: Color(0xFF1F1F1F))),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Colors.green, surface: Color(0xFF1F1F1F))),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  void _confirmBooking() {
    final user = FirebaseAuth.instance.currentUser;
  if (user == null || selectedDate == null || selectedTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please log in and select date & time.')),
    );
    return;
  }
    
    final type = _getTypeString();
      final bookingData = {
    '${type}Id': widget.itemId,
    '${type}Name': widget.itemName,
    'userId': user.uid,
    'userEmail': user.email ?? '',
    'userName': user.displayName ?? 'Guest',
    'date': selectedDate!.toIso8601String(),
    'time': '${selectedTime!.hour}:${selectedTime!.minute}',
    'count': count,
    'bookingTime': DateTime.now().toIso8601String(),
    'status': 'confirmed',
  };
    ref.read(bookingControllerProvider.notifier).addBooking(_getTypeString(), widget.itemId, user.uid , bookingData);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_getSuccessMessage()), backgroundColor: Colors.green),
    );
  }

  String _getPageTitle() {
    return {
      BookingType.dining: 'Book a Table',
      BookingType.event: 'Book Event',
      BookingType.movie: 'Book Movie Tickets',
      BookingType.other: 'Make a Booking',
    }[widget.bookingType]!;
  }

  String _getCountLabel() {
    return {
      BookingType.dining: 'Number of Seats',
      BookingType.event: 'Number of Tickets',
      BookingType.movie: 'Number of Tickets',
      BookingType.other: 'Count',
    }[widget.bookingType]!;
  }

  String _getCountUnit() {
    final units = {
      BookingType.dining: ['Guest', 'Guests'],
      BookingType.event: ['Ticket', 'Tickets'],
      BookingType.movie: ['Ticket', 'Tickets'],
      BookingType.other: ['Item', 'Items'],
    }[widget.bookingType]!;
    return count == 1 ? units[0] : units[1];
  }

  String _getTypeString() {
    return {
      BookingType.dining: 'dining',
      BookingType.event: 'event',
      BookingType.movie: 'movie',
      BookingType.other: 'other',
    }[widget.bookingType]!;
  }

  String _getSuccessMessage() {
    return {
      BookingType.dining: 'Table booked for $count guests!',
      BookingType.event: '$count ticket${count > 1 ? 's' : ''} booked successfully!',
      BookingType.movie: '$count movie ticket${count > 1 ? 's' : ''} booked!',
      BookingType.other: 'Booking confirmed!',
    }[widget.bookingType]!;
  }
}
