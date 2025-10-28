import 'package:district/features/home/movies/moviebookingpage.dart';
import 'package:district/models/movie/movie_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final bookmarkedMoviesProvider = StateProvider<Set<String>>((ref) => {});

class MovieDetailPage extends ConsumerWidget {
  final MovieModel movie;

  const MovieDetailPage({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarkedMoviesProvider);
    final isBookmarked = bookmarks.contains(movie.id);

    return Scaffold(
      backgroundColor: Colors.black,
// <<<<<<< HEAD
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildMovieInfo(),
              const Divider(color: Colors.white10, height: 1),
              _buildSectionTitle('Synopsis'),
              _buildDescription(),
              const Divider(color: Colors.white10, height: 1),
              _buildSectionTitle('Cast'),
              _buildCast(),
              const Divider(color: Colors.white10, height: 1),
              _buildSectionTitle('Crew'),
              _buildCrew(),
              const Divider(color: Colors.white10, height: 1),
              _buildSectionTitle('Showtimes'),
              _buildShowtimes(context),
              const Divider(color: Colors.white10, height: 1),
              _buildSectionTitle('Reviews (${movie.reviews.length})'),
              _buildReviews(),
              const SizedBox(height: 100),
            ]),
          ),
        ],
// =======
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(context, ref, isBookmarked),
//             _buildMovieInfo(),
//             _buildDescription(),
//             _buildCast(),
//             _buildCrew(),
//             _buildShowtimes(context),
//             _buildReviews(),
//             const SizedBox(height: 100),
//           ],
//         ),
// >>>>>>> 25e9c2302838ffa38bef29b0a279b323df89c3de
      ),
      bottomNavigationBar: _buildBookButton(context),
    );
  }

// <<<<<<< HEAD
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFE50914),
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
  

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.black,
      leading: Container(),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              movie.posterUrls.isNotEmpty &&
                      movie.posterUrls[0].startsWith('http')
                  ? movie.posterUrls[0]
                  : '',
              height: 400,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 400,
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.movie, color: Colors.white54, size: 80),
                ),
              ),
            ),
            Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.95),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_border, color: Colors.white),
          onPressed: () {},
// =======
//   Widget _buildHeader(BuildContext context, WidgetRef ref, bool isBookmarked) {
//     return Stack(
//       children: [
//         Image.asset(movie.posterUrls.isNotEmpty ? movie.posterUrls[0] : '', height: 400, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 400, color: Colors.grey[800])),
//         Container(height: 400, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.9)]))),
//         Positioned(top: 40, left: 16, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
//         Positioned(
//           top: 40,
//           right: 16,
//           child: IconButton(
//             icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: isBookmarked ? Colors.yellow : Colors.white),
//             onPressed: () {
//               final bookmarks = ref.read(bookmarkedMoviesProvider.notifier);
//               if (isBookmarked) {
//                 bookmarks.state = {...bookmarks.state}..remove(movie.id);
//               } else {
//                 bookmarks.state = {...bookmarks.state, movie.id};
//               }
//             },
//           ),
// >>>>>>> 25e9c2302838ffa38bef29b0a279b323df89c3de
        ),
      ],
      title: Text(
        movie.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMovieInfo() {
    return Padding(
// <<<<<<< HEAD
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
// =======
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(movie.title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
// >>>>>>> 25e9c2302838ffa38bef29b0a279b323df89c3de
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
// <<<<<<< HEAD
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber[700],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Text(
                      movie.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Colors.black, size: 16),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${movie.totalReviews} reviews',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(movie.rating, color: Colors.red.withOpacity(0.2)),
              _buildChip(movie.language),
              _buildChip(movie.duration),
              _buildChip(movie.genre),
            ],
          ),
// =======
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(color: Colors.green[700], borderRadius: BorderRadius.circular(4)),
//                 child: Row(children: [Text(movie.averageRating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(width: 2), const Icon(Icons.star, color: Colors.white, size: 14)]),
//               ),
//               const SizedBox(width: 12),
//               Text('${movie.totalReviews} reviews', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Wrap(spacing: 8, children: [_buildChip(movie.rating), _buildChip(movie.language), _buildChip(movie.duration), _buildChip(movie.genre)]),
// >>>>>>> 25e9c2302838ffa38bef29b0a279b323df89c3de
        ],
      ),
    );
  }

