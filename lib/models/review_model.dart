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
      userId: map['userId'],
      userName: map['userName'],
      userProfilePic: map['userProfilePic'],
      rating: map['rating'],
      comment: map['comment'],
      date: DateTime.parse(map['date']),
    );
  }
  Map<String, dynamic> toMap(){
    return {
      'userId': userId,
      'userName': userName,
      'userProfilePic': userProfilePic,
      'rating': rating,
      'comment': comment,
      'date':  date.toIso8601String(),
    };
  }

}
