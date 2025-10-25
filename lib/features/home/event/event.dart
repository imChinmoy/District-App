import 'dart:convert';
import 'package:district/features/home/event/categoryevent.dart';
import 'package:district/features/home/event/eventdetail.dart';
import 'package:district/models/event/artist_model.dart';
import 'package:district/models/event/event_model.dart';
import 'package:district/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final eventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final response = await rootBundle.loadString('assets/event/events.json');
  final data = json.decode(response);
  return (data['events'] as List).map((e) => EventModel.fromMap(e)).toList();
});

final artistsProvider = FutureProvider<List<ArtistModel>>((ref) async {
  final response = await rootBundle.loadString('assets/artists/artists.json');
  final data = json.decode(response);
  return (data['artists'] as List).map((a) => ArtistModel.fromMap(a)).toList();
});

class EventsScreen extends ConsumerWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);
    final artistsAsync = ref.watch(artistsProvider);

    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSectionHeading('Featured events'),
            const SizedBox(height: 24),
            _buildSection(context, eventsAsync, true),
            const SizedBox(height: 40),
            _buildSectionHeading('Artists in your District'),
            const SizedBox(height: 24),
            _buildArtistsSection(artistsAsync),
            const SizedBox(height: 40),
            _buildSectionHeading('Explore events'),
            const SizedBox(height: 24),
            _buildExploreCategories(context),
            const SizedBox(height: 40),
            _buildSectionHeading('All Events'),
            const SizedBox(height: 24),
            _buildSection(context, eventsAsync, false),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, AsyncValue<List<EventModel>> asyncData, bool isHorizontal) {
    return asyncData.when(
      data: (events) => events.isEmpty
          ? _buildMessage('No events available')
          : isHorizontal
              ? _buildHorizontalList(context, events)
              : _buildVerticalList(context, events),
      loading: () => _buildMessage('Loading...', isLoading: true),
      error: (e, _) => _buildMessage('Error: $e', isError: true),
    );
  }

  Widget _buildHorizontalList(BuildContext context, List<EventModel> events) {
    return SizedBox(
      height: 420,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: events.length,
        itemBuilder: (context, index) => EventCard(
          event: events[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventDetailPage(event: events[index])),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalList(BuildContext context, List<EventModel> events) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: events.length,
      itemBuilder: (context, index) => AllEventCard(
        event: events[index],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EventDetailPage(event: events[index])),
        ),
      ),
    );
  }

  Widget _buildArtistsSection(AsyncValue<List<ArtistModel>> asyncData) {
    return asyncData.when(
      data: (artists) => artists.isEmpty
          ? _buildMessage('No artists available')
          : SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: artists.length,
                itemBuilder: (context, index) => ArtistCard(artist: artists[index]),
              ),
            ),
      loading: () => _buildMessage('Loading...', isLoading: true),
      error: (e, _) => _buildMessage('Error: $e', isError: true),
    );
  }

  Widget _buildExploreCategories(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: [
          _buildCategoryCard(context, 'MUSIC', EventCategory.concert, '🎸', Colors.purple[700]!),
          _buildCategoryCard(context, 'NIGHTLIFE', null, '🪩', Colors.orange[700]!),
          _buildCategoryCard(context, 'COMEDY', EventCategory.standup, '🎤', Colors.amber[700]!),
          _buildCategoryCard(context, 'SPORTS', null, '🏟️', Colors.green[700]!),
          _buildCategoryCard(context, 'PERFORMANCES', EventCategory.exhibition, '🎭', Colors.pink[700]!),
          _buildCategoryCard(context, 'SOCIAL\nMIXERS', EventCategory.festival, '🥂', Colors.blue[700]!),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, EventCategory? category, String emoji, Color color) {
    return GestureDetector(
      onTap: () {
        if (category != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoryEventsPage(category: category, categoryName: title)),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(String message, {bool isLoading = false, bool isError = false}) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) CircularProgressIndicator(color: AppColors.events),
            if (isError) const Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: isLoading || isError ? 16 : 0),
            Text(message, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class AllEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const AllEventCard({Key? key, required this.event, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    event.images.isNotEmpty ? event.images[0] : 'assets/events/default.jpg',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Icon(Icons.event, color: Colors.white54, size: 60),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bookmark_border, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat('EEE, dd MMM, h:mm a').format(event.startDate),
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      const Spacer(),
                      const Icon(Icons.bookmark_border, color: Colors.white, size: 24),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.name,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[400], size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(color: Colors.green[700], borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          children: [
                            Text(
                              event.rating.toStringAsFixed(1),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.star, color: Colors.white, size: 12),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        event.price == 0 ? 'FREE Entry' : '₹${event.price.toInt()} onwards',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArtistCard extends StatelessWidget {
  final ArtistModel artist;

  const ArtistCard({Key? key, required this.artist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              artist.image,
              width: 160,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 160,
                height: 180,
                color: Colors.grey[800],
                child: const Icon(Icons.person, color: Colors.white54, size: 60),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 40,
            child: Text(
              artist.name,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
              child: const Icon(Icons.bookmark_border, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCard({Key? key, required this.event, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.asset(
                    event.images.isNotEmpty ? event.images[0] : 'assets/events/default.jpg',
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 280,
                      color: Colors.grey[800],
                      child: const Icon(Icons.event, color: Colors.white54, size: 80),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bookmark_border, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.name,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEE, dd MMM, h:mm a').format(event.startDate),
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
