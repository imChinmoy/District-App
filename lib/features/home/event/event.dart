import 'dart:convert';
import 'package:district/features/controllers/program_controller.dart';
import 'package:district/features/home/event/categoryevent.dart';
import 'package:district/features/home/event/eventdetail.dart';
import 'package:district/models/event/artist_model.dart';
import 'package:district/models/event/event_model.dart';
import 'package:district/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Assuming eventProvider and artistProvider are FutureProviders defined in program_controller.dart

typedef FallbackImageBuilder = Widget Function();

// ----------------------- MAIN SCREEN -----------------------

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventProvider);
    final artistsAsync = ref.watch(artistProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        color: AppColors.events,
        onRefresh: () async {
          ref.invalidate(eventProvider);
          ref.invalidate(artistProvider);
          await Future.wait([
            ref.read(eventProvider.future),
            ref.read(artistProvider.future),
          ]);
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const _SectionHeading('FEATURED EVENTS'),
              const SizedBox(height: 24),
              _EventListSection(asyncData: eventsAsync, isHorizontal: true),
              const SizedBox(height: 40),
              const _SectionHeading('ARTISTS IN YOUR DISTRICT'),
              const SizedBox(height: 24),
              _ArtistSection(artistsAsync: artistsAsync),
              const SizedBox(height: 40),
              const _SectionHeading('EXPLORE EVENTS'),
              const SizedBox(height: 24),
              const _ExploreCategoriesGrid(),
              const SizedBox(height: 40),
              const _SectionHeading('ALL EVENTS'),
              const SizedBox(height: 24),
              _EventListSection(asyncData: eventsAsync, isHorizontal: false),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------- UTILITY COMPONENTS -----------------------

class _SectionHeading extends StatelessWidget {
  final String title;
  
  const _SectionHeading(this.title);

  Widget _buildDivider({bool reverse = false}) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            reverse ? Colors.grey.withOpacity(0.5) : Colors.transparent,
            reverse ? Colors.transparent : Colors.grey.withOpacity(0.5),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(child: _buildDivider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
          ),
          Expanded(child: _buildDivider(reverse: true)),
        ],
      ),
    );
  }
}

class _MessageWidget extends StatelessWidget {
  final String message;
  final bool isLoading;
  final bool isError;

  const _MessageWidget({
    required this.message,
    this.isLoading = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)  CircularProgressIndicator(color: AppColors.events),
            if (isError)
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: isLoading || isError ? 16 : 0),
            Text(message, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// ⭐️ CRITICAL FIX: Robust Image Loader
class _ImageLoader extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double width;
  final BoxFit fit;
  final FallbackImageBuilder fallbackImage; 

  const _ImageLoader({
    required this.imageUrl,
    required this.height,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.fallbackImage = _defaultFallbackImage, 
  });

  // Default Fallback Image with Icon
  static Widget _defaultFallbackImage() {
    return Container(
      color: Colors.grey.shade800,
      child: const Icon(Icons.event, color: Colors.white54, size: 60),
    );
  }
  
  // Alternative fallback for debugging broken asset paths
  static Widget _debugFallbackImage(String? path) {
    return Container(
      color: Colors.red.shade900,
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          'Image Failed\nPath: ${path ?? "null"}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
          maxLines: 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return SizedBox(height: height, width: width, child: fallbackImage());
    }

    final String path = imageUrl!;
    final bool isNetwork = path.startsWith('http');
    
    // Check for common asset path issue: If it's not a network URL, 
    // it must be a valid asset path defined in pubspec.yaml.
    final ImageProvider imageProvider = isNetwork
        ? NetworkImage(path)
        : AssetImage(path);

    return Image(
      image: imageProvider,
      fit: fit,
      height: height,
      width: width,
      errorBuilder: (context, error, stackTrace) {
        // Use the debug fallback to see if the path is the issue
        return SizedBox(
          height: height, 
          width: width, 
          child: _debugFallbackImage(path), 
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          width: width,
          color: Colors.grey.shade800,
          child:  Center(
            child: CircularProgressIndicator(color: AppColors.events),
          ),
        );
      },
    );
  }
}

// ----------------------- DATA-DRIVEN SECTIONS -----------------------

class _EventListSection extends StatelessWidget {
  final AsyncValue<List<EventModel>> asyncData;
  final bool isHorizontal;
  
  const _EventListSection({required this.asyncData, required this.isHorizontal});

  @override
  Widget build(BuildContext context) {
    return asyncData.when(
      data: (events) => events.isEmpty
          ? const _MessageWidget(message: 'No events available')
          : isHorizontal
              ? _buildHorizontalList(context, events)
              : _buildVerticalList(context, events),
      loading: () => const _MessageWidget(message: 'Loading events...', isLoading: true),
      error: (e, _) => _MessageWidget(message: 'Error loading events: ${e.toString()}', isError: true),
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
}

class _ArtistSection extends StatelessWidget {
  final AsyncValue<List<ArtistModel>> artistsAsync;

  const _ArtistSection({required this.artistsAsync});

  @override
  Widget build(BuildContext context) {
    return artistsAsync.when(
      data: (artists) => artists.isEmpty
          ? const _MessageWidget(message: 'No artists available')
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
      loading: () => const _MessageWidget(message: 'Loading artists...', isLoading: true),
      error: (e, _) => _MessageWidget(message: 'Error loading artists: ${e.toString()}', isError: true),
    );
  }
}

class _ExploreCategoriesGrid extends StatelessWidget {
  const _ExploreCategoriesGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
        children: const [
          _CategoryCard(title: 'MUSIC', category: EventCategory.concert, emoji: '🎸', color: Color(0xFF9C27B0)),
          _CategoryCard(title: 'NIGHTLIFE', category: null, emoji: '🪩', color: Color(0xFFF57C00)),
          _CategoryCard(title: 'COMEDY', category: EventCategory.standup, emoji: '🎤', color: Color(0xFFFFB300)),
          _CategoryCard(title: 'SPORTS', category: null, emoji: '🏟️', color: Color(0xFF388E3C)),
          _CategoryCard(title: 'PERFORMANCES', category: EventCategory.exhibition, emoji: '🎭', color: Color(0xFFC2185B)),
          _CategoryCard(title: 'SOCIAL\nMIXERS', category: EventCategory.festival, emoji: '🥂', color: Color(0xFF1976D2)),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final EventCategory? category;
  final String emoji;
  final Color color;

  const _CategoryCard({required this.title, this.category, required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (category != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoryEventsPage(category:category! , categoryName: title)),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade800),
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
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------- CARD WIDGETS -----------------------

class AllEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const AllEventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imagePath = event.images.isNotEmpty ? event.images[0] : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color: Colors.grey[900], 
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  // ⭐️ Using the robust image loader
                  child: _ImageLoader(
                    imageUrl: imagePath,
                    height: 200,
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
                  Text(
                    DateFormat('EEE, dd MMM, h:mm a').format(event.startDate),
                    style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w600),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.events, borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      event.price == 0 ? 'FREE' : '₹${event.price.toInt()} ONWARDS',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
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

  const ArtistCard({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            // ⭐️ Using the robust image loader for artists
            child: _ImageLoader(
              imageUrl: artist.image,
              height: 180,
              width: 160,
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
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  artist.category,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imagePath = event.images.isNotEmpty ? event.images[0] : null;

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
                  // ⭐️ Using the robust image loader
                  child: _ImageLoader(
                    imageUrl: imagePath,
                    height: 280,
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

// enum EventCategory { concert, exhibition, standup, festival }