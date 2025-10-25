import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String userId;
  final String userName;
  final String userProfilePic;
  final double rating;
  final String comment;
  final DateTime date;

  ReviewModel({
    required this.userId,
    required this.userName,
    required this.userProfilePic,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      userId: map['userId'] as String? ?? 'guest_id',
      userName: map['userName'] as String? ?? 'Guest User',
      userProfilePic: map['userProfilePic'] as String? ?? '',
      rating: (map['rating'] as num? ?? 0.0).toDouble(),
      comment: map['comment'] as String? ?? 'No comment.',
      date:
          (map['date'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userProfilePic': userProfilePic,
      'rating': rating,
      'comment': comment,
      'date': Timestamp.fromDate(date),
    };
  }
}
