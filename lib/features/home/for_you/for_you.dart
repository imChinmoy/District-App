import 'package:district/features/controllers/program_controller.dart';
import 'package:district/models/event/event_model.dart';
import 'package:district/models/event/artist_model.dart';
import 'package:district/models/dining/dining_model.dart';
import 'package:district/models/movie/movie_model.dart';
import 'package:district/models/mood_model.dart';
import 'package:district/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

typedef FallbackImageBuilder = Widget Function();

class ForYouScreen extends ConsumerWidget {
  const ForYouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        color: AppColors.foryou,
        onRefresh: () async {
          ref.invalidate(eventProvider);
          ref.invalidate(movieProvider);
          ref.invalidate(diningProvider);
          ref.invalidate(artistProvider);
          ref.invalidate(diningTypeProvider);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const _SectionHeading('IN THE SPOTLIGHT'),
                  const SizedBox(height: 16),
                  _EventsSection(ref.watch(eventProvider)),
                  const SizedBox(height: 32),
                  const _SectionHeading('TOP MOVIES NEAR YOU'),
                  const SizedBox(height: 16),
                  _MoviesSection(ref.watch(movieProvider)),
                  const SizedBox(height: 32),
                  const _SectionHeading('NOW TRENDING'),
                  const SizedBox(height: 16),
                  _DiningSection(ref.watch(diningProvider)),
                  const SizedBox(height: 32),
                  const _SectionHeading('ARTISTS IN YOUR DISTRICT'),
                  const SizedBox(height: 16),
                  _ArtistsSection(ref.watch(artistProvider)),
                  const SizedBox(height: 32),
                  const _SectionHeading('IN THE MOOD FOR'),
                  const SizedBox(height: 16),
                  _MoodsSection(ref.watch(diningTypeProvider)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Section Heading
class _SectionHeading extends StatelessWidget {
  final String title;
  const _SectionHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2)),
          ),
          Expanded(child: _Divider(reverse: true)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool reverse;
  const _Divider({this.reverse = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [reverse ? Colors.grey.withOpacity(0.5) : Colors.transparent, reverse ? Colors.transparent : Colors.grey.withOpacity(0.5)],
        ),
      ),
    );
  }
}

// Events Section
class _EventsSection extends StatelessWidget {
  final AsyncValue<List<EventModel>> eventsAsync;
  const _EventsSection(this.eventsAsync);