// <<<<<<< HEAD
  Widget _buildChip(String label, {Color color = const Color(0xFF1E1E1E)}) {
    return Chip(
      label: Text(label),
      backgroundColor: color,
      labelStyle: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        movie.description,
        style: TextStyle(color: Colors.grey[300], fontSize: 15, height: 1.6),
// =======
//   Widget _buildChip(String label) => Chip(label: Text(label), backgroundColor: Colors.grey[900], labelStyle: const TextStyle(color: Colors.white70, fontSize: 12));

//   Widget _buildDescription() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Description', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Text(movie.description, style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.5)),
//         ],
// >>>>>>> 25e9c2302838ffa38bef29b0a279b323df89c3de
      ),
    );
  }

  Widget _buildCast() {
    return Padding(
// <<<<<<< HEAD
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: movie.cast.map((actor) => _buildChip(actor)).toList(),
// =======
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Cast', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Wrap(spacing: 6, runSpacing: 6, children: movie.cast.map((actor) => _buildChip(actor)).toList()),
//         ],
// >>>>>>> 25e9c2302838ffa38bef29b0a279b323df89c3de
      ),
    );
  }

  Widget _buildCrew() {
    return Padding(
// <<<<<<< HEAD
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: movie.crew.map((member) => _buildChip(member)).toList(),
// =======
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Crew', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Wrap(spacing: 6, runSpacing: 6, children: movie.crew.map((member) => _buildChip(member)).toList()),
//         ],
// >>>>>>> 25e9c2302838ffa38bef29b0a279b323df89c3de
      ),
    );
  }

  Widget _buildShowtimes(BuildContext context) {
    return Padding(
// <<<<<<< HEAD
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: movie.showtimes
            .map(
              (showtime) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showtime.cinemaName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${showtime.address} - ${showtime.screenType.name.toUpperCase()}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Text(
                            DateFormat('h:mm a').format(showtime.time),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '₹${showtime.price.toInt()}',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
// =======
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Showtimes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),
//           ...movie.showtimes.map((s) => Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(s.cinemaName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 4),
//                     Text(s.address, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
//                     const SizedBox(height: 8),
//                     Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(DateFormat('h:mm a').format(s.time), style: const TextStyle(color: Colors.white, fontSize: 14)), Text('₹${s.price.toInt()}', style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold))]),
// >>>>>>> 25e9c2302838ffa38bef29b0a279b323df89c3de
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildReviews() {
    return Padding(
// <<<<<<< HEAD
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: movie.reviews
            .map(
              (review) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
// =======
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Reviews', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),
//           ...movie.reviews.map((r) => Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
// >>>>>>> 25e9c2302838ffa38bef29b0a279b323df89c3de
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
// <<<<<<< HEAD
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.red.withOpacity(0.5),
                          backgroundImage:
                              review.userProfilePic.isNotEmpty &&
                                  review.userProfilePic.startsWith('http')
                              ? NetworkImage(review.userProfilePic)
                                    as ImageProvider
                              : null,
                          child:
                              review.userProfilePic.isEmpty ||
                                  !review.userProfilePic.startsWith('http')
                              ? Text(
                                  review.userName.isNotEmpty
                                      ? review.userName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM dd, yyyy').format(review.date),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[700],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Text(
                                review.rating.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.black,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      review.comment,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
// =======
//                       children: [
//                         CircleAvatar(radius: 20, backgroundColor: Colors.grey[800], backgroundImage: r.userProfilePic.isNotEmpty ? AssetImage(r.userProfilePic) : null, child: r.userProfilePic.isEmpty ? Text(r.userName.isNotEmpty ? r.userName[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)) : null),
//                         const SizedBox(width: 12),
//                         Expanded(child: Text(r.userName, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
//                         Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green[700], borderRadius: BorderRadius.circular(4)), child: Row(children: [Text(r.rating.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)), const Icon(Icons.star, color: Colors.white, size: 12)])),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Text(r.comment, style: TextStyle(color: Colors.grey[300], fontSize: 13, height: 1.4)),
//                     const SizedBox(height: 8),
//                     Text(DateFormat('MMM dd, yyyy').format(r.date), style: TextStyle(color: Colors.grey[600], fontSize: 11)),
//                   ],
//                 ),
//               )),
//         ],
// >>>>>>> 25e9c2302838ffa38bef29b0a279b323df89c3de
      ),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return Container(
// <<<<<<< HEAD
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieBookingPage(movie: movie),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE50914),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'BOOK TICKETS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
// =======
//       padding: const EdgeInsets.all(16),
//       color: Colors.grey[900],
//       child: ElevatedButton(
//         onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieBookingPage(movie: movie))),
//         style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
//         child: const Text('Book Tickets', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
// >>>>>>> 25e9c2302838ffa38bef29b0a279b323df89c3de
      ),
    );
  }
}
