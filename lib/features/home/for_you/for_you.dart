import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:district/features/home/dining/rest.dart';
import 'package:district/features/home/movies/moviedetail.dart';
import 'package:district/models/event/event_model.dart';
import 'package:district/models/movie/movie_model.dart';
import 'package:district/models/dining/dining_model.dart';
import 'package:district/models/event/artist_model.dart';
import 'package:district/features/home/event/eventdetail.dart';
import 'package:district/features/home/event/categoryevent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Providers
final eventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final response = await rootBundle.loadString('assets/event/events.json');
  final data = json.decode(response);
  return (data['events'] as List).map((e) => EventModel.fromMap(e)).toList();
});

final moviesProvider = FutureProvider<List<MovieModel>>((ref) async {
  final response = await rootBundle.loadString('assets/movies/movies.json');
  final data = json.decode(response);
  return (data['movies'] as List).map((m) => MovieModel.fromMap(m)).toList();
});

final restaurantsProvider = FutureProvider<List<DiningModel>>((ref) async {
  final response = await rootBundle.loadString('assets/restaurant/restaurants.json');
  final data = json.decode(response);
  return (data['restaurants'] as List).map((r) => DiningModel.fromMap(r)).toList();
});

final artistsProvider = FutureProvider<List<ArtistModel>>((ref) async {
  final response = await rootBundle.loadString('assets/artists/artists.json');
  final data = json.decode(response);
  return (data['artists'] as List).map((a) => ArtistModel.fromMap(a)).toList();
});

final moodsProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final response = await rootBundle.loadString('assets/dining/mood.json');
  final data = json.decode(response);
  return (data['categories'] as List).map((m) => {
    'title': m['title'].toString(),
    'imagePath': m['imagePath'].toString(),
  }).toList();
});

