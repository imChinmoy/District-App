import 'package:carousel_slider/carousel_slider.dart';
import 'package:district/features/controllers/program_controller.dart';
import 'package:district/features/home/movies/moviedetail.dart';
import 'package:district/models/movie/movie_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class MoviesScreen extends ConsumerWidget {
  const MoviesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final moviesAsync = ref.watch(movieProvider); 

    return Container(
      color: Colors.black,
      child: moviesAsync.when(
        data: (movies) {
          if (movies.isEmpty) {
            return const ErrorMessageWrapper(error: 'No movies found.', isRetryable: true);
          }
          return MovieContent(movies: movies);
        },
        loading: () => const LoadingMessageWrapper(),
        error: (e, stack) => ErrorMessageWrapper(error: e.toString(), isRetryable: true),
      ),
    );
  }
}


class LoadingMessageWrapper extends StatelessWidget {
  const LoadingMessageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFE50914)),
            SizedBox(height: 16),
            Text('Loading...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class ErrorMessageWrapper extends ConsumerWidget {
  final Object error;
  final bool isRetryable;
  const ErrorMessageWrapper({super.key, required this.error, this.isRetryable = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE50914), size: 48),
            const SizedBox(height: 16),
            Text('Error: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
            if (isRetryable) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(movieProvider), 
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
                child: const Text('Try Again', style: TextStyle(color: Colors.white)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}


class MovieContent extends ConsumerStatefulWidget {
  final List<MovieModel> movies;
  const MovieContent({super.key, required this.movies});

  @override
  ConsumerState<MovieContent> createState() => _MovieContentState();
}

class _MovieContentState extends ConsumerState<MovieContent> {
  int _currentIndex = 0;
  final CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    final movies = widget.movies;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildSectionHeading('IN THE SPOTLIGHT'),
          const SizedBox(height: 20),
          _buildSpotlightCarousel(movies),
          const SizedBox(height: 40),
          _buildSectionHeading('ONLY IN THEATRES'),
          const SizedBox(height: 20),
          _buildMoviesGrid(movies),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title) {
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
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
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
            reverse ? Colors.grey.withOpacity(0.5) : Colors.transparent,
            reverse ? Colors.transparent : Colors.grey.withOpacity(0.5),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotlightCarousel(List<MovieModel> movies) {
    if (movies.isEmpty) return const SizedBox.shrink();
    final CarouselSliderController _carouselController = CarouselSliderController();

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: movies.length,
          options: CarouselOptions(
            height: 500,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            enlargeFactor: 0.18,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
          itemBuilder: (context, index, realIndex) => SpotlightMovieCard(
            movie: movies[index],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailPage(movie: movies[index]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: movies.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentIndex == entry.key ? 24 : 8,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: _currentIndex == entry.key ? const Color(0xFFE50914) : Colors.white.withOpacity(0.4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMoviesGrid(List<MovieModel> movies) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.60,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) => MovieCard(
          movie: movies[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailPage(movie: movies[index]),
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorWidget extends ConsumerWidget {
  final Object error;
  final bool isRetryable;
  const ErrorWidget({super.key, required this.error, this.isRetryable = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFE50914), size: 48),
            const SizedBox(height: 16),
            Text('Error: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
            if (isRetryable) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.watch(movieProvider),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
                child: const Text('Try Again', style: TextStyle(color: Colors.white)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class SpotlightMovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onTap;

  const SpotlightMovieCard({Key? key, required this.movie, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.9),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${movie.averageRating.toStringAsFixed(1)} | ${movie.language}',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'BOOK NOW',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (movie.posterUrls.isEmpty || movie.posterUrls[0].isEmpty) {
      return _buildPlaceholder();
    }

    final imageUrl = movie.posterUrls[0];
    return imageUrl.startsWith('http')
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          )
        : Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildPlaceholder(),
          );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.movie, color: Colors.white38, size: 80),
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onTap;

  const MovieCard({Key? key, required this.movie, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImage(),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_border,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.averageRating.toStringAsFixed(1)} | ${movie.language}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
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

  Widget _buildImage() {
    if (movie.posterUrls.isEmpty || movie.posterUrls[0].isEmpty) {
      return _buildPlaceholder();
    }

    final imageUrl = movie.posterUrls[0];
    return imageUrl.startsWith('http')
        ? Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _buildPlaceholder())
        : Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _buildPlaceholder());
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.movie, color: Colors.white38, size: 60),
      ),
    );
  }
}