import 'package:district/models/booking_model.dart';
import 'package:district/providers/auth_provider.dart';
import 'package:district/features/controllers/booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
class TableBookings extends ConsumerStatefulWidget {
  const TableBookings({Key? key}) : super(key: key);

  @override
  ConsumerState<TableBookings> createState() => _TableBookingsState();
}

class _TableBookingsState extends ConsumerState<TableBookings> {
  bool _isFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ref.watch(authProvider);
    if (!_isFetched && user != null) {
      ref.read(bookingControllerProvider.notifier).fetchUserBookings(user.uid);
      _isFetched = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingControllerProvider);
    final user = ref.watch(authProvider);

    if (user == null) {
      return const Center(
        child: Text('Please sign in to view your bookings.'),
      );
    }

    if (bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(bookingControllerProvider.notifier)
            .fetchUserBookings(user.uid);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final iconData = _getBookingIcon(booking.bookingType);
    final color = _getBookingColor(booking.status);
    final statusText = booking.status.name.toUpperCase();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(iconData, color: color, size: 26),
        ),
        title: Text(
          '${booking.bookingType.name.toUpperCase()} • ${booking.quantity} item(s)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '₹${booking.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Booked on: ${_formatDate(booking.bookingDate)}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () => context.push('/home/dining/details', extra: booking),
      ),
    );
  }

  IconData _getBookingIcon(BookingType type) {
    switch (type) {
      case BookingType.movie:
        return Icons.movie;
      case BookingType.dining:
        return Icons.restaurant;
      case BookingType.event:
        return Icons.event;
    }
  }

  Color _getBookingColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}