  @override
  Widget build(BuildContext context) {
    return eventsAsync.when(
      data: (events) => events.isEmpty
          ? const _EmptyState('No events available')
          : SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: events.take(10).length,
                itemBuilder: (_, index) => _EventCard(events[index]),
              ),
            ),
      loading: () => const _LoadingShimmer(),
      error: (_, __) => const _EmptyState('Failed to load events'),
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
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: _ImageLoader(imageUrl: event.images.isNotEmpty ? event.images[0] : null, height: 140, width: 160, fallbackIcon: Icons.event),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(event.location, style: TextStyle(color: Colors.grey[400], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Movies Section
class _MoviesSection extends StatelessWidget {
  final AsyncValue<List<MovieModel>> moviesAsync;
  const _MoviesSection(this.moviesAsync);

  @override
  Widget build(BuildContext context) {
    return moviesAsync.when(
      data: (movies) => movies.isEmpty
          ? const _EmptyState('No movies available')
          : SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: movies.take(10).length,
                itemBuilder: (_, index) => _MovieCard(movies[index]),
              ),
            ),
      loading: () => const _LoadingShimmer(),
      error: (_, __) => const _EmptyState('Failed to load movies'),
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
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: _ImageLoader(imageUrl: movie.posterUrls.isNotEmpty ? movie.posterUrls[0] : null, height: 160, width: 140, fallbackIcon: Icons.movie),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(movie.averageRating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 12)),
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

// Dining Section
class _DiningSection extends StatelessWidget {
  final AsyncValue<List<DiningModel>> diningAsync;
  const _DiningSection(this.diningAsync);

  @override
  Widget build(BuildContext context) {
    return diningAsync.when(
      data: (restaurants) => restaurants.isEmpty
          ? const _EmptyState('No restaurants available')
          : SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: restaurants.take(10).length,
                itemBuilder: (_, index) => _DiningCard(restaurants[index]),
              ),
            ),
      loading: () => const _LoadingShimmer(),
      error: (_, __) => const _EmptyState('Failed to load restaurants'),
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
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: _ImageLoader(imageUrl: restaurant.images.isNotEmpty ? restaurant.images[0] : null, height: 140, width: 180, fallbackIcon: Icons.restaurant),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(restaurant.rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 12)),
                      const Spacer(),
                      Text('₹${restaurant.averageCostForTwo.toInt()} for 2', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(restaurant.city, style: TextStyle(color: Colors.grey[500], fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Artists Section
class _ArtistsSection extends StatelessWidget {
  final AsyncValue<List<ArtistModel>> artistsAsync;
  const _ArtistsSection(this.artistsAsync);

  @override
  Widget build(BuildContext context) {
    return artistsAsync.when(
      data: (artists) => artists.isEmpty
          ? const _EmptyState('No artists available')
          : SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: artists.take(10).length,
                itemBuilder: (_, index) => _ArtistCard(artists[index]),
              ),
            ),
      loading: () => const _LoadingShimmer(),
      error: (_, __) => const _EmptyState('Failed to load artists'),
    );
  }
}

class _ArtistCard extends StatelessWidget {
  final ArtistModel artist;
  const _ArtistCard(this.artist);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(60), child: _ImageLoader(imageUrl: artist.imageUrl, height: 100, width: 100, fallbackIcon: Icons.person)),
          const SizedBox(height: 8),
          Text(artist.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          Text(artist.category, style: TextStyle(color: Colors.grey[400], fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// Moods Section
class _MoodsSection extends StatelessWidget {
  final AsyncValue<List<MoodCategory>> moodsAsync;
  const _MoodsSection(this.moodsAsync);

  @override
  Widget build(BuildContext context) {
    return moodsAsync.when(
      data: (moods) => moods.isEmpty
          ? const _EmptyState('No moods available')
          : SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: moods.take(10).length,
                itemBuilder: (_, index) => _MoodCard(moods[index]),
              ),
            ),
      loading: () => const _LoadingShimmer(),
      error: (_, __) => const _EmptyState('Failed to load moods'),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final MoodCategory mood;
  const _MoodCard(this.mood);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ImageLoader(imageUrl: mood.imageUrl, height: 140, width: 130, fallbackIcon: Icons.favorite),
            Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]))),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(mood.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widgets
class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: AppColors.foryou)));
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState(this.message);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 200, child: Center(child: Text(message, style: const TextStyle(color: Colors.white70))));
  }
}

// Image Loader
class _ImageLoader extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double width;
  final IconData fallbackIcon;

  const _ImageLoader({required this.imageUrl, required this.height, this.width = double.infinity, this.fallbackIcon = Icons.image_not_supported_outlined});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(height: height, width: width, color: Colors.grey[800], child: Icon(fallbackIcon, color: Colors.white54, size: 40));
    }

    final isNetwork = imageUrl!.startsWith('http');
    final ImageProvider imageProvider = isNetwork ? NetworkImage(imageUrl!) : AssetImage(imageUrl!) as ImageProvider;

    return Image(
      image: imageProvider,
      fit: BoxFit.cover,
      height: height,
      width: width,
      errorBuilder: (_, __, ___) => Container(height: height, width: width, color: Colors.grey[800], child: Icon(fallbackIcon, color: Colors.white54, size: 40)),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(height: height, width: width, color: Colors.grey[800], child: Center(child: CircularProgressIndicator(color: AppColors.foryou, strokeWidth: 2)));
      },
    );
  }
}
