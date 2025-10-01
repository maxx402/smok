class DailyCheckIn {
  final DateTime date;
  final int mood; // 1-10 scale
  final int cravingIntensity; // 1-10 scale
  final String? notes;
  final List<String> achievements;

  DailyCheckIn({
    required this.date,
    required this.mood,
    required this.cravingIntensity,
    this.notes,
    this.achievements = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.millisecondsSinceEpoch,
      'mood': mood,
      'cravingIntensity': cravingIntensity,
      'notes': notes,
      'achievements': achievements,
    };
  }

  factory DailyCheckIn.fromJson(Map<String, dynamic> json) {
    return DailyCheckIn(
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      mood: json['mood'],
      cravingIntensity: json['cravingIntensity'],
      notes: json['notes'],
      achievements: List<String>.from(json['achievements'] ?? []),
    );
  }
}

class ResistanceLog {
  final DateTime timestamp; // 精确到分钟的时间戳
  final int mood; // 1-10 scale
  final int temptationIntensity; // 1-10 scale，诱惑强度
  final String? notes;
  final String id; // 唯一标识符

  ResistanceLog({
    required this.timestamp,
    required this.mood,
    required this.temptationIntensity,
    this.notes,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'mood': mood,
      'temptationIntensity': temptationIntensity,
      'notes': notes,
    };
  }

  factory ResistanceLog.fromJson(Map<String, dynamic> json) {
    return ResistanceLog(
      id: json['id'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      mood: json['mood'],
      temptationIntensity: json['temptationIntensity'],
      notes: json['notes'],
    );
  }

  // 检查是否是今天的记录
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
           timestamp.month == now.month &&
           timestamp.day == now.day;
  }
}

class Achievement {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final String iconName;
  final DateTime? unlockedAt;
  final AchievementType type;
  final dynamic target;

  Achievement({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.iconName,
    this.unlockedAt,
    required this.type,
    this.target,
  });

  bool get isUnlocked => unlockedAt != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleKey': titleKey,
      'descriptionKey': descriptionKey,
      'iconName': iconName,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
      'type': type.toString(),
      'target': target,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      titleKey: json['titleKey'],
      descriptionKey: json['descriptionKey'],
      iconName: json['iconName'],
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'])
          : null,
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AchievementType.time,
      ),
      target: json['target'],
    );
  }
}

enum AchievementType {
  time, // 时间类成就
  health, // 健康类成就
  economic, // 经济类成就
  willpower, // 毅力类成就
}