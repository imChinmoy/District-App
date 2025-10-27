import 'package:district/features/home/for_you/for_you.dart';
import 'package:district/models/event/event_model.dart';
import 'package:district/models/movie/movie_model.dart';
import 'package:district/models/dining/dining_model.dart';
import 'package:district/models/event/artist_model.dart';
import 'package:district/features/home/event/eventdetail.dart';
import 'package:district/features/home/movies/moviedetail.dart';
import 'package:district/features/home/dining/rest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredEventsProvider = Provider<List<EventModel>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return [];
  return (ref.watch(eventsProvider).value ?? []).where((e) => e.name.toLowerCase().contains(query) || e.location.toLowerCase().contains(query)).toList();
});

final filteredMoviesProvider = Provider<List<MovieModel>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return [];
  return (ref.watch(moviesProvider).value ?? []).where((m) => m.title.toLowerCase().contains(query) || m.genre.toLowerCase().contains(query)).toList();
});

final filteredRestaurantsProvider = Provider<List<DiningModel>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return [];
  return (ref.watch(restaurantsProvider).value ?? []).where((r) => r.name.toLowerCase().contains(query) || r.address.toLowerCase().contains(query)).toList();
});

final filteredArtistsProvider = Provider<List<ArtistModel>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return [];
  return (ref.watch(artistsProvider).value ?? []).where((a) => a.name.toLowerCase().contains(query)).toList();
});

class SearchPage extends ConsumerWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final events = ref.watch(filteredEventsProvider);
    final movies = ref.watch(filteredMoviesProvider);
    final restaurants = ref.watch(filteredRestaurantsProvider);
    final artists = ref.watch(filteredArtistsProvider);
    final loading = ref.watch(eventsProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: InputBorder.none,
            suffixIcon: query.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () => ref.read(searchQueryProvider.notifier).state = '') : null,
          ),
          onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
        ),
      ),
      body: loading ? const Center(child: CircularProgressIndicator(color: Colors.blue)) : _buildBody(context, query, events, movies, restaurants, artists),
    );
  }

  Widget _buildBody(BuildContext context, String query, List<EventModel> events, List<MovieModel> movies, List<DiningModel> restaurants, List<ArtistModel> artists) {
    if (query.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search, size: 80, color: Colors.grey[700]), const SizedBox(height: 16), Text('Search...', style: TextStyle(color: Colors.grey[600]))]));
    
    final hasResults = events.isNotEmpty || movies.isNotEmpty || restaurants.isNotEmpty || artists.isNotEmpty;
    if (!hasResults) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off, size: 80, color: Colors.grey[700]), const SizedBox(height: 16), const Text('No results', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (events.isNotEmpty) ...[Text('Events (${events.length})', 
          style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), 
            const SizedBox(height: 12),
            ...events.map((e) => _card(context, e.images.isNotEmpty ? 
            e.images[0] : 
            '', e.name, '${DateFormat('dd MMM').format(e.startDate)} • ${e.location}', () => 
            Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailPage(event: e))), 80))],
          if (movies.isNotEmpty) ...[const SizedBox(height: 24), 
          Text('Movies (${movies.length})', 
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), 
          const SizedBox(height: 12),
           ...movies.map((m) => _card(context, m.posterUrls.isNotEmpty ? 
           m.posterUrls[0] : 
           '', m.title, '${m.rating} • ${m.genre}', 
           () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailPage(movie: m))), 60, height: 90))],
          if (restaurants.isNotEmpty) ...[const SizedBox(height: 24), 
          Text('Restaurants (${restaurants.length})', 
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), 
          const SizedBox(height: 12), 
          ...restaurants.map((r) => _card(context, r.images.isNotEmpty ?
          r.images[0] : 
          '', r.name, r.address, () => 
          Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantDetailPage(restaurant: r))), 80))],
          if (artists.isNotEmpty) ...[const SizedBox(height: 24), 
          Text('Artists (${artists.length})', 
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), 
          const SizedBox(height: 12), ...artists.map((a) => _card(context, a.imageUrl, a.name, '', null, 60, circular: true))],
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String img, String title, String subtitle, VoidCallback? onTap, double size, {double? height, bool circular = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(circular ? size / 2 : 8),
              child: Image.asset(img, width: size, height: height ?? size, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: size, height: height ?? size, color: Colors.grey[800], child: const Icon(Icons.image, color: Colors.white54))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis), if (subtitle.isNotEmpty) ...[const SizedBox(height: 4), Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)]])),
          ],
        ),
      ),
    );
  }
}
