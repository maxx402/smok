import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn() : super('en');

  @override
  String get appTitle => 'Quit Smoking Assistant';

  // Bottom Navigation
  @override
  String get homeTab => 'Home';
  @override
  String get encouragementTab => 'Encourage';
  @override
  String get checkinTab => 'Resist';
  @override
  String get remindersTab => 'Stats';
  @override
  String get settingsTab => 'Settings';

  // Home Screen
  @override
  String get quitTimerTitle => 'Quit Timer';
  @override
  String get days => 'Days';
  @override
  String get hours => 'Hours';
  @override
  String get minutes => 'Minutes';
  @override
  String get moneySaved => 'Money Saved';
  @override
  String get cigarettesAvoided => 'Cigarettes Avoided';
  @override
  String get healthProgress => 'Health Progress';
  @override
  String get nextMilestone => 'Next Milestone';

  // Resist Temptation Screen
  @override
  String get dailyCheckin => 'Resist Temptation';
  @override
  String get howAreYouFeeling => 'How are you feeling right now?';
  @override
  String get cravingIntensity => 'Temptation Intensity';
  @override
  String get addNotes => 'Record Thoughts';
  @override
  String get submitCheckin => 'Log Resistance';
  @override
  String get checkinSuccess => 'Great job resisting!';

  // Health Milestones
  @override
  String get health_20min_title => 'Blood Pressure & Pulse Recovery';
  @override
  String get health_20min_desc =>
      'Heart rate and blood pressure drop to normal levels';
  @override
  String get health_8hours_title => 'Carbon Monoxide Levels Drop';
  @override
  String get health_8hours_desc =>
      'Carbon monoxide levels in blood drop, oxygen levels return to normal';
  @override
  String get health_24hours_title => 'Heart Attack Risk Decreases';
  @override
  String get health_24hours_desc => 'Risk of heart attack begins to decrease';
  @override
  String get health_2days_title => 'Taste & Smell Improve';
  @override
  String get health_2days_desc =>
      'Nerve endings for taste and smell start to recover';
  @override
  String get health_3days_title => 'Breathing Improves';
  @override
  String get health_3days_desc =>
      'Bronchial tubes begin to relax, breathing becomes easier';
  @override
  String get health_1week_title => 'Circulation Improves';
  @override
  String get health_1week_desc =>
      'Blood circulation improves, nicotine is completely eliminated';
  @override
  String get health_1month_title => 'Lung Function Increases';
  @override
  String get health_1month_desc =>
      'Lung cilia regrow, lung function significantly improves';
  @override
  String get health_3months_title => 'Cardiovascular Health';
  @override
  String get health_3months_desc =>
      'Cardiovascular function significantly improves';
  @override
  String get health_1year_title => 'Heart Disease Risk Halved';
  @override
  String get health_1year_desc =>
      'Risk of coronary heart disease is 50% less than a smoker';

  // Settings Screen
  @override
  String get personalInfo => 'Personal Information';
  @override
  String get nickname => 'Nickname';
  @override
  String get gender => 'Gender';
  @override
  String get age => 'Age';
  @override
  String get smokingInfo => 'Smoking Information';
  @override
  String get dailyExpense => 'Daily Expense';
  @override
  String get dailyCigarettes => 'Daily Cigarettes';
  @override
  String get smokingYears => 'Smoking Years';
  @override
  String get quitReason => 'Quit Reason';
  @override
  String get notifications => 'Notifications';
  @override
  String get enableNotifications => 'Enable Notifications';
  @override
  String get reminderTimes => 'Reminder Times';
  @override
  String get language => 'Language';
  @override
  String get theme => 'Theme';
  @override
  String get dataManagement => 'Data Management';
  @override
  String get exportData => 'Export Data';
  @override
  String get importData => 'Import Data';
  @override
  String get resetAllData => 'Reset All Data';

  // Feedback
  @override
  String get feedbackSectionTitle => 'Feedback';
  @override
  String get feedbackDescription =>
      'Share ideas or issues to help improve the app. Text only for now.';
  @override
  String get feedbackPlaceholder => 'Describe your feedback...';
  @override
  String get submitFeedback => 'Submit Feedback';
  @override
  String get feedbackSuccess => 'Thanks!';
  @override
  String get feedbackEmptyError =>
      'Please enter some feedback before submitting.';
  @override
  String get feedbackFailure => 'Failed to save feedback. Try again later.';
  @override
  String get feedbackEnable65DialogTitle => 'Restart Required';
  @override
  String get feedbackEnable65DialogMessage =>
      'Please restart the app to apply the latest changes.';
  @override
  String get feedbackEnable65Confirm => 'Restart Now';

  // Encouragement Wall
  @override
  String get encouragementEmptyTitle => 'Your encouragement wall is empty';
  @override
  String get encouragementEmptySubtitle =>
      'Copy a friend’s supportive message and come back to the app to pin it here.';
  @override
  String get encouragementDeleteTitle => 'Remove message';
  @override
  String get encouragementDeleteMessage =>
      'This will remove the selected encouragement from your wall.';
  @override
  String get encouragementDeleteAction => 'Remove';
  @override
  String get encouragementAddSuccess => 'Saved to encouragement wall';
  @override
  String get encouragementClipboardPermissionTitle =>
      'Enable clipboard capture';
  @override
  String get encouragementClipboardPermissionMessage =>
      'When you open the app we can read your clipboard once to save copied support messages to the encouragement wall.';
  @override
  String get encouragementClipboardPermissionAction => 'Turn on';
  @override
  String get encouragementClipboardPreviewTitle => 'Add to encouragement wall?';
  @override
  String get encouragementClipboardDismiss => 'Not now';
  @override
  String get encouragementClipboardSave => 'Save message';

  // Common
  @override
  String get save => 'Save';
  @override
  String get cancel => 'Cancel';
  @override
  String get confirm => 'Confirm';
  @override
  String get delete => 'Delete';
  @override
  String get edit => 'Edit';
  @override
  String get done => 'Done';
}