class ForYouScreen extends ConsumerStatefulWidget {
  const ForYouScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends ConsumerState<ForYouScreen> {
  int _eventIndex = 0;
  int _movieIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('IN THE SPOTLIGHT', ref.watch(eventsProvider), (events) => _buildEventCarousel(events)),
            _buildSection('BLOCKBUSTER RELEASE', ref.watch(moviesProvider), (movies) => _buildMovieCarousel(movies)),
            _buildSection('TRENDING THIS WEEK', ref.watch(restaurantsProvider), (data) => _buildRestaurants(data)),
            _buildSection('IN THE MOOD FOR', ref.watch(moodsProvider), (moods) => _buildMoods(moods)),
            const SizedBox(height: 40),
            _buildSectionHeading('EXPLORE EVENTS'),
            const SizedBox(height: 20),
            _buildExploreEvents(),
            _buildSection('ARTISTS IN YOUR DISTRICT', ref.watch(artistsProvider), (artists) => _buildArtists(artists)),
            _buildSection('SCREENINGS', ref.watch(moviesProvider), (movies) => _buildScreenings(movies)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection<T>(String title, AsyncValue<List<T>> asyncData, Widget Function(List<T>) builder) {
    return Column(
      children: [
        const SizedBox(height: 40),
        _buildSectionHeading(title),
        const SizedBox(height: 20),
        asyncData.when(
          data: (data) => data.isNotEmpty ? builder(data) : const SizedBox(),
          loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.blue))),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildSectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildDivider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5),
            ),
          ),
          Expanded(child: _buildDivider(reverse: true)),
        ],
      ),
    );
  }

  Widget _buildDivider({bool reverse = false}) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            reverse ? Colors.grey.withOpacity(0.3) : Colors.transparent,
            reverse ? Colors.transparent : Colors.grey.withOpacity(0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCarousel(List<EventModel> events) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: events.length,
          options: CarouselOptions(
            height: 500,
            viewportFraction: 0.88,
            enlargeCenterPage: true,
            enlargeFactor: 0.15,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (index, _) => setState(() => _eventIndex = index),
          ),
          itemBuilder: (_, index, __) => _buildCard(
            image: events[index].images.isNotEmpty ? events[index].images[0] : '',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailPage(event: events[index]))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('EEE, dd MMM, h:mm a').format(events[index].startDate), style: TextStyle(color: Colors.grey[300], fontSize: 13)),
                const SizedBox(height: 8),
                Text(events[index].name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), maxLines: 2),
                const SizedBox(height: 8),
                Text(events[index].location, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildIndicators(_eventIndex, events.length),
      ],
    );
  }

  Widget _buildMovieCarousel(List<MovieModel> movies) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: movies.length,
          options: CarouselOptions(
            height: 480,
            viewportFraction: 0.88,
            enlargeCenterPage: true,
            enlargeFactor: 0.15,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, _) => setState(() => _movieIndex = index),
          ),
          itemBuilder: (_, index, __) => _buildCard(
            image: movies[index].posterUrls.isNotEmpty ? movies[index].posterUrls[0] : '',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailPage(movie: movies[index]))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movies[index].title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), maxLines: 2),
                const SizedBox(height: 8),
                Text('${movies[index].rating} | ${movies[index].language}', style: TextStyle(color: Colors.grey[300], fontSize: 13)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailPage(movie: movies[index]))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Book tickets', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildIndicators(_movieIndex, movies.length),
      ],
    );
  }

  Widget _buildCard({required String image, required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 10)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[800])),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(bottom: 20, left: 20, right: 20, child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurants(List<DiningModel> restaurants) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: restaurants.length,
        itemBuilder: (_, index) {
          final r = restaurants[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantDetailPage(restaurant: r))),
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(r.images.isNotEmpty ? r.images[0] : '', height: 180, width: 200, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 180, color: Colors.grey[800])),
                  ),
                  const SizedBox(height: 8),
                  Text(r.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(r.address, style: TextStyle(color: Colors.grey[400], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoods(List<Map<String, String>> moods) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: moods.length,
        itemBuilder: (_, index) {
          final m = moods[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    m['imagePath']!,
                    height: 100,
                    width: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 100, width: 120, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.restaurant, color: Colors.white54, size: 40)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(m['title']!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExploreEvents() {
    final categories = [
      {'name': 'MUSIC', 'emoji': '🎸', 'color': const Color(0xFF9B59B6), 'category': EventCategory.concert},
      {'name': 'NIGHTLIFE', 'emoji': '🪩', 'color': const Color(0xFFE67E22), 'category': EventCategory.festival},
      {'name': 'COMEDY', 'emoji': '🎤', 'color': const Color(0xFFF39C12), 'category': EventCategory.standup},
      {'name': 'SOCIAL MIXERS', 'emoji': '🥂', 'color': const Color(0xFF3498DB), 'category': EventCategory.exhibition},
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final c = categories[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryEventsPage(category: c['category'] as EventCategory, categoryName: c['name'] as String))),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[800]!, width: 1)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(c['emoji'] as String, style: const TextStyle(fontSize: 50)),
                  const SizedBox(height: 12),
                  Text(c['name'] as String, style: TextStyle(color: c['color'] as Color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5), textAlign: TextAlign.center, maxLines: 2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArtists(List<ArtistModel> artists) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: artists.length,
        itemBuilder: (_, index) {
          final a = artists[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset(a.image, height: 120, width: 120, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 120, width: 120, decoration: BoxDecoration(color: Colors.grey[800], shape: BoxShape.circle))),
                ),
                const SizedBox(height: 8),
                Text(a.name, style: const TextStyle(color: Colors.white, fontSize: 13), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScreenings(List<MovieModel> movies) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 12, mainAxisSpacing: 16),
        itemCount: movies.length > 6 ? 6 : movies.length,
        itemBuilder: (_, index) {
          final m = movies[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailPage(movie: m))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(m.posterUrls.isNotEmpty ? m.posterUrls[0] : '', fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => Container(color: Colors.grey[800])))),
                const SizedBox(height: 8),
                Text(m.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2),
                Text('${m.rating} | ${m.language}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndicators(int current, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) => Container(
        width: current == index ? 20 : 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: current == index ? Colors.white : Colors.white.withOpacity(0.4)),
      )),
    );
  }
}
