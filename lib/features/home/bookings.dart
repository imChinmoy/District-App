import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:district/providers/auth_provider.dart';
import 'package:district/features/controllers/booking_controller.dart';

class AllBookingsScreen extends ConsumerStatefulWidget {
  const AllBookingsScreen({super.key});

  @override
  ConsumerState<AllBookingsScreen> createState() => _AllBookingsScreenState();
}

class _AllBookingsScreenState extends ConsumerState<AllBookingsScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _fetchBookings();
      _initialized = true;
    }
  }

  void _fetchBookings() {
    final user = ref.read(authProvider);
    if (user != null) {
      ref.read(bookingControllerProvider.notifier).fetchUserBookings(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingControllerProvider);
    final user = ref.read(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: _buildAppBar(),
      body: _buildBody(user, bookings),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text("My Bookings"),
      backgroundColor: Colors.deepPurpleAccent.shade200,
      elevation: 4,
    );
  }

  Widget _buildBody(dynamic user, List bookings) {
    if (user == null) {
      return const Center(
        child: Text(
          "Please log in to view your bookings.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    if (bookings.isEmpty) {
      return const Center(
        child: Text(
          "No bookings yet",
          style: TextStyle(fontSize: 16, color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: bookings.length,
      padding: const EdgeInsets.all(14),
      itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
    );
  }

  Widget _buildBookingCard(dynamic booking) {
    final bookingInfo = _extractBookingInfo(booking);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: _cardDecoration(),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildLeadingIcon(bookingInfo.status),
        title: _buildTitle(bookingInfo.name),
        subtitle: _buildSubtitle(bookingInfo),
        trailing: _buildStatusBadge(bookingInfo.status),
      ),
    );
  }

  BookingInfo _extractBookingInfo(dynamic booking) {

    return BookingInfo(
      name: booking.eventName ?? booking.movieName ?? booking.diningName ?? "Unknown",
      count: booking.count?.toString() ?? "1",
      date: _formatDate(booking.date),
      time: booking.time ?? "N/A",
      status: booking.status?.name ?? "pending",
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Widget _buildLeadingIcon(String status) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: _getStatusColor(status),
      child: const Icon(Icons.confirmation_num_outlined, color: Colors.white),
    );
  }

  Widget _buildTitle(String name) {
    return Text(
      name,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSubtitle(BookingInfo info) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoText("Date: ${info.date}"),
          _buildInfoText("Time: ${info.time}"),
          _buildInfoText("Tickets: ${info.count}"),
        ],
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return "Unknown Date";
    
    try {
      final parsed = DateTime.tryParse(dateValue.toString());
      if (parsed == null) return dateValue.toString();
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return dateValue.toString();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.greenAccent.shade400;
      case 'pending':
        return Colors.orangeAccent;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}

class BookingInfo {
  final String name;
  final String count;
  final String date;
  final String time;
  final String status;

  BookingInfo({
    required this.name,
    required this.count,
    required this.date,
    required this.time,
    required this.status,
  });
}