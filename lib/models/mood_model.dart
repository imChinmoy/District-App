class MoodCategory {
  final String id;
  final String title;
  final String imageUrl;

  MoodCategory({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory MoodCategory.fromMap(Map<String, dynamic> json) => MoodCategory(
    id: json['id'] as String? ?? 'mood_unknown',
    title: json['title'] as String? ?? 'Untitled Mood',
    imageUrl: json['imageUrl'] as String? ?? 'assets/placeholder.png',
  );
}
