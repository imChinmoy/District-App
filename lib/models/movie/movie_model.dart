import 'package:district/models/review_model.dart';
import 'package:district/models/movie/showtime_model.dart';

class MovieModel {
  final String id;
  final String title;
  final String description;
  final String genre;
  final String language;
  final String duration;
  final String rating; // e.g. "PG-13"
  final List<String> cast;
  final List<String> crew;
  final List<String> posterUrls;
  final double averageRating;
  final int totalReviews;
  final List<ShowtimeModel> showtimes;
  final List<ReviewModel> reviews;

  MovieModel({
    required this.id,
    required this.title,
    required this.description,
    required this.genre,
    required this.language,
    required this.duration,
    required this.rating,
    required this.cast,
    required this.crew,
    required this.posterUrls,
    required this.averageRating,
    required this.totalReviews,
    required this.showtimes,
    required this.reviews,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'genre': genre,
      'language': language,
      'duration': duration,
      'rating': rating,
      'cast': cast,
      'crew': crew,
      'posterUrls': posterUrls,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'showtimes': showtimes.map((s) => s.toMap()).toList(),
      'reviews': reviews.map((r) => r.toMap()).toList(),
    };
  }

  factory MovieModel.fromMap(Map<String, dynamic> map) {
  return MovieModel(
    id: (map['id'] ?? '').toString(),
    title: (map['title'] ?? 'Unknown').toString(),
    description: (map['description'] ?? '').toString(),
    genre: (map['genre'] ?? '').toString(),
    language: (map['language'] ?? 'Unknown').toString(),
    duration: (map['duration'] ?? '').toString(),
    rating: (map['rating'] ?? 'N/A').toString(),
    cast: (map['cast'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    crew: (map['crew'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    posterUrls: (map['posterUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    averageRating: ((map['averageRating'] ?? 0) as num).toDouble(),
    totalReviews: (map['totalReviews'] ?? 0) as int,
    showtimes: (map['showtimes'] as List<dynamic>?)
            ?.map((s) => ShowtimeModel.fromMap(s as Map<String, dynamic>))
            .toList() ??
        [],
    reviews: (map['reviews'] as List<dynamic>?)
            ?.map((r) => ReviewModel.fromMap(r as Map<String, dynamic>))
            .toList() ??
        [],
  );
}
}
