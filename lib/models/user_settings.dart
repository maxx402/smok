class UserSettings {
  final String? nickname;
  final String? gender;
  final int? age;
  final double dailyExpense;
  final int dailyCigarettes;
  final int smokingYears;
  final String? quitReason;
  final DateTime? quitStartDate;
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final List<String> reminderTimes;

  UserSettings({
    this.nickname,
    this.gender,
    this.age,
    this.dailyExpense = 20.0,
    this.dailyCigarettes = 20,
    this.smokingYears = 1,
    this.quitReason,
    this.quitStartDate,
    this.language = 'zh_CN',
    this.theme = 'system',
    this.notificationsEnabled = true,
    this.reminderTimes = const [],
  });

  UserSettings copyWith({
    String? nickname,
    String? gender,
    int? age,
    double? dailyExpense,
    int? dailyCigarettes,
    int? smokingYears,
    String? quitReason,
    DateTime? quitStartDate,
    String? language,
    String? theme,
    bool? notificationsEnabled,
    List<String>? reminderTimes,
  }) {
    return UserSettings(
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      dailyExpense: dailyExpense ?? this.dailyExpense,
      dailyCigarettes: dailyCigarettes ?? this.dailyCigarettes,
      smokingYears: smokingYears ?? this.smokingYears,
      quitReason: quitReason ?? this.quitReason,
      quitStartDate: quitStartDate ?? this.quitStartDate,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTimes: reminderTimes ?? this.reminderTimes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'gender': gender,
      'age': age,
      'dailyExpense': dailyExpense,
      'dailyCigarettes': dailyCigarettes,
      'smokingYears': smokingYears,
      'quitReason': quitReason,
      'quitStartDate': quitStartDate?.millisecondsSinceEpoch,
      'language': language,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'reminderTimes': reminderTimes,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      nickname: json['nickname'],
      gender: json['gender'],
      age: json['age'],
      dailyExpense: (json['dailyExpense'] ?? 20.0).toDouble(),
      dailyCigarettes: json['dailyCigarettes'] ?? 20,
      smokingYears: json['smokingYears'] ?? 1,
      quitReason: json['quitReason'],
      quitStartDate: json['quitStartDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['quitStartDate'])
          : null,
      language: json['language'] ?? 'zh_CN',
      theme: json['theme'] ?? 'system',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      reminderTimes: List<String>.from(json['reminderTimes'] ?? []),
    );
  }
}