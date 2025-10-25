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
    userName: (map['userName'] ?? 'Anonymous').toString(),
    userProfilePic: (map['userProfilePic'] ?? '').toString(),
    rating: ((map['rating'] ?? 0) as num).toDouble(),  
    comment: (map['comment'] ?? '').toString(),
    date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()), userId: '',
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
