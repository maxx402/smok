class EncouragementEntry {
  EncouragementEntry({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String content;
  final DateTime createdAt;

  factory EncouragementEntry.fromJson(Map<String, dynamic> json) {
    return EncouragementEntry(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
