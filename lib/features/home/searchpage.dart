import 'package:district/features/controllers/program_controller.dart';
import 'package:district/models/event/event_model.dart';
import 'package:district/models/event/artist_model.dart';
import 'package:district/models/dining/dining_model.dart';
import 'package:district/models/movie/movie_model.dart';
import 'package:district/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';


typedef FallbackImageBuilder = Widget Function();

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchEventsProvider = Provider<List<EventModel>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return [];

  return (ref.watch(eventProvider).value ?? []).where((e) => e.name.toLowerCase().contains(query) || e.location.toLowerCase().contains(query)).toList();

});

final searchMoviesProvider = Provider<List<MovieModel>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return [];
  return (ref.watch(movieProvider).value ?? [])
      .where((m) => m.title.toLowerCase().contains(query) || m.genre.toLowerCase().contains(query))
      .toList();
});

final searchDiningProvider = Provider<List<DiningModel>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return [];
  return (ref.watch(diningProvider).value ?? [])
      .where((r) => r.name.toLowerCase().contains(query) || r.address.toLowerCase().contains(query))
      .toList();
});

final searchArtistsProvider = Provider<List<ArtistModel>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  if (query.isEmpty) return [];
  return (ref.watch(artistProvider).value ?? [])
      .where((a) => a.name.toLowerCase().contains(query))
      .toList();
});

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(eventProvider).isLoading;
    final searchEvents = ref.watch(searchEventsProvider);
    final searchMovies = ref.watch(searchMoviesProvider);
    final searchDining = ref.watch(searchDiningProvider);
    final searchArtists = ref.watch(searchArtistsProvider);

    final hasResults = searchEvents.isNotEmpty || searchMovies.isNotEmpty || 
                       searchDining.isNotEmpty || searchArtists.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search events, movies, restaurants...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
            setState(() {});
          },
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: AppColors.foryou))
          : _searchController.text.isEmpty
              ? _EmptySearch()
              : !hasResults
                  ? _NoResults()
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          if (searchEvents.isNotEmpty) ...[
                            _SectionHeader('Events', searchEvents.length),
                            _EventsList(searchEvents),
                          ],
                          if (searchMovies.isNotEmpty) ...[
                            _SectionHeader('Movies', searchMovies.length),
                            _MoviesList(searchMovies),
                          ],
                          if (searchDining.isNotEmpty) ...[
                            _SectionHeader('Restaurants', searchDining.length),
                            _DiningList(searchDining),
                          ],
                          if (searchArtists.isNotEmpty) ...[
                            _SectionHeader('Artists', searchArtists.length),
                            _ArtistsList(searchArtists),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
    );
  }
}


class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader(this.title, this.count);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text('$count results', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  final List<EventModel> events;
  const _EventsList(this.events);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: events.length,
      itemBuilder: (_, index) => _EventCard(events[index]),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  const _EventCard(this.event);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/events/detail', extra: event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: _ImageLoader(
                imageUrl: event.images.isNotEmpty ? event.images[0] : null,
                height: 100,
                width: 100,
                fallbackIcon: Icons.event,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey[500], size: 14),
                        const SizedBox(width: 4),
                        Expanded(child: Text(event.location, style: TextStyle(color: Colors.grey[400], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.events.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                      child: Text(event.category.name.toUpperCase(), style: TextStyle(color: AppColors.events, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoviesList extends StatelessWidget {
  final List<MovieModel> movies;
  const _MoviesList(this.movies);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: movies.length,
      itemBuilder: (_, index) => _MovieCard(movies[index]),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final MovieModel movie;
  const _MovieCard(this.movie);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/movies/detail', extra: movie),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: _ImageLoader(
                imageUrl: movie.posterUrls.isNotEmpty ? movie.posterUrls[0] : null,
                height: 120,
                width: 80,
                fallbackIcon: Icons.movie,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(movie.genre, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(movie.averageRating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.movies.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                          child: Text(movie.language.toUpperCase(), style: TextStyle(color: AppColors.movies, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _DiningList extends StatelessWidget {
  final List<DiningModel> restaurants;
  const _DiningList(this.restaurants);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: restaurants.length,
      itemBuilder: (_, index) => _DiningCard(restaurants[index]),
    );
  }
}

class _DiningCard extends StatelessWidget {
  final DiningModel restaurant;
  const _DiningCard(this.restaurant);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/dining/detail', extra: restaurant),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: _ImageLoader(
                imageUrl: restaurant.images.isNotEmpty ? restaurant.images[0] : null,
                height: 100,
                width: 100,
                fallbackIcon: Icons.restaurant,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(restaurant.rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 13)),
                        const SizedBox(width: 12),
                        Text('₹${restaurant.averageCostForTwo.toInt()} for 2', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(restaurant.city, style: TextStyle(color: Colors.grey[500], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ArtistsList extends StatelessWidget {
  final List<ArtistModel> artists;
  const _ArtistsList(this.artists);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: artists.length,
        itemBuilder: (_, index) => _ArtistCard(artists[index]),
      ),
    );
  }
}

class _ArtistCard extends StatelessWidget {
  final ArtistModel artist;
  const _ArtistCard(this.artist);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: _ImageLoader(imageUrl: artist.imageUrl, height: 80, width: 80, fallbackIcon: Icons.person),
          ),
          const SizedBox(height: 8),
          Text(artist.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}


class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text('Search for events, movies,\nrestaurants & more', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text('No results found', style: TextStyle(color: Colors.grey[500], fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Try searching with different keywords', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }
}


class _ImageLoader extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double width;
  final IconData fallbackIcon;

  const _ImageLoader({
    required this.imageUrl,
    required this.height,
    this.width = double.infinity,
    this.fallbackIcon = Icons.image_not_supported_outlined,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(height: height, width: width, color: Colors.grey[800], child: Icon(fallbackIcon, color: Colors.white54, size: 30));
    }

    final isNetwork = imageUrl!.startsWith('http');
    final ImageProvider imageProvider = isNetwork ? NetworkImage(imageUrl!) : AssetImage(imageUrl!) as ImageProvider;

    return Image(
      image: imageProvider,
      fit: BoxFit.cover,
      height: height,
      width: width,
      errorBuilder: (_, __, ___) => Container(height: height, width: width, color: Colors.grey[800], child: Icon(fallbackIcon, color: Colors.white54, size: 30)),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(height: height, width: width, color: Colors.grey[800], child: Center(child: CircularProgressIndicator(color: AppColors.foryou, strokeWidth: 2)));
      },
    );
  }
}