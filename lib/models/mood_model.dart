class MoodCategory {
  final String id;
  final String title;
  final String imagePath;

  MoodCategory({
    required this.id,
    required this.title,
    required this.imagePath,
  });

  factory MoodCategory.fromMap(Map<String, dynamic> json) => MoodCategory(
    id: json['id'] as String? ?? 'mood_unknown',
    title: json['title'] as String? ?? 'Untitled Mood',
    imagePath: json['imagePath'] as String? ?? 'assets/placeholder.png',
  );
  factory MoodCategory.fromJson(Map<String, dynamic> json) => MoodCategory(
    id: json['id'] as String? ?? 'mood_unknown',
    title: json['title'] as String? ?? 'Untitled Mood',
    imagePath: json['imagePath'] as String? ?? 'assets/placeholder.png',
  );
}
