import 'package:district/models/movie/movie_model.dart';
import 'package:district/models/movie/showtime_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MovieBookingPage extends StatefulWidget {
  final MovieModel movie;

  const MovieBookingPage({Key? key, required this.movie}) : super(key: key);

  @override
  State<MovieBookingPage> createState() => _MovieBookingPageState();
}

class _MovieBookingPageState extends State<MovieBookingPage> {
  static const int maxSeats = 7;
  static const List<String> rows = ['A', 'B', 'C', 'D', 'E', 'F'];
  static const int seatsPerRow = 10;

  ShowtimeModel? selectedShowtime;
  List<String> selectedSeats = [];
  late List<String> bookedSeats;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMovieInfo(),
            _buildShowtimeSelection(),
            if (selectedShowtime != null) _buildSeatSelection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.movie.title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget _buildMovieInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              widget.movie.posterUrls.isNotEmpty ? widget.movie.posterUrls[0] : '',
              width: 80,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 120,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.movie.rating} | ${widget.movie.language}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.movie.duration,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowtimeSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Showtime',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.movie.showtimes.map(_buildShowtimeCard),
        ],
      ),
    );
  }

  Widget _buildShowtimeCard(ShowtimeModel showtime) {
    final isSelected = selectedShowtime?.id == showtime.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedShowtime = showtime;
          selectedSeats.clear();
          bookedSeats = _generateBookedSeats(showtime);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withOpacity(0.2) : Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              showtime.cinemaName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              showtime.address,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('h:mm a').format(showtime.time),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                Text(
                  '₹${showtime.price.toInt()} per ticket',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${showtime.availableSeats} seats available',
              style: TextStyle(
                color: showtime.availableSeats < 20 ? Colors.orange : Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Seats (${selectedSeats.length}/$maxSeats)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (selectedSeats.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => selectedSeats.clear()),
                  child: const Text(
                    'Clear All',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildScreen(),
                const SizedBox(height: 24),
                _buildSeatsGrid(),
                const SizedBox(height: 16),
                _buildLegend(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[800]!, Colors.white, Colors.grey[800]!],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'SCREEN',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSeatsGrid() {
    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  row,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              ...List.generate(seatsPerRow, (index) {
                final seatNumber = '$row${index + 1}';
                return _buildSeat(seatNumber);
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeat(String seatNumber) {
    final isBooked = bookedSeats.contains(seatNumber);
    final isSelected = selectedSeats.contains(seatNumber);

    return GestureDetector(
      onTap: isBooked ? null : () => _toggleSeat(seatNumber),
      child: Container(
        margin: const EdgeInsets.all(3),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isBooked
              ? Colors.grey[700]
              : isSelected
                  ? Colors.green
                  : Colors.grey[800],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            isBooked
                ? Icons.close
                : isSelected
                    ? Icons.check
                    : null,
            size: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _toggleSeat(String seatNumber) {
    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else if (selectedSeats.length < maxSeats) {
        selectedSeats.add(seatNumber);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum $maxSeats seats can be selected'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Available', Colors.grey[800]!),
        const SizedBox(width: 16),
        _buildLegendItem('Selected', Colors.green),
        const SizedBox(width: 16),
        _buildLegendItem('Booked', Colors.grey[700]!),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }

  Widget? _buildBottomBar() {
    if (selectedShowtime == null || selectedSeats.isEmpty) return null;

    final numberOfTickets = selectedSeats.length;
    final totalPrice = selectedShowtime!.price * numberOfTickets;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$numberOfTickets Ticket${numberOfTickets > 1 ? 's' : ''}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              Text(
                '₹${totalPrice.toInt()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Seats: ${selectedSeats.join(", ")}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _showConfirmationDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirm Booking',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    final numberOfTickets = selectedSeats.length;
    final totalPrice = selectedShowtime!.price * numberOfTickets;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Booking Confirmed!',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('Movie', widget.movie.title),
            _buildDialogRow('Cinema', selectedShowtime!.cinemaName),
            _buildDialogRow(
              'Time',
              DateFormat('MMM dd, h:mm a').format(selectedShowtime!.time),
            ),
            _buildDialogRow('Tickets', numberOfTickets.toString()),
            _buildDialogRow('Seats', selectedSeats.join(", ")),
            const SizedBox(height: 8),
            Text(
              'Total: ₹${totalPrice.toInt()}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label: $value',
        style: TextStyle(color: Colors.grey[400]),
      ),
    );
  }

  List<String> _generateBookedSeats(ShowtimeModel showtime) {
    final bookedCount = showtime.totalSeats - showtime.availableSeats;
    return List.generate(
      bookedCount > 20 ? 20 : bookedCount,
      (i) => '${rows[i ~/ seatsPerRow]}${(i % seatsPerRow) + 1}',
    );
  }
}
