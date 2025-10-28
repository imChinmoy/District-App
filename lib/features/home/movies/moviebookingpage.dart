import 'package:district/models/movie/movie_model.dart';
import 'package:district/models/movie/showtime_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final selectedShowtimeProvider = StateProvider<ShowtimeModel?>((ref) => null);
final selectedSeatsProvider = StateProvider<List<String>>((ref) => []);
final bookedSeatsProvider = Provider<List<String>>((ref) {
  final showtime = ref.watch(selectedShowtimeProvider);
  if (showtime == null) return [];
  final bookedCount = showtime.totalSeats - showtime.availableSeats;
  return List.generate(bookedCount > 20 ? 20 : bookedCount, (i) => '${_rows[i ~/ 10]}${(i % 10) + 1}');
});

const _rows = ['A', 'B', 'C', 'D', 'E', 'F'];
const _maxSeats = 7;

class MovieBookingPage extends ConsumerWidget {
  final MovieModel movie;

  const MovieBookingPage({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedShowtime = ref.watch(selectedShowtimeProvider);
    final selectedSeats = ref.watch(selectedSeatsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text(movie.title, style: const TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMovieInfo(),
            _buildShowtimeSelection(ref),
            if (selectedShowtime != null) _buildSeatSelection(ref),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: selectedShowtime != null && selectedSeats.isNotEmpty ? _buildBottomBar(context, ref, selectedShowtime, selectedSeats) : null,
    );
  }

  Widget _buildMovieInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(movie.posterUrls.isNotEmpty ? movie.posterUrls[0] : '', width: 80, height: 120, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 80, height: 120, color: Colors.grey[800])),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${movie.rating} | ${movie.language}', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                const SizedBox(height: 4),
                Text(movie.duration, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowtimeSelection(WidgetRef ref) {
    final selected = ref.watch(selectedShowtimeProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Showtime', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...movie.showtimes.map((showtime) => GestureDetector(
                onTap: () {
                  ref.read(selectedShowtimeProvider.notifier).state = showtime;
                  ref.read(selectedSeatsProvider.notifier).state = [];
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected?.id == showtime.id ? Colors.red.withOpacity(0.2) : Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected?.id == showtime.id ? Colors.red : Colors.transparent, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(showtime.cinemaName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(showtime.address, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [const Icon(Icons.access_time, color: Colors.grey, size: 16), const SizedBox(width: 4), Text(DateFormat('h:mm a').format(showtime.time), style: const TextStyle(color: Colors.white, fontSize: 14))]),
                          Text('₹${showtime.price.toInt()} per ticket', style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${showtime.availableSeats} seats available', style: TextStyle(color: showtime.availableSeats < 20 ? Colors.orange : Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSeatSelection(WidgetRef ref) {
    final selectedSeats = ref.watch(selectedSeatsProvider);
    final bookedSeats = ref.watch(bookedSeatsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Seats (${selectedSeats.length}/$_maxSeats)', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (selectedSeats.isNotEmpty) TextButton(onPressed: () => ref.read(selectedSeatsProvider.notifier).state = [], child: const Text('Clear All', style: TextStyle(color: Colors.red, fontSize: 14))),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                _buildScreen(),
                const SizedBox(height: 24),
                Column(
                  children: _rows.map((row) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20, child: Text(row, style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                            ...List.generate(10, (i) {
                              final seat = '$row${i + 1}';
                              final isBooked = bookedSeats.contains(seat);
                              final isSelected = selectedSeats.contains(seat);
                              return GestureDetector(
                                onTap: isBooked
                                    ? null
                                    : () {
                                        final seats = ref.read(selectedSeatsProvider.notifier);
                                        if (isSelected) {
                                          seats.state = seats.state.where((s) => s != seat).toList();
                                        } else if (seats.state.length < _maxSeats) {
                                          seats.state = [...seats.state, seat];
                                        } else {
                                          ScaffoldMessenger.of(ref.context).showSnackBar(SnackBar(content: Text('Max $_maxSeats seats'), backgroundColor: Colors.red));
                                        }
                                      },
                                child: Container(
                                  margin: const EdgeInsets.all(3),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(color: isBooked ? Colors.grey[700] : isSelected ? Colors.green : Colors.grey[800], borderRadius: BorderRadius.circular(4)),
                                  child: Center(child: Icon(isBooked ? Icons.close : isSelected ? Icons.check : null, size: 14, color: Colors.white)),
                                ),
                              );
                            }),
                          ],
                        ),
                      )).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegend('Available', Colors.grey[800]!),
                    const SizedBox(width: 16),
                    _buildLegend('Selected', Colors.green),
                    const SizedBox(width: 16),
                    _buildLegend('Booked', Colors.grey[700]!),
                  ],
                ),
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
        Container(width: double.infinity, height: 4, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.grey[800]!, Colors.white, Colors.grey[800]!]), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 8),
        Text('SCREEN', style: TextStyle(color: Colors.grey[600], fontSize: 12, letterSpacing: 2)),
      ],
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(children: [Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))), const SizedBox(width: 4), Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12))]);
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, ShowtimeModel showtime, List<String> seats) {
    final total = showtime.price * seats.length;
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${seats.length} Ticket${seats.length > 1 ? 's' : ''}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              Text('₹${total.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text('Seats: ${seats.join(", ")}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            ],
          ),
          ElevatedButton(
            onPressed: () => _showConfirmation(context, showtime, seats, total),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            child: const Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showConfirmation(BuildContext context, ShowtimeModel showtime, List<String> seats, double total) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Booking Confirmed!', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Movie: ${movie.title}', style: TextStyle(color: Colors.grey[400])),
            Text('Cinema: ${showtime.cinemaName}', style: TextStyle(color: Colors.grey[400])),
            Text('Time: ${DateFormat('MMM dd, h:mm a').format(showtime.time)}', style: TextStyle(color: Colors.grey[400])),
            Text('Tickets: ${seats.length}', style: TextStyle(color: Colors.grey[400])),
            Text('Seats: ${seats.join(", ")}', style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 8),
            Text('Total: ₹${total.toInt()}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: const Text('OK', style: TextStyle(color: Colors.red)))],
      ),
    );
  }
}
