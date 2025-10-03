import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_settings.dart';
import '../models/daily_checkin.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Database? _database;
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'quit_smoking.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE checkins (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date INTEGER NOT NULL UNIQUE,
            mood INTEGER NOT NULL,
            cravingIntensity INTEGER NOT NULL,
            notes TEXT,
            achievements TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE achievements (
            id TEXT PRIMARY KEY,
            titleKey TEXT NOT NULL,
            descriptionKey TEXT NOT NULL,
            iconName TEXT NOT NULL,
            unlockedAt INTEGER,
            type TEXT NOT NULL,
            target TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE resistance_logs (
            id TEXT PRIMARY KEY,
            timestamp INTEGER NOT NULL,
            mood INTEGER NOT NULL,
            temptationIntensity INTEGER NOT NULL,
            notes TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add resistance_logs table in version 2
          await db.execute('''
            CREATE TABLE resistance_logs (
              id TEXT PRIMARY KEY,
              timestamp INTEGER NOT NULL,
              mood INTEGER NOT NULL,
              temptationIntensity INTEGER NOT NULL,
              notes TEXT
            )
          ''');
        }
      },
    );
  }

  // User Settings
  Future<UserSettings> getUserSettings() async {
    await _ensureInitialized();
    final String? settingsJson = _prefs!.getString('user_settings');
    if (settingsJson != null) {
      return UserSettings.fromJson(jsonDecode(settingsJson));
    }
    return UserSettings();
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    await _ensureInitialized();
    await _prefs!.setString('user_settings', jsonEncode(settings.toJson()));
  }

  // Daily Check-ins
  Future<void> saveDailyCheckIn(DailyCheckIn checkIn) async {
    await _ensureInitialized();
    await _database!.insert('checkins', {
      'date': checkIn.date.millisecondsSinceEpoch,
      'mood': checkIn.mood,
      'cravingIntensity': checkIn.cravingIntensity,
      'notes': checkIn.notes,
      'achievements': jsonEncode(checkIn.achievements),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<DailyCheckIn?> getDailyCheckIn(DateTime date) async {
    await _ensureInitialized();
    final dateStart = DateTime(date.year, date.month, date.day);
    final dateEnd = dateStart.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await _database!.query(
      'checkins',
      where: 'date >= ? AND date < ?',
      whereArgs: [
        dateStart.millisecondsSinceEpoch,
        dateEnd.millisecondsSinceEpoch,
      ],
    );

    if (maps.isNotEmpty) {
      final map = maps.first;
      return DailyCheckIn(
        date: DateTime.fromMillisecondsSinceEpoch(map['date']),
        mood: map['mood'],
        cravingIntensity: map['cravingIntensity'],
        notes: map['notes'],
        achievements: List<String>.from(
          jsonDecode(map['achievements'] ?? '[]'),
        ),
      );
    }
    return null;
  }

  Future<List<DailyCheckIn>> getCheckInHistory({int? limit}) async {
    await _ensureInitialized();
    final List<Map<String, dynamic>> maps = await _database!.query(
      'checkins',
      orderBy: 'date DESC',
      limit: limit,
    );

    return maps
        .map(
          (map) => DailyCheckIn(
            date: DateTime.fromMillisecondsSinceEpoch(map['date']),
            mood: map['mood'],
            cravingIntensity: map['cravingIntensity'],
            notes: map['notes'],
            achievements: List<String>.from(
              jsonDecode(map['achievements'] ?? '[]'),
            ),
          ),
        )
        .toList();
  }

  // Resistance Logs
  Future<void> saveResistanceLog(ResistanceLog log) async {
    await _ensureInitialized();
    await _database!.insert('resistance_logs', {
      'id': log.id,
      'timestamp': log.timestamp.millisecondsSinceEpoch,
      'mood': log.mood,
      'temptationIntensity': log.temptationIntensity,
      'notes': log.notes,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<ResistanceLog>> getTodayResistanceLogs() async {
    await _ensureInitialized();
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await _database!.query(
      'resistance_logs',
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [
        dayStart.millisecondsSinceEpoch,
        dayEnd.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
    );

    return maps
        .map(
          (map) => ResistanceLog(
            id: map['id'],
            timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
            mood: map['mood'],
            temptationIntensity: map['temptationIntensity'],
            notes: map['notes'],
          ),
        )
        .toList();
  }

  Future<List<ResistanceLog>> getResistanceLogsHistory({int? limit}) async {
    await _ensureInitialized();
    final List<Map<String, dynamic>> maps = await _database!.query(
      'resistance_logs',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps
        .map(
          (map) => ResistanceLog(
            id: map['id'],
            timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
            mood: map['mood'],
            temptationIntensity: map['temptationIntensity'],
            notes: map['notes'],
          ),
        )
        .toList();
  }

  Future<int> getResistanceCountForDate(DateTime date) async {
    await _ensureInitialized();
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final List<Map<String, dynamic>> result = await _database!.rawQuery(
      'SELECT COUNT(*) as count FROM resistance_logs WHERE timestamp >= ? AND timestamp < ?',
      [dayStart.millisecondsSinceEpoch, dayEnd.millisecondsSinceEpoch],
    );

    return result.first['count'] as int;
  }

  // Achievements
  Future<void> saveAchievement(Achievement achievement) async {
    await _ensureInitialized();
    await _database!.insert('achievements', {
      'id': achievement.id,
      'titleKey': achievement.titleKey,
      'descriptionKey': achievement.descriptionKey,
      'iconName': achievement.iconName,
      'unlockedAt': achievement.unlockedAt?.millisecondsSinceEpoch,
      'type': achievement.type.toString(),
      'target': achievement.target?.toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Achievement>> getAchievements() async {
    await _ensureInitialized();
    final List<Map<String, dynamic>> maps = await _database!.query(
      'achievements',
    );

    return maps
        .map(
          (map) => Achievement(
            id: map['id'],
            titleKey: map['titleKey'],
            descriptionKey: map['descriptionKey'],
            iconName: map['iconName'],
            unlockedAt: map['unlockedAt'] != null
                ? DateTime.fromMillisecondsSinceEpoch(map['unlockedAt'])
                : null,
            type: AchievementType.values.firstWhere(
              (e) => e.toString() == map['type'],
              orElse: () => AchievementType.time,
            ),
            target: map['target'],
          ),
        )
        .toList();
  }

  Future<void> _ensureInitialized() async {
    if (_prefs == null || _database == null) {
      await init();
    }
  }
}
