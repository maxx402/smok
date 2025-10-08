class UserFeedbackEntry {
  final String id;
  final String content;
  final DateTime createdAt;

  UserFeedbackEntry({required this.content, DateTime? createdAt, String? id})
    : createdAt = createdAt ?? DateTime.now(),
      id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserFeedbackEntry.fromJson(Map<String, dynamic> json) {
    final rawTimestamp = json['createdAt'];
    final timestamp = rawTimestamp is num ? rawTimestamp.toInt() : null;

    return UserFeedbackEntry(
      id: json['id'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : DateTime.now(),
    );
  }
}
