import 'package:district/features/controllers/program_controller.dart';
import 'package:district/features/home/event/eventdetail.dart';
import 'package:district/features/home/for_you/for_you.dart';
import 'package:district/models/event/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';


final categoryEventsProvider = Provider.family<List<EventModel>, EventCategory>((ref, category) {
  final events = ref.watch(eventProvider).value ?? [];
  return events.where((e) => e.category == category).toList();
});

class CategoryEventsPage extends ConsumerWidget {
  final EventCategory category;
  final String categoryName;

  const CategoryEventsPage({
    Key? key,
    required this.category,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventProvider);
    final filteredEvents = ref.watch(categoryEventsProvider(category));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(categoryName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: eventsAsync.when(
        data: (_) => filteredEvents.isEmpty ? _buildEmptyState() : _buildEventsList(filteredEvents, context),
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.green)),
        error: (_, __) => const Center(child: Text('Error loading events', style: TextStyle(color: Colors.white))),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, color: Colors.grey, size: 80),
          const SizedBox(height: 16),
          Text('No ${categoryName.toLowerCase()} events available', style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<EventModel> events, BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (_, index) => GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailPage(event: events[index]))),
        child: _buildEventCard(events[index]),
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Image.asset(
              event.images.isNotEmpty ? event.images[0] : '',
              width: 120,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 120, height: 140, color: Colors.grey[800], child: const Icon(Icons.event, color: Colors.white54, size: 40)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _getCategoryColor(), borderRadius: BorderRadius.circular(12)),
                    child: Text(_getCategoryName(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Text(event.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Expanded(child: Text(event.location, style: TextStyle(color: Colors.grey[400], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text(DateFormat('MMM dd, yyyy').format(event.startDate), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(event.price == 0 ? 'FREE' : '₹${event.price.toInt()}', style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(event.rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName() {
    switch (category) {
      case EventCategory.concert:
        return 'CONCERT';
      case EventCategory.exhibition:
        return 'EXHIBITION';
      case EventCategory.standup:
        return 'STAND-UP';
      case EventCategory.festival:
        return 'FESTIVAL';
    }
  }

  Color _getCategoryColor() {
    switch (category) {
      case EventCategory.concert:
        return Colors.purple[700]!;
      case EventCategory.exhibition:
        return Colors.blue[700]!;
      case EventCategory.standup:
        return Colors.orange[700]!;
      case EventCategory.festival:
        return Colors.pink[700]!;
    }
  }
}
