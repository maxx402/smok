import '../models/user_settings.dart';

class QuitStats {
  final DateTime quitDate;
  final double dailyExpense;
  final int dailyCigarettes;

  QuitStats({
    required this.quitDate,
    required this.dailyExpense,
    required this.dailyCigarettes,
  });

  Duration get quitDuration => DateTime.now().difference(quitDate);

  int get quitDays => quitDuration.inDays;
  int get quitHours => quitDuration.inHours;
  int get quitMinutes => quitDuration.inMinutes;

  // 节省的金钱
  double get moneySaved => (quitDays * dailyExpense);

  // 没有抽的香烟支数
  int get cigarettesNotSmoked => (quitDays * dailyCigarettes);

  // 健康改善里程碑
  List<HealthMilestone> get healthMilestones {
    return [
      HealthMilestone(
        duration: const Duration(minutes: 20),
        titleKey: 'health_20min_title',
        descriptionKey: 'health_20min_desc',
        achieved: quitDuration >= const Duration(minutes: 20),
      ),
      HealthMilestone(
        duration: const Duration(hours: 8),
        titleKey: 'health_8hours_title',
        descriptionKey: 'health_8hours_desc',
        achieved: quitDuration >= const Duration(hours: 8),
      ),
      HealthMilestone(
        duration: const Duration(hours: 24),
        titleKey: 'health_24hours_title',
        descriptionKey: 'health_24hours_desc',
        achieved: quitDuration >= const Duration(hours: 24),
      ),
      HealthMilestone(
        duration: const Duration(days: 2),
        titleKey: 'health_2days_title',
        descriptionKey: 'health_2days_desc',
        achieved: quitDuration >= const Duration(days: 2),
      ),
      HealthMilestone(
        duration: const Duration(days: 3),
        titleKey: 'health_3days_title',
        descriptionKey: 'health_3days_desc',
        achieved: quitDuration >= const Duration(days: 3),
      ),
      HealthMilestone(
        duration: const Duration(days: 7),
        titleKey: 'health_1week_title',
        descriptionKey: 'health_1week_desc',
        achieved: quitDuration >= const Duration(days: 7),
      ),
      HealthMilestone(
        duration: const Duration(days: 30),
        titleKey: 'health_1month_title',
        descriptionKey: 'health_1month_desc',
        achieved: quitDuration >= const Duration(days: 30),
      ),
      HealthMilestone(
        duration: const Duration(days: 90),
        titleKey: 'health_3months_title',
        descriptionKey: 'health_3months_desc',
        achieved: quitDuration >= const Duration(days: 90),
      ),
      HealthMilestone(
        duration: const Duration(days: 365),
        titleKey: 'health_1year_title',
        descriptionKey: 'health_1year_desc',
        achieved: quitDuration >= const Duration(days: 365),
      ),
    ];
  }

  // 获取下一个里程碑
  HealthMilestone? get nextMilestone {
    return healthMilestones.firstWhere(
      (milestone) => !milestone.achieved,
      orElse: () => healthMilestones.last,
    );
  }

  // 当前里程碑进度
  double get milestoneProgress {
    final next = nextMilestone;
    if (next == null) return 1.0;

    return quitDuration.inMinutes / next.duration.inMinutes;
  }

  static QuitStats fromUserSettings(UserSettings settings) {
    return QuitStats(
      quitDate: settings.quitStartDate ?? DateTime.now(),
      dailyExpense: settings.dailyExpense,
      dailyCigarettes: settings.dailyCigarettes,
    );
  }
}

class HealthMilestone {
  final Duration duration;
  final String titleKey;
  final String descriptionKey;
  final bool achieved;

  HealthMilestone({
    required this.duration,
    required this.titleKey,
    required this.descriptionKey,
    required this.achieved,
  });

  String get timeDescription {
    if (duration.inDays > 0) {
      return '${duration.inDays}天';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}小时';
    } else {
      return '${duration.inMinutes}分钟';
    }
  }
}