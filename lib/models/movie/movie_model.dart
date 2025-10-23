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
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      genre: map['genre'] ?? '',
      language: map['language'] ?? '',
      duration: map['duration'] ?? '',
      rating: map['rating'] ?? '',
      cast: List<String>.from(map['cast'] ?? []),
      crew: List<String>.from(map['crew'] ?? []),
      posterUrls: List<String>.from(map['posterUrls'] ?? []),
      averageRating: (map['averageRating'] ?? 0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      showtimes: (map['showtimes'] as List<dynamic>?)
              ?.map((s) => ShowtimeModel.fromMap(s))
              .toList() ??
          [],
      reviews: (map['reviews'] as List<dynamic>?)
              ?.map((r) => ReviewModel.fromMap(r))
              .toList() ??
          [],
    );
  }
}
