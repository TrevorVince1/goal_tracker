import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

void main() {
  runApp(const GoalTrackerApp());
}

// ============= TROPICAL COLOR PALETTE =============

class TropicalColors {
  static const Color oceanBlue = Color(0xFF00B4D8);
  static const Color deepSea = Color(0xFF0077B6);
  static const Color palmGreen = Color(0xFF2A9D8F);
  static const Color sunsetOrange = Color(0xFFF4A261);
  static const Color sunsetPink = Color(0xFFE76F51);
  static const Color sand = Color(0xFFFFF8E7);
  static const Color sandDark = Color(0xFFF5E6C8);
  static const Color coconut = Color(0xFF6B4F3A);
  static const Color hibiscus = Color(0xFFE63946);
  static const Color sunshine = Color(0xFFFFD166);
  static const Color sky = Color(0xFF90E0EF);
  static const Color coral = Color(0xFFFF8C42);
  static const Color teal = Color(0xFF06D6A0);
  static const Color purple = Color(0xFF9D4EDD);
  static const Color forest = Color(0xFF2D6A4F);
  static const Color charcoal = Color(0xFF264653);
}

class GoalTrackerApp extends StatelessWidget {
  const GoalTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tropical Goal Tracker',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: TropicalColors.oceanBlue,
          secondary: TropicalColors.palmGreen,
          surface: Colors.white,
          background: TropicalColors.sand,
          error: TropicalColors.hibiscus,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: TropicalColors.coconut,
          onBackground: TropicalColors.coconut,
        ),
        scaffoldBackgroundColor: TropicalColors.sand,
        cardColor: Colors.white,
      ),
      home: const MainTabScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ============= REMINDER MODEL =============

class ReminderSettings {
  final String? timeOfDay;
  final int? durationMinutes;
  final bool reminderEnabled;

  ReminderSettings({
    this.timeOfDay,
    this.durationMinutes,
    this.reminderEnabled = false,
  });

  bool get hasReminder =>
      timeOfDay != null || durationMinutes != null || reminderEnabled;

  Map<String, dynamic> toJson() => {
        'timeOfDay': timeOfDay,
        'durationMinutes': durationMinutes,
        'reminderEnabled': reminderEnabled,
      };

  factory ReminderSettings.fromJson(Map<String, dynamic> json) {
    return ReminderSettings(
      timeOfDay: json['timeOfDay'],
      durationMinutes: json['durationMinutes'],
      reminderEnabled: json['reminderEnabled'] ?? false,
    );
  }
}

// ============= USER PROFILE MODEL =============

class UserProfile {
  String? season;
  String? ageRange;
  String? locationType;
  String? climate;
  String? livingSituation;

  UserProfile({
    this.season,
    this.ageRange,
    this.locationType,
    this.climate,
    this.livingSituation,
  });

  bool get isComplete =>
      season != null &&
      ageRange != null &&
      locationType != null &&
      climate != null &&
      livingSituation != null;

  Map<String, dynamic> toJson() => {
        'season': season,
        'ageRange': ageRange,
        'locationType': locationType,
        'climate': climate,
        'livingSituation': livingSituation,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      season: json['season'],
      ageRange: json['ageRange'],
      locationType: json['locationType'],
      climate: json['climate'],
      livingSituation: json['livingSituation'],
    );
  }
}

// ============= DATA MODELS =============

class WeeklyGoal {
  final String value;
  final String day;
  final String id;
  final ReminderSettings? reminder;

  WeeklyGoal({
    required this.value,
    required this.day,
    required this.id,
    this.reminder,
  });

  Map<String, dynamic> toJson() => {
        'value': value,
        'day': day,
        'id': id,
        'reminder': reminder?.toJson(),
      };

  factory WeeklyGoal.fromJson(Map<String, dynamic> json) {
    return WeeklyGoal(
      value: json['value'] ?? '',
      day: json['day'] ?? 'Monday',
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      reminder: json['reminder'] != null
          ? ReminderSettings.fromJson(json['reminder'])
          : null,
    );
  }

  WeeklyGoal copyWith({
    String? value,
    String? day,
    ReminderSettings? reminder,
    bool clearReminder = false,
  }) {
    return WeeklyGoal(
      value: value ?? this.value,
      day: day ?? this.day,
      id: id,
      reminder: clearReminder ? null : (reminder ?? this.reminder),
    );
  }
}

class DailyGoalEntry {
  final String id;
  final String text;
  final bool isCompleted;
  final DateTime date;
  final String category;
  final ReminderSettings? reminder;

  DailyGoalEntry({
    required this.id,
    required this.text,
    this.isCompleted = false,
    required this.date,
    required this.category,
    this.reminder,
  });

  DailyGoalEntry copyWith({
    String? text,
    bool? isCompleted,
    DateTime? date,
    ReminderSettings? reminder,
    bool clearReminder = false,
  }) {
    return DailyGoalEntry(
      id: id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      category: category,
      reminder: clearReminder ? null : (reminder ?? this.reminder),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isCompleted': isCompleted,
        'date': date.toIso8601String(),
        'category': category,
        'reminder': reminder?.toJson(),
      };

  factory DailyGoalEntry.fromJson(Map<String, dynamic> json) {
    return DailyGoalEntry(
      id: json['id'],
      text: json['text'],
      isCompleted: json['isCompleted'] ?? false,
      date: DateTime.parse(json['date']),
      category: json['category'] ?? 'General',
      reminder: json['reminder'] != null
          ? ReminderSettings.fromJson(json['reminder'])
          : null,
    );
  }
}

class HabitEntry {
  final String id;
  final String name;
  final String icon;
  final List<DateTime> completedDates;
  final DateTime createdAt;
  final ReminderSettings? reminder;

  HabitEntry({
    required this.id,
    required this.name,
    required this.icon,
    this.completedDates = const [],
    required this.createdAt,
    this.reminder,
  });

  HabitEntry copyWith({
    String? name,
    String? icon,
    List<DateTime>? completedDates,
    ReminderSettings? reminder,
    bool clearReminder = false,
  }) {
    return HabitEntry(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt,
      reminder: clearReminder ? null : (reminder ?? this.reminder),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'reminder': reminder?.toJson(),
      };

  factory HabitEntry.fromJson(Map<String, dynamic> json) {
    return HabitEntry(
      id: json['id'],
      name: json['name'],
      icon: json['icon'] ?? '🌺',
      completedDates: (json['completedDates'] as List<dynamic>?)
              ?.map((d) => DateTime.parse(d))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      reminder: json['reminder'] != null
          ? ReminderSettings.fromJson(json['reminder'])
          : null,
    );
  }

  bool isCompletedOn(DateTime date) {
    return completedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  int getStreak() {
    if (completedDates.isEmpty) return 0;
    final sorted = List<DateTime>.from(completedDates)..sort();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final todayCompleted = sorted.any((d) =>
        d.year == todayDate.year &&
        d.month == todayDate.month &&
        d.day == todayDate.day);
    if (!todayCompleted) return 0;
    int streak = 0;
    DateTime checkDate = todayDate;
    while (true) {
      final completed = sorted.any((d) =>
          d.year == checkDate.year &&
          d.month == checkDate.month &&
          d.day == checkDate.day);
      if (!completed) break;
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int getWeeklyCount() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    return _countBetween(
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
        DateTime(today.year, today.month, today.day));
  }

  int getMonthlyCount() {
    final today = DateTime.now();
    return _countBetween(DateTime(today.year, today.month, 1),
        DateTime(today.year, today.month, today.day));
  }

  int getYearlyCount() {
    final today = DateTime.now();
    return _countBetween(DateTime(today.year, 1, 1),
        DateTime(today.year, today.month, today.day));
  }

  int _countBetween(DateTime start, DateTime end) {
    int count = 0;
    DateTime current = DateTime(start.year, start.month, start.day);
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      if (isCompletedOn(current)) count++;
      current = current.add(const Duration(days: 1));
    }
    return count;
  }

  int getWeeklyPossible() => DateTime.now().weekday;
  int getMonthlyPossible() => DateTime.now().day;
  int getYearlyPossible() =>
      DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays + 1;

  int getCompletionRate(DateTime startDate, DateTime endDate) {
    if (completedDates.isEmpty) return 0;
    int totalDays = 0;
    int completedDays = 0;
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      totalDays++;
      if (isCompletedOn(current)) completedDays++;
      current = current.add(const Duration(days: 1));
    }
    return totalDays > 0 ? (completedDays / totalDays * 100).round() : 0;
  }
}

class BadHabitEntry {
  final String id;
  final String name;
  final String icon;
  final DateTime startDate;
  final List<DateTime> relapseDates;
  final ReminderSettings? reminder;

  BadHabitEntry({
    required this.id,
    required this.name,
    required this.icon,
    required this.startDate,
    this.relapseDates = const [],
    this.reminder,
  });

  BadHabitEntry copyWith({
    String? name,
    String? icon,
    DateTime? startDate,
    List<DateTime>? relapseDates,
    ReminderSettings? reminder,
    bool clearReminder = false,
  }) {
    return BadHabitEntry(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      startDate: startDate ?? this.startDate,
      relapseDates: relapseDates ?? this.relapseDates,
      reminder: clearReminder ? null : (reminder ?? this.reminder),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'startDate': startDate.toIso8601String(),
        'relapseDates': relapseDates.map((d) => d.toIso8601String()).toList(),
        'reminder': reminder?.toJson(),
      };

  factory BadHabitEntry.fromJson(Map<String, dynamic> json) {
    return BadHabitEntry(
      id: json['id'],
      name: json['name'],
      icon: json['icon'] ?? '🚫',
      startDate: DateTime.parse(json['startDate']),
      relapseDates: (json['relapseDates'] as List<dynamic>?)
              ?.map((d) => DateTime.parse(d))
              .toList() ??
          [],
      reminder: json['reminder'] != null
          ? ReminderSettings.fromJson(json['reminder'])
          : null,
    );
  }

  int getCurrentStreak() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    DateTime lastRelapse = startDate;
    if (relapseDates.isNotEmpty) {
      final sorted = List<DateTime>.from(relapseDates)..sort();
      lastRelapse = sorted.last;
    }
    final cleanStart =
        DateTime(lastRelapse.year, lastRelapse.month, lastRelapse.day);
    return todayDate.difference(cleanStart).inDays;
  }

  int getLongestStreak() {
    if (relapseDates.isEmpty) return getCurrentStreak();
    final sorted = List<DateTime>.from(relapseDates)..sort();
    int longest = sorted.first
        .difference(DateTime(startDate.year, startDate.month, startDate.day))
        .inDays;
    for (int i = 1; i < sorted.length; i++) {
      final days = sorted[i]
          .difference(DateTime(
              sorted[i - 1].year, sorted[i - 1].month, sorted[i - 1].day))
          .inDays;
      if (days > longest) longest = days;
    }
    final today = DateTime.now();
    final currentStreak = DateTime(today.year, today.month, today.day)
        .difference(
            DateTime(sorted.last.year, sorted.last.month, sorted.last.day))
        .inDays;
    if (currentStreak > longest) longest = currentStreak;
    return longest;
  }

  int getTotalRelapses() => relapseDates.length;

  int getDaysSinceStart() {
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day)
        .difference(DateTime(startDate.year, startDate.month, startDate.day))
        .inDays;
  }
}

// ============= DATA SERVICE =============

class DataService {
  static const String WEEKLY_STORAGE_KEY = 'weekly_goals_data_v4';
  static const String DAILY_STORAGE_KEY = 'daily_goals_data_v4';
  static const String HABIT_STORAGE_KEY = 'habit_data_v2';
  static const String BAD_HABIT_STORAGE_KEY = 'bad_habit_data_v1';
  static const String PROFILE_STORAGE_KEY = 'user_profile_v1';
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  Map<int, WeeklyGoal> weeklyEntries = {};
  Map<String, bool> weeklyCheckboxStates = {};
  List<DailyGoalEntry> dailyGoals = [];
  List<HabitEntry> habits = [];
  List<BadHabitEntry> badHabits = [];
  UserProfile userProfile = UserProfile();

  bool _isLoaded = false;

  Future<void> loadAllData() async {
    if (!kIsWeb) {
      _isLoaded = true;
      return;
    }
    try {
      final String? weeklyString = html.window.localStorage[WEEKLY_STORAGE_KEY];
      if (weeklyString != null && weeklyString.isNotEmpty) {
        final Map<String, dynamic> weeklyData = jsonDecode(weeklyString);
        weeklyEntries.clear();
        weeklyCheckboxStates.clear();
        if (weeklyData['entries'] != null) {
          final entriesMap = weeklyData['entries'] as Map<String, dynamic>;
          entriesMap.forEach((key, value) {
            final int index = int.parse(key);
            weeklyEntries[index] = WeeklyGoal.fromJson(value);
          });
        }
        if (weeklyData['checkboxStates'] != null) {
          weeklyCheckboxStates =
              Map<String, bool>.from(weeklyData['checkboxStates']);
        }
      }
      final String? dailyString = html.window.localStorage[DAILY_STORAGE_KEY];
      if (dailyString != null && dailyString.isNotEmpty) {
        final List<dynamic> jsonData = jsonDecode(dailyString);
        dailyGoals =
            jsonData.map((item) => DailyGoalEntry.fromJson(item)).toList();
      }
      final String? habitString = html.window.localStorage[HABIT_STORAGE_KEY];
      if (habitString != null && habitString.isNotEmpty) {
        final List<dynamic> jsonData = jsonDecode(habitString);
        habits = jsonData.map((item) => HabitEntry.fromJson(item)).toList();
      } else {
        _initializeDefaultHabits();
      }
      final String? badHabitString =
          html.window.localStorage[BAD_HABIT_STORAGE_KEY];
      if (badHabitString != null && badHabitString.isNotEmpty) {
        final List<dynamic> jsonData = jsonDecode(badHabitString);
        badHabits =
            jsonData.map((item) => BadHabitEntry.fromJson(item)).toList();
      }
      final String? profileString =
          html.window.localStorage[PROFILE_STORAGE_KEY];
      if (profileString != null && profileString.isNotEmpty) {
        userProfile = UserProfile.fromJson(jsonDecode(profileString));
      }
      _isLoaded = true;
    } catch (e) {
      print('Error loading data: $e');
      _isLoaded = true;
    }
  }

  void _initializeDefaultHabits() {
    final defaultHabits = [
      {'name': 'Wake up early', 'icon': '🌅'},
      {'name': 'Drink water', 'icon': '🥥'},
      {'name': 'Exercise', 'icon': '🏄'},
      {'name': 'Healthy breakfast', 'icon': '🥗'},
      {'name': 'Meditate', 'icon': '🧘'},
      {'name': 'Read 10 pages', 'icon': '📖'},
      {'name': 'Journal', 'icon': '✍️'},
      {'name': 'Skin care', 'icon': '🧴'},
      {'name': 'Walk 30 min', 'icon': '🚶'},
      {'name': 'Sleep early', 'icon': '🌙'},
    ];
    for (var habit in defaultHabits) {
      habits.add(HabitEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString() +
            habits.length.toString(),
        name: habit['name']!,
        icon: habit['icon']!,
        createdAt: DateTime.now(),
      ));
    }
    saveHabitData();
  }

  void saveProfile() {
    if (!kIsWeb) return;
    try {
      html.window.localStorage[PROFILE_STORAGE_KEY] =
          jsonEncode(userProfile.toJson());
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  void saveWeeklyData() {
    if (!kIsWeb) return;
    try {
      html.window.localStorage[WEEKLY_STORAGE_KEY] = jsonEncode({
        'entries': weeklyEntries.map(
            (key, value) => MapEntry(key.toString(), value.toJson())),
        'checkboxStates': weeklyCheckboxStates,
      });
    } catch (e) {
      print('Error saving weekly data: $e');
    }
  }

  void saveDailyData() {
    if (!kIsWeb) return;
    try {
      html.window.localStorage[DAILY_STORAGE_KEY] =
          jsonEncode(dailyGoals.map((g) => g.toJson()).toList());
    } catch (e) {
      print('Error saving daily data: $e');
    }
  }

  void saveHabitData() {
    if (!kIsWeb) return;
    try {
      html.window.localStorage[HABIT_STORAGE_KEY] =
          jsonEncode(habits.map((h) => h.toJson()).toList());
    } catch (e) {
      print('Error saving habit data: $e');
    }
  }

  void saveBadHabitData() {
    if (!kIsWeb) return;
    try {
      html.window.localStorage[BAD_HABIT_STORAGE_KEY] =
          jsonEncode(badHabits.map((h) => h.toJson()).toList());
    } catch (e) {
      print('Error saving bad habit data: $e');
    }
  }

  void addWeeklyGoal(int index, String value, String day) {
    weeklyEntries[index] = WeeklyGoal(
      value: value,
      day: day,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    saveWeeklyData();
  }

  void updateWeeklyReminder(int index, ReminderSettings? reminder) {
    if (!weeklyEntries.containsKey(index)) return;
    weeklyEntries[index] = weeklyEntries[index]!.copyWith(
      reminder: reminder,
      clearReminder: reminder == null,
    );
    saveWeeklyData();
  }

  void deleteWeeklyGoal(int index) {
    weeklyEntries.remove(index);
    final keysToRemove = weeklyCheckboxStates.keys
        .where((key) => key.contains('_$index') || key.endsWith('_$index'))
        .toList();
    for (var key in keysToRemove) {
      weeklyCheckboxStates.remove(key);
    }
    saveWeeklyData();
  }

  void toggleWeeklyCheckbox(String key) {
    weeklyCheckboxStates[key] = !(weeklyCheckboxStates[key] ?? false);
    saveWeeklyData();
  }

  void addDailyGoal(DailyGoalEntry goal) {
    dailyGoals.add(goal);
    saveDailyData();
  }

  void updateDailyReminder(String id, ReminderSettings? reminder) {
    final index = dailyGoals.indexWhere((g) => g.id == id);
    if (index == -1) return;
    dailyGoals[index] = dailyGoals[index].copyWith(
      reminder: reminder,
      clearReminder: reminder == null,
    );
    saveDailyData();
  }

  void toggleDailyGoal(String id) {
    final index = dailyGoals.indexWhere((g) => g.id == id);
    if (index != -1) {
      dailyGoals[index] = dailyGoals[index].copyWith(
        isCompleted: !dailyGoals[index].isCompleted,
      );
      saveDailyData();
    }
  }

  void deleteDailyGoal(String id) {
    dailyGoals.removeWhere((goal) => goal.id == id);
    saveDailyData();
  }

  List<DailyGoalEntry> getTodayDailyGoals() {
    final today = DateTime.now();
    return dailyGoals
        .where((goal) =>
            goal.date.year == today.year &&
            goal.date.month == today.month &&
            goal.date.day == today.day)
        .toList();
  }

  Map<String, List<MapEntry<int, WeeklyGoal>>> getWeeklyGoalsByDay() {
    final Map<String, List<MapEntry<int, WeeklyGoal>>> goalsByDay = {};
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    for (var day in days) {
      goalsByDay[day] = [];
    }
    weeklyEntries.forEach((index, goal) {
      if (goalsByDay.containsKey(goal.day)) {
        goalsByDay[goal.day]!.add(MapEntry(index, goal));
      }
    });
    return goalsByDay;
  }

  List<MapEntry<int, WeeklyGoal>> getTodaysWeeklyGoals() {
    final today = DateTime.now();
    final dayName = DateFormat('EEEE').format(today);
    return getWeeklyGoalsByDay()[dayName] ?? [];
  }

  int getTotalWeeklyGoals() => weeklyEntries.length;

  void addHabit(String name, String icon) {
    habits.add(HabitEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      icon: icon,
      createdAt: DateTime.now(),
    ));
    saveHabitData();
  }

  void updateHabitReminder(String id, ReminderSettings? reminder) {
    final index = habits.indexWhere((h) => h.id == id);
    if (index == -1) return;
    habits[index] = habits[index].copyWith(
      reminder: reminder,
      clearReminder: reminder == null,
    );
    saveHabitData();
  }

  void deleteHabit(String id) {
    habits.removeWhere((h) => h.id == id);
    saveHabitData();
  }

  void toggleHabit(String id, DateTime date) {
    final index = habits.indexWhere((h) => h.id == id);
    if (index == -1) return;
    final habit = habits[index];
    final dateKey = DateTime(date.year, date.month, date.day);
    final completedList = List<DateTime>.from(habit.completedDates);
    final existingIndex = completedList.indexWhere((d) =>
        d.year == dateKey.year &&
        d.month == dateKey.month &&
        d.day == dateKey.day);
    if (existingIndex != -1) {
      completedList.removeAt(existingIndex);
    } else {
      completedList.add(dateKey);
    }
    habits[index] = habit.copyWith(completedDates: completedList);
    saveHabitData();
  }

  List<HabitEntry> getHabits() => habits;

  int getHabitStreak(String id) {
    final habit =
        habits.firstWhere((h) => h.id == id, orElse: () => habits.first);
    return habit.getStreak();
  }

  Map<String, int> getHabitStats(String id) {
    final habit =
        habits.firstWhere((h) => h.id == id, orElse: () => habits.first);
    final today = DateTime.now();
    return {
      'streak': habit.getStreak(),
      'monthlyRate': habit.getCompletionRate(
          DateTime(today.year, today.month, 1),
          DateTime(today.year, today.month, today.day)),
      'total': habit.completedDates.length,
    };
  }

  void addBadHabit(String name, String icon) {
    badHabits.add(BadHabitEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      icon: icon,
      startDate: DateTime.now(),
    ));
    saveBadHabitData();
  }

  void updateBadHabitReminder(String id, ReminderSettings? reminder) {
    final index = badHabits.indexWhere((h) => h.id == id);
    if (index == -1) return;
    badHabits[index] = badHabits[index].copyWith(
      reminder: reminder,
      clearReminder: reminder == null,
    );
    saveBadHabitData();
  }

  void recordRelapse(String id) {
    final index = badHabits.indexWhere((h) => h.id == id);
    if (index == -1) return;
    final habit = badHabits[index];
    final relapseDates = List<DateTime>.from(habit.relapseDates);
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final exists = relapseDates.any((d) =>
        d.year == todayKey.year &&
        d.month == todayKey.month &&
        d.day == todayKey.day);
    if (!exists) {
      relapseDates.add(todayKey);
      badHabits[index] = habit.copyWith(relapseDates: relapseDates);
      saveBadHabitData();
    }
  }

  void resetBadHabitStreak(String id) {
    final index = badHabits.indexWhere((h) => h.id == id);
    if (index == -1) return;
    final habit = badHabits[index];
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    badHabits[index] = habit.copyWith(
      startDate: todayKey,
      relapseDates: [],
    );
    saveBadHabitData();
  }

  void deleteBadHabit(String id) {
    badHabits.removeWhere((h) => h.id == id);
    saveBadHabitData();
  }

  List<BadHabitEntry> getBadHabits() => badHabits;

  // ===== REPORT ANALYTICS =====
  List<Map<String, dynamic>> getDailyGoalsHistory(int days) {
    final today = DateTime.now();
    final List<Map<String, dynamic>> result = [];
    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayGoals = dailyGoals.where((g) =>
          g.date.year == date.year &&
          g.date.month == date.month &&
          g.date.day == date.day).toList();
      final completed = dayGoals.where((g) => g.isCompleted).length;
      result.add({
        'date': date,
        'total': dayGoals.length,
        'completed': completed,
        'rate':
            dayGoals.isEmpty ? 0 : (completed / dayGoals.length * 100).round(),
      });
    }
    return result;
  }

  List<Map<String, dynamic>> getHabitsHistory(int days) {
    final today = DateTime.now();
    final List<Map<String, dynamic>> result = [];
    for (int i = days - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final completedCount =
          habits.where((h) => h.isCompletedOn(date)).length;
      final rate = habits.isEmpty
          ? 0
          : (completedCount / habits.length * 100).round();
      result.add({
        'date': date,
        'completed': completedCount,
        'total': habits.length,
        'rate': rate,
      });
    }
    return result;
  }

  Map<String, dynamic> getOverallStats() {
    final today = DateTime.now();
    final last7 = getDailyGoalsHistory(7);
    final last30 = getDailyGoalsHistory(30);
    int totalDailyCompleted =
        last7.fold(0, (sum, d) => sum + (d['completed'] as int));
    int totalDailyGoals =
        last7.fold(0, (sum, d) => sum + (d['total'] as int));
    final habitHistory7 = getHabitsHistory(7);
    final habitHistory30 = getHabitsHistory(30);
    int totalHabitCompletions =
        habitHistory7.fold(0, (sum, d) => sum + (d['completed'] as int));
    int possibleHabitCompletions =
        habitHistory7.fold(0, (sum, d) => sum + (d['total'] as int));
    final totalWeeklyGoals = getTotalWeeklyGoals();
    final completedWeeklyGoals =
        weeklyCheckboxStates.values.where((v) => v).length;
    int totalCleanDays = 0;
    int totalRelapses = 0;
    for (var bad in badHabits) {
      totalCleanDays += bad.getCurrentStreak();
      totalRelapses += bad.getTotalRelapses();
    }
    return {
      'dailyCompleted7': totalDailyCompleted,
      'dailyTotal7': totalDailyGoals,
      'dailyCompleted30':
          last30.fold(0, (sum, d) => sum + (d['completed'] as int)),
      'dailyTotal30':
          last30.fold(0, (sum, d) => sum + (d['total'] as int)),
      'habitCompletions7': totalHabitCompletions,
      'habitPossible7': possibleHabitCompletions,
      'habitCompletions30':
          habitHistory30.fold(0, (sum, d) => sum + (d['completed'] as int)),
      'weeklyTotal': totalWeeklyGoals,
      'weeklyCompleted': completedWeeklyGoals,
      'badHabitsCount': badHabits.length,
      'cleanDays': totalCleanDays,
      'relapses': totalRelapses,
      'todayDailyCompleted': last7.last['completed'],
      'todayDailyTotal': last7.last['total'],
      'todayHabitCompleted': habitHistory7.last['completed'],
      'todayHabitTotal': habitHistory7.last['total'],
    };
  }

  Map<String, Map<String, int>> getCategoryBreakdown(int days) {
    final today = DateTime.now();
    final startDate = today.subtract(Duration(days: days - 1));
    final Map<String, Map<String, int>> result = {};
    for (final cat in DailyCategory.categories) {
      result[cat.name] = {'completed': 0, 'total': 0};
    }
    for (final goal in dailyGoals) {
      if (goal.date.isBefore(startDate)) continue;
      if (!result.containsKey(goal.category)) {
        result[goal.category] = {'completed': 0, 'total': 0};
      }
      result[goal.category]!['total'] = result[goal.category]!['total']! + 1;
      if (goal.isCompleted) {
        result[goal.category]!['completed'] =
            result[goal.category]!['completed']! + 1;
      }
    }
    return result;
  }
}

// ============= SURVIVAL ENGINE =============

class SurvivalEngine {
  final UserProfile profile;

  SurvivalEngine(this.profile);

  List<SurvivalTip> getSeasonalTips() {
    final season = profile.season ?? 'Summer';
    final climate = profile.climate ?? 'Temperate';

    final Map<String, List<SurvivalTip>> seasonTips = {
      'Spring': [
        SurvivalTip('🌸', 'Spring Cleaning & Reset',
            'Declutter your space, wash winter bedding, and open windows to circulate fresh air. A clean environment reduces stress.'),
        SurvivalTip('🌱', 'Start a Garden or Plant',
            'Even a single herb pot on a windowsill boosts mood and gives you fresh food. Gardening reduces cortisol by up to 20%.'),
        SurvivalTip('💧', 'Prepare for Allergy Season',
            'Check pollen forecasts, keep antihistamines on hand, and shower before bed to remove pollen from hair and skin.'),
        SurvivalTip('🚶', 'Increase Outdoor Time',
            'Aim for at least 20 minutes outside daily. Spring sunlight helps regulate circadian rhythm and boosts vitamin D.'),
        SurvivalTip('🏠', 'Check Home Maintenance',
            'Inspect roof, gutters, and windows after winter. Small fixes now prevent expensive repairs later.'),
        SurvivalTip('👕', 'Rotate Your Wardrobe',
            'Store winter clothes properly with cedar or lavender. Bring out breathable fabrics for warmer days ahead.'),
      ],
      'Summer': [
        SurvivalTip('💧', 'Hydration Is Survival',
            'Drink at least 8-10 glasses of water daily. Add electrolytes if sweating heavily. Dehydration kills faster than hunger.'),
        SurvivalTip('☀️', 'Sun Protection Always',
            'SPF 30+ every day, even when cloudy. Reapply every 2 hours. UV damage accumulates silently.'),
        SurvivalTip('🌡️', 'Beat the Heat',
            'Avoid outdoor activity between 10am-4pm. Use fans, cold compresses, and take cool showers if overheating.'),
        SurvivalTip('🍉', 'Eat Water-Rich Foods',
            'Watermelon, cucumber, oranges, and berries hydrate and provide natural sugars for energy.'),
        SurvivalTip('🦟', 'Insect Protection',
            'Use mosquito repellent at dusk. Remove standing water around your home. Wear light-colored long sleeves in wooded areas.'),
        SurvivalTip('🚗', 'Never Leave Anyone in Cars',
            'Cars reach 120°F+ in minutes. This applies to pets and children — a life-or-death rule every summer.'),
      ],
      'Fall': [
        SurvivalTip('🍂', 'Prepare for Cold Season',
            'Get a flu shot, stock up on vitamin C and D, and build your immune system before winter hits.'),
        SurvivalTip('🧥', 'Layer Your Clothing',
            'Three-layer system: base (moisture-wicking), mid (insulating), outer (weatherproof). Adapt as temperatures shift.'),
        SurvivalTip('🍁', 'Harvest & Preserve',
            'If you garden, now is the time to can, freeze, or dry. Stock your pantry with non-perishables.'),
        SurvivalTip('🏠', 'Winterize Your Home',
            'Seal drafts, service your heating system, and insulate pipes before the first freeze.'),
        SurvivalTip('🌙', 'Adjust to Shorter Days',
            'Use a sunrise alarm clock or light therapy lamp if you feel seasonal mood drops. Vitamin D is essential.'),
        SurvivalTip('🍲', 'Warm, Nutrient-Dense Meals',
            'Soups, stews, and root vegetables provide sustained energy and warmth for colder days.'),
      ],
      'Winter': [
        SurvivalTip('🧣', 'Cold Weather Safety',
            'Cover extremities first — fingers, toes, ears, nose. Frostbite can occur in minutes below freezing.'),
        SurvivalTip('🔥', 'Emergency Heat Plan',
            'Keep blankets, flashlights, batteries, and non-perishable food ready. Never use generators indoors.'),
        SurvivalTip('🥣', 'High-Calorie Warm Foods',
            'Oatmeal, stews, and soups maintain body temperature. Eat more calories than in summer to fuel heat generation.'),
        SurvivalTip('🚗', 'Winter Driving Kit',
            'Keep a blanket, ice scraper, jumper cables, snacks, water, and a phone charger in your car at all times.'),
        SurvivalTip('🛌', 'Prioritize Sleep',
            'Longer nights are natural. Aim for 7-9 hours. Your body repairs more during cold months.'),
        SurvivalTip('🤝', 'Combat Isolation',
            'Shorter days can trigger depression. Schedule regular social contact and get outside during daylight hours.'),
      ],
    };

    final climateAdditions = <String, List<SurvivalTip>>{
      'Tropical': [
        SurvivalTip('🌴', 'Humidity Management',
            'Use breathable fabrics, keep air flowing, and watch for mold growth. Dehumidifiers help indoors.'),
        SurvivalTip('🦟', 'Disease Prevention',
            'Tropical regions have higher mosquito-borne illness risk. Use nets and repellent consistently.'),
      ],
      'Arid': [
        SurvivalTip('🏜️', 'Water Conservation',
            'Store water in multiple locations. Learn to find and purify water. Never ration water in an emergency — drink it.'),
        SurvivalTip('🌵', 'Heat Safety',
            'Travel at night, rest during peak heat, and know the signs of heatstroke: confusion, hot dry skin, rapid pulse.'),
      ],
      'Cold': [
        SurvivalTip('❄️', 'Hypothermia Awareness',
            'Watch for shivering, confusion, and slurred speech. Warm the core first, not the extremities.'),
        SurvivalTip('🔥', 'Fire Starting Skills',
            'Carry multiple fire-starting methods: lighter, ferro rod, waterproof matches. Practice in non-emergency settings.'),
      ],
      'Humid': [
        SurvivalTip('💨', 'Air Quality',
            'Humidity breeds mold and dust mites. Use HEPA filters and ventilate regularly.'),
        SurvivalTip('🌧️', 'Flood Preparedness',
            'Know your flood zone. Keep important documents waterproofed and elevated.'),
      ],
    };

    final result = <SurvivalTip>[];
    result.addAll(seasonTips[season] ?? []);
    if (climateAdditions.containsKey(climate)) {
      result.addAll(climateAdditions[climate]!);
    }
    return result;
  }

  List<SurvivalTip> getAgeTips() {
    final age = profile.ageRange ?? 'Adult';
    final Map<String, List<SurvivalTip>> ageTips = {
      'Teen': [
        SurvivalTip('🧠', 'Build Your Foundation',
            'Your brain is still developing until around age 25. Sleep 8-10 hours, avoid alcohol and drugs, and learn skills that compound.'),
        SurvivalTip('💪', 'Establish Fitness Habits',
            'Habits formed now last a lifetime. Even 20 minutes of daily movement builds lifelong health.'),
        SurvivalTip('📚', 'Learn to Learn',
            'Practice critical thinking, reading, and math. These unlock everything else in life.'),
        SurvivalTip('💰', 'Start Saving Early',
            'Even \$20/month compounds massively over 40 years. Open a savings account today.'),
      ],
      'Young Adult': [
        SurvivalTip('💼', 'Build Career Capital',
            'Skills matter more than credentials in most fields. Spend 1 hour daily on your craft. Network relentlessly.'),
        SurvivalTip('🏦', 'Emergency Fund First',
            'Save 3-6 months of expenses before any other investing. This is your survival buffer.'),
        SurvivalTip('❤️', 'Invest in Relationships',
            'Loneliness is as deadly as smoking. Maintain 5-10 close friendships. They are your safety net.'),
        SurvivalTip('🎯', 'Define Your Values',
            'Write down what actually matters to you. Most people drift for decades without this.'),
      ],
      'Adult': [
        SurvivalTip('💪', 'Muscle Mass Equals Longevity',
            'Adults lose 3-8% muscle per decade after 30. Strength train twice weekly to preserve it.'),
        SurvivalTip('💰', 'Compound Your Money',
            'Max out tax-advantaged accounts. Index funds beat 90% of active managers long-term.'),
        SurvivalTip('🧘', 'Manage Stress Actively',
            'Chronic stress ages you faster. Meditation, exercise, and sleep are non-negotiable.'),
        SurvivalTip('👨‍👩‍👧', 'Deepen Relationships',
            'Quality over quantity. Weekly meaningful connection with loved ones prevents burnout.'),
      ],
      'Middle Age': [
        SurvivalTip('🩺', 'Health Screenings',
            'Annual checkups, blood work, and cancer screenings are non-negotiable. Early detection saves lives.'),
        SurvivalTip('🧠', 'Cognitive Health',
            'Learn something new every month. Novelty builds cognitive reserve against dementia.'),
        SurvivalTip('💪', 'Preserve Mobility',
            'Stretch daily, work on balance, and lift weights. Falls are a leading cause of decline.'),
        SurvivalTip('💰', 'Retirement Planning',
            'Calculate your target number. If behind, increase savings by 1-2% per year.'),
      ],
      'Senior': [
        SurvivalTip('🧓', 'Fall Prevention',
            'Remove tripping hazards, install grab bars, and practice balance exercises daily. Falls are the number one risk.'),
        SurvivalTip('💊', 'Medication Management',
            'Use a weekly pill organizer and review medications with your doctor every 6 months.'),
        SurvivalTip('👥', 'Stay Social',
            'Isolation is a top health risk for seniors. Join groups, volunteer, or call a friend daily.'),
        SurvivalTip('🧠', 'Keep Learning',
            'Puzzles, reading, and new hobbies reduce dementia risk by up to 30%.'),
      ],
    };
    return ageTips[age] ?? [];
  }

  List<SurvivalTip> getLocationTips() {
    final location = profile.locationType ?? 'Suburban';
    final Map<String, List<SurvivalTip>> locationTips = {
      'Urban': [
        SurvivalTip('🚇', 'Situational Awareness',
            'Keep your head up, phone down in public. Trust your gut. Walk with confidence even if lost.'),
        SurvivalTip('🚨', 'Emergency Routes',
            'Know 2-3 ways out of your neighborhood on foot. In emergencies, streets become gridlocked.'),
        SurvivalTip('🏢', 'Community Networks',
            'Know your neighbors. In a crisis, they are your first responders.'),
        SurvivalTip('🎒', 'Go-Bag Essentials',
            'Keep a small bag with water, snacks, flashlight, phone charger, and ID ready to grab.'),
      ],
      'Suburban': [
        SurvivalTip('🚗', 'Vehicle Readiness',
            'Keep your car maintained, fueled, and stocked with essentials. It is your lifeline.'),
        SurvivalTip('🔧', 'Basic Repair Skills',
            'Learn to fix a leaky faucet, change a tire, reset a breaker. Saves money and builds confidence.'),
        SurvivalTip('🌳', 'Yard Preparedness',
            'Even small yards can grow food, collect rainwater, and provide emergency shelter options.'),
        SurvivalTip('🏘️', 'Neighborhood Watch',
            'Join or start a community group. Shared resources and information multiply survival odds.'),
      ],
      'Rural': [
        SurvivalTip('💧', 'Water Independence',
            'Learn to access, filter, and store water. Rural water often comes from wells — have a backup plan.'),
        SurvivalTip('⚡', 'Power Independence',
            'Solar panels, generators, or battery banks are essential. Rural outages last longer.'),
        SurvivalTip('🌾', 'Food Security',
            'Grow, raise, hunt, or forage. Build a deep pantry with 3-6 months of staples.'),
        SurvivalTip('🔫', 'Self-Defense',
            'Rural areas have longer emergency response times. Know how to protect your home responsibly.'),
      ],
      'Coastal': [
        SurvivalTip('🌊', 'Tsunami & Storm Awareness',
            'Know evacuation routes. If you feel a strong quake near the coast, move inland and uphill immediately.'),
        SurvivalTip('🏠', 'Flood Preparedness',
            'Elevate valuables, waterproof documents, and know your flood zone. Never drive through floodwater.'),
        SurvivalTip('⛵', 'Marine Skills',
            'Learn basic swimming, boating, and signaling. The ocean is both resource and threat.'),
        SurvivalTip('🐟', 'Local Food Sources',
            'Learn sustainable fishing, crabbing, or foraging. Coastal areas offer abundant natural protein.'),
      ],
      'Mountain': [
        SurvivalTip('🏔️', 'Altitude Adjustment',
            'Acclimatize slowly above 8,000 ft. Drink extra water and watch for altitude sickness symptoms.'),
        SurvivalTip('🧭', 'Navigation Skills',
            'GPS fails in mountains. Learn map, compass, and natural navigation.'),
        SurvivalTip('🐻', 'Wildlife Awareness',
            'Store food properly, make noise on trails, and know how to react to bears, cougars, and snakes.'),
        SurvivalTip('❄️', 'Weather Reading',
            'Mountain weather changes fast. Learn cloud patterns and never push through dangerous conditions.'),
      ],
    };
    return locationTips[location] ?? [];
  }

  List<SurvivalTip> getGeneralTips() {
    return [
      SurvivalTip('🎯', 'The 80/20 Rule',
          '80% of results come from 20% of actions. Identify your vital few and ignore the trivial many.'),
      SurvivalTip('📚', 'Never Stop Learning',
          'The most successful people read 20+ books per year. Knowledge compounds like money.'),
      SurvivalTip('🤝', 'Build Your Network',
          'Your network is your net worth. Give value first. Reciprocity is universal.'),
      SurvivalTip('💪', 'Physical Strength Equals Freedom',
          'Strength gives you options: to help others, to escape danger, to age well. Train it.'),
      SurvivalTip('🧠', 'Protect Your Attention',
          'Your focus is your most valuable asset. Delete apps that steal it. Curate your input.'),
      SurvivalTip('💰', 'Money Buys Options',
          'Not happiness, but options. Save, invest, and never stop increasing your earning power.'),
      SurvivalTip('❤️', 'Health Before Wealth',
          'No amount of money fixes a broken body. Sleep, food, movement — non-negotiable.'),
      SurvivalTip('🧘', 'Master Your Emotions',
          'Emotions are data, not commands. Pause, breathe, respond — do not react.'),
      SurvivalTip('🌱', 'Small Daily Gains',
          '1% better every day equals 37x better in a year. Consistency beats intensity.'),
      SurvivalTip('🕯️', 'Prepare, Do Not Panic',
          'Preparation prevents panic. Have plans, supplies, and skills ready before you need them.'),
      SurvivalTip('🗣️', 'Learn to Say No',
          'Every yes is a no to something else. Protect your time fiercely.'),
      SurvivalTip('🌍', 'Give Back',
          'Helping others is the most reliable path to meaning and happiness.'),
    ];
  }

  List<Challenge> getChallenges() {
    return [
      Challenge(
        '30-Day Cold Shower',
        '☀️',
        'Finish every shower with 30 seconds of cold water for 30 days. Builds mental toughness, improves circulation, and reduces inflammation.',
        '🧠 Mental',
        'High',
      ),
      Challenge(
        'Digital Sunset',
        '🌙',
        'No screens 1 hour before bed for 2 weeks. Sleep quality improves 20-30% on average.',
        '😴 Health',
        'Medium',
      ),
      Challenge(
        'Daily Walk Streak',
        '🚶',
        'Walk at least 20 minutes outside every day for 30 days. No excuses. Rain or shine.',
        '💪 Physical',
        'Low',
      ),
      Challenge(
        'Learn One New Skill',
        '🎯',
        'Dedicate 15 min/day for 30 days to a new skill: language, instrument, coding, cooking.',
        '📚 Mental',
        'Medium',
      ),
      Challenge(
        'No Complaints Week',
        '🤐',
        '7 days without complaining out loud or in your head. Notice how your mindset shifts.',
        '🧘 Mental',
        'High',
      ),
      Challenge(
        'Read 12 Books in 12 Months',
        '📖',
        'One book per month for a year. Mix genres: business, fiction, biography, science.',
        '📚 Mental',
        'Medium',
      ),
      Challenge(
        'Save 1000 Emergency Fund',
        '💰',
        'Build a \$1,000 emergency fund within 90 days. Start with \$5/day. Automate it.',
        '💵 Financial',
        'Medium',
      ),
      Challenge(
        'Cook Every Meal for 30 Days',
        '🍳',
        'No restaurants, no takeout. Learn 10 recipes. Saves money and improves health.',
        '🍽️ Health',
        'High',
      ),
      Challenge(
        'Call a Friend or Family Daily',
        '📞',
        '7 days of meaningful 15+ min conversations with loved ones. Deepens connection.',
        '❤️ Social',
        'Low',
      ),
      Challenge(
        'Wake at 5AM for 21 Days',
        '🌅',
        'The 21/90 rule: 21 days to form a habit, 90 to cement a lifestyle. Start with 21.',
        '⏰ Discipline',
        'High',
      ),
      Challenge(
        'Write Daily Journal',
        '✍️',
        '10 minutes of reflection every night for 30 days. Boosts clarity and emotional processing.',
        '🧠 Mental',
        'Low',
      ),
      Challenge(
        'Zero Sugar for 2 Weeks',
        '🍬',
        'Cut all added sugars for 14 days. Taste buds reset; energy stabilizes.',
        '🍽️ Health',
        'High',
      ),
    ];
  }

  List<RoutineBlock> getDailyRoutine() {
    return [
      RoutineBlock('5:00-6:00 AM', 'Wake & Hydrate', '💧',
          'Drink 16oz water, stretch, review your top 3 goals for the day.', TropicalColors.sunshine),
      RoutineBlock('6:00-7:00 AM', 'Move Your Body', '🏃',
          'Walk, run, lift, yoga — anything that gets blood flowing. 30 min minimum.', TropicalColors.palmGreen),
      RoutineBlock('7:00-8:00 AM', 'Fuel Up', '🥗',
          'Protein + complex carbs + healthy fats. Skip sugar and refined grains.', TropicalColors.teal),
      RoutineBlock('8:00-12:00 PM', 'Deep Work Block', '🧠',
          'Your brain is sharpest now. Tackle hardest tasks first. Phone in another room.', TropicalColors.oceanBlue),
      RoutineBlock('12:00-1:00 PM', 'Lunch & Reset', '🍽️',
          'Eat light, take a 10-min walk, get sunlight. Avoid heavy meals.', TropicalColors.sunsetOrange),
      RoutineBlock('1:00-5:00 PM', 'Collaboration & Meetings', '🤝',
          'Schedule calls, meetings, admin work here. Energy dips naturally.', TropicalColors.purple),
      RoutineBlock('5:00-6:30 PM', 'Wind Down Work', '📥',
          'Wrap up, plan tomorrow, clear inbox. Work does not follow you home.', TropicalColors.deepSea),
      RoutineBlock('6:30-8:00 PM', 'Life & Connection', '❤️',
          'Family, friends, hobbies, learning. Real life happens here.', TropicalColors.hibiscus),
      RoutineBlock('8:00-9:30 PM', 'Digital Sunset', '🌙',
          'No screens. Read, journal, plan, prepare for tomorrow.', TropicalColors.charcoal),
      RoutineBlock('9:30-10:30 PM', 'Sleep Ritual', '😴',
          'Cool room, dark, quiet. Aim for 7-9 hours. Consistency matters more than perfection.', TropicalColors.coconut),
    ];
  }

  List<EmergencyItem> getEmergencyChecklist() {
    return [
      EmergencyItem('Water (1 gal/person/day)', '3 days minimum', '💧', true),
      EmergencyItem('Non-perishable food', '3 days minimum', '🥫', true),
      EmergencyItem('Flashlight + batteries', 'LED, water-resistant', '🔦', true),
      EmergencyItem('First aid kit', 'Bandages, antiseptic, meds', '🩹', true),
      EmergencyItem('Multi-tool or knife', 'Quality blade', '🔪', true),
      EmergencyItem('Phone charger (solar/power bank)', 'Fully charged', '🔋', true),
      EmergencyItem('Important documents', 'Waterproof container', '📄', true),
      EmergencyItem('Cash (small bills)', '\$200-500', '💵', true),
      EmergencyItem('Emergency blanket', 'Space blanket or wool', '🧣', true),
      EmergencyItem('Whistle', 'Signaling device', '📢', true),
      EmergencyItem('Dust mask', 'N95 or better', '😷', false),
      EmergencyItem('Fire starting kit', 'Lighter + ferro rod', '🔥', false),
      EmergencyItem('Water filter/purification', 'Tablets or filter', '🧴', false),
      EmergencyItem('Local maps (paper)', 'Your area, evacuation routes', '🗺️', false),
      EmergencyItem('Prescription medications', '7-day supply', '💊', false),
    ];
  }
}

class SurvivalTip {
  final String emoji;
  final String title;
  final String body;

  SurvivalTip(this.emoji, this.title, this.body);
}

class Challenge {
  final String title;
  final String emoji;
  final String description;
  final String category;
  final String difficulty;

  Challenge(this.title, this.emoji, this.description, this.category,
      this.difficulty);
}

class RoutineBlock {
  final String time;
  final String title;
  final String emoji;
  final String description;
  final Color color;

  RoutineBlock(
      this.time, this.title, this.emoji, this.description, this.color);
}

class EmergencyItem {
  final String name;
  final String detail;
  final String emoji;
  final bool essential;

  EmergencyItem(this.name, this.detail, this.emoji, this.essential);
}

// ============= REMINDER MENU =============

class ReminderMenu extends StatefulWidget {
  final ReminderSettings? initialReminder;
  final String title;
  final Function(ReminderSettings?) onSave;

  const ReminderMenu({
    super.key,
    required this.initialReminder,
    required this.title,
    required this.onSave,
  });

  @override
  State<ReminderMenu> createState() => _ReminderMenuState();
}

class _ReminderMenuState extends State<ReminderMenu> {
  String? _timeOfDay;
  int? _durationMinutes;
  bool _reminderEnabled = false;

  final List<int> _durationOptions = [5, 10, 15, 20, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _timeOfDay = widget.initialReminder?.timeOfDay;
    _durationMinutes = widget.initialReminder?.durationMinutes;
    _reminderEnabled = widget.initialReminder?.reminderEnabled ?? false;
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDay != null
          ? TimeOfDay(
              hour: int.parse(_timeOfDay!.split(':')[0]),
              minute: int.parse(_timeOfDay!.split(':')[1]),
            )
          : TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeOfDay =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _save() {
    if (_timeOfDay == null && _durationMinutes == null && !_reminderEnabled) {
      widget.onSave(null);
    } else {
      widget.onSave(ReminderSettings(
        timeOfDay: _timeOfDay,
        durationMinutes: _durationMinutes,
        reminderEnabled: _reminderEnabled,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TropicalColors.sky,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TropicalColors.oceanBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.alarm,
                      color: TropicalColors.oceanBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Time & Reminder',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: TropicalColors.deepSea)),
                      Text(widget.title,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF8B7355)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (widget.initialReminder != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _timeOfDay = null;
                        _durationMinutes = null;
                        _reminderEnabled = false;
                      });
                    },
                    child: const Text('Clear',
                        style: TextStyle(
                            color: TropicalColors.hibiscus, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('⏰ Time of Day',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TropicalColors.deepSea)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: TropicalColors.sand,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _timeOfDay != null
                        ? TropicalColors.oceanBlue
                        : TropicalColors.sandDark,
                    width: _timeOfDay != null ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time,
                        color: _timeOfDay != null
                            ? TropicalColors.oceanBlue
                            : TropicalColors.coconut,
                        size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _timeOfDay ?? 'Tap to set a time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _timeOfDay != null
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _timeOfDay != null
                              ? TropicalColors.deepSea
                              : const Color(0xFF8B7355),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('⏱️ Duration',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TropicalColors.deepSea)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _durationOptions.map((mins) {
                final isSelected = _durationMinutes == mins;
                return GestureDetector(
                  onTap: () => setState(
                      () => _durationMinutes = isSelected ? null : mins),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(colors: [
                              TropicalColors.oceanBlue,
                              TropicalColors.teal
                            ])
                          : null,
                      color: isSelected ? null : TropicalColors.sand,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? TropicalColors.oceanBlue
                            : TropicalColors.sandDark,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      mins < 60
                          ? '${mins}m'
                          : '${mins ~/ 60}h${mins % 60 > 0 ? ' ${mins % 60}m' : ''}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : TropicalColors.coconut,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _reminderEnabled
                    ? TropicalColors.palmGreen.withOpacity(0.1)
                    : TropicalColors.sand,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _reminderEnabled
                      ? TropicalColors.palmGreen
                      : TropicalColors.sandDark,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _reminderEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: _reminderEnabled
                        ? TropicalColors.palmGreen
                        : TropicalColors.coconut,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Reminder',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: TropicalColors.deepSea)),
                  ),
                  Switch(
                    value: _reminderEnabled,
                    onChanged: (v) => setState(() => _reminderEnabled = v),
                    activeColor: TropicalColors.palmGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: TropicalColors.sandDark),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: TropicalColors.coconut)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TropicalColors.oceanBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child:
                        const Text('Save 🌺', style: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showReminderMenu(BuildContext context,
    {required ReminderSettings? initialReminder,
    required String title,
    required Function(ReminderSettings?) onSave}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ReminderMenu(
      initialReminder: initialReminder,
      title: title,
      onSave: onSave,
    ),
  );
}

Widget buildClockButton({
  required ReminderSettings? reminder,
  required VoidCallback onTap,
  Color? color,
}) {
  final hasReminder = reminder != null && reminder.hasReminder;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: hasReminder
            ? TropicalColors.oceanBlue.withOpacity(0.15)
            : TropicalColors.sand,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              hasReminder ? TropicalColors.oceanBlue : TropicalColors.sandDark,
          width: hasReminder ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasReminder ? Icons.alarm_on : Icons.alarm_add,
            size: 18,
            color: hasReminder
                ? (color ?? TropicalColors.oceanBlue)
                : const Color(0xFF8B7355),
          ),
          if (hasReminder) ...[
            const SizedBox(width: 4),
            if (reminder!.timeOfDay != null)
              Text(reminder.timeOfDay!,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: TropicalColors.deepSea)),
            if (reminder.durationMinutes != null) ...[
              if (reminder.timeOfDay != null)
                const Text(' · ',
                    style: TextStyle(fontSize: 10, color: Color(0xFF8B7355))),
              Text('${reminder.durationMinutes}m',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: TropicalColors.deepSea)),
            ],
          ],
        ],
      ),
    ),
  );
}

Widget buildReminderChipStatic(ReminderSettings reminder) {
  return Wrap(
    spacing: 6,
    runSpacing: 4,
    children: [
      if (reminder.timeOfDay != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: TropicalColors.oceanBlue.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time,
                  size: 11, color: TropicalColors.oceanBlue),
              const SizedBox(width: 3),
              Text(reminder.timeOfDay!,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: TropicalColors.oceanBlue)),
            ],
          ),
        ),
      if (reminder.durationMinutes != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: TropicalColors.sunsetOrange.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer,
                  size: 11, color: TropicalColors.sunsetOrange),
              const SizedBox(width: 3),
              Text(
                  reminder.durationMinutes! < 60
                      ? '${reminder.durationMinutes}m'
                      : '${reminder.durationMinutes! ~/ 60}h${reminder.durationMinutes! % 60 > 0 ? ' ${reminder.durationMinutes! % 60}m' : ''}',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: TropicalColors.sunsetOrange)),
            ],
          ),
        ),
      if (reminder.reminderEnabled)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: TropicalColors.palmGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_active,
                  size: 11, color: TropicalColors.palmGreen),
              SizedBox(width: 3),
              Text('ON',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: TropicalColors.palmGreen)),
            ],
          ),
        ),
    ],
  );
}

// ============= MAIN TAB SCREEN =============

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await DataService().loadAllData();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: TropicalColors.sand,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(TropicalColors.oceanBlue),
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          DailyScreen(),
          WeeklyScreen(),
          HabitScreen(),
          ReportScreen(),
          SurvivalScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [TropicalColors.oceanBlue, TropicalColors.deepSea],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: TropicalColors.sunshine,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle:
              const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.beach_access_outlined),
              activeIcon: Icon(Icons.beach_access),
              label: 'Daily',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny_outlined),
              activeIcon: Icon(Icons.wb_sunny),
              label: 'Weekly',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.spa_outlined),
              activeIcon: Icon(Icons.spa),
              label: 'Habits',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Survival',
            ),
          ],
        ),
      ),
    );
  }
}

// ============= SURVIVAL SCREEN =============

class SurvivalScreen extends StatefulWidget {
  const SurvivalScreen({super.key});

  @override
  State<SurvivalScreen> createState() => _SurvivalScreenState();
}

class _SurvivalScreenState extends State<SurvivalScreen>
    with SingleTickerProviderStateMixin {
  final DataService _dataService = DataService();
  late TabController _tabController;
  String _currentTime = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _startClock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now().toLocal();
    final eastern = now.add(const Duration(hours: -5));
    if (mounted) {
      setState(() => _currentTime = DateFormat('h:mm:ss a').format(eastern));
    }
  }

  Future<void> _showProfileSetup() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProfileSetupSheet(
        initialProfile: _dataService.userProfile,
        onSave: (profile) {
          _dataService.userProfile = profile;
          _dataService.saveProfile();
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _dataService.userProfile;

    return Scaffold(
      backgroundColor: TropicalColors.sand,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [TropicalColors.forest, TropicalColors.charcoal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🧭 ', style: TextStyle(fontSize: 16)),
            Text('Survival Guide',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            Text(' ⛺', style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_currentTime,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ),
        ],
        bottom: profile.isComplete
            ? TabBar(
                controller: _tabController,
                indicatorColor: TropicalColors.sunshine,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 11),
                isScrollable: true,
                tabs: const [
                  Tab(text: '🌍 For You'),
                  Tab(text: '🎯 Challenges'),
                  Tab(text: '⏰ Routine'),
                  Tab(text: '🎒 Kit'),
                ],
              )
            : null,
      ),
      body: !profile.isComplete
          ? _buildSetupPrompt()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalizedTips(profile),
                _buildChallenges(),
                _buildRoutine(),
                _buildEmergencyKit(),
              ],
            ),
    );
  }

  Widget _buildSetupPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TropicalColors.forest.withOpacity(0.15),
                      TropicalColors.palmGreen.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Text('🧭', style: TextStyle(fontSize: 64)),
              ),
              const SizedBox(height: 24),
              const Text('Welcome to Survival',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: TropicalColors.deepSea)),
              const SizedBox(height: 12),
              const Text(
                'Personalized challenges, tips, and tricks to survive and thrive in any situation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF8B7355)),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: TropicalColors.palmGreen.withOpacity(0.3),
                      width: 1.5),
                ),
                child: Column(
                  children: [
                    _buildFeatureRow('🌍', 'Seasonal tips for your climate'),
                    _buildFeatureRow('🎂', 'Age-appropriate life advice'),
                    _buildFeatureRow('📍', 'Location-specific survival skills'),
                    _buildFeatureRow('🎯', '30-day challenges and routines'),
                    _buildFeatureRow('🎒', 'Emergency preparation checklists'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showProfileSetup,
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text('Get Started',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TropicalColors.forest,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13,
                    color: TropicalColors.coconut,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedTips(UserProfile profile) {
    final engine = SurvivalEngine(profile);
    final seasonalTips = engine.getSeasonalTips();
    final ageTips = engine.getAgeTips();
    final locationTips = engine.getLocationTips();
    final generalTips = engine.getGeneralTips();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TropicalColors.forest,
                  TropicalColors.palmGreen.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🧭', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Your Survival Profile',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                    GestureDetector(
                      onTap: _showProfileSetup,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Edit',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildProfileChip('🌤️', profile.season ?? ''),
                    _buildProfileChip('🎂', profile.ageRange ?? ''),
                    _buildProfileChip('📍', profile.locationType ?? ''),
                    _buildProfileChip('🌡️', profile.climate ?? ''),
                    _buildProfileChip('🏠', profile.livingSituation ?? ''),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('🌍 Seasonal Survival',
              'Tips for ${profile.season}'),
          const SizedBox(height: 8),
          ...seasonalTips
              .map((tip) => _buildTipCard(tip, TropicalColors.palmGreen)),
          const SizedBox(height: 20),
          _buildSectionHeader(
              '🎂 Age-Smart Advice', 'For ${profile.ageRange}'),
          const SizedBox(height: 8),
          ...ageTips.map((tip) => _buildTipCard(tip, TropicalColors.oceanBlue)),
          const SizedBox(height: 20),
          _buildSectionHeader('📍 Location Skills',
              '${profile.locationType} living'),
          const SizedBox(height: 8),
          ...locationTips
              .map((tip) => _buildTipCard(tip, TropicalColors.sunsetOrange)),
          const SizedBox(height: 20),
          _buildSectionHeader(
              '💎 Life Fundamentals', 'Universal survival truths'),
          const SizedBox(height: 8),
          ...generalTips
              .map((tip) => _buildTipCard(tip, TropicalColors.purple)),
        ],
      ),
    );
  }

  Widget _buildProfileChip(String emoji, String label) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTipCard(SurvivalTip tip, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(tip.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color)),
                const SizedBox(height: 4),
                Text(tip.body,
                    style: const TextStyle(
                        fontSize: 12,
                        color: TropicalColors.coconut,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallenges() {
    final engine = SurvivalEngine(_dataService.userProfile);
    final challenges = engine.getChallenges();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TropicalColors.sunsetOrange.withOpacity(0.15),
                  TropicalColors.hibiscus.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: TropicalColors.sunsetOrange.withOpacity(0.3),
                  width: 1.5),
            ),
            child: Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Level Up Your Life',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: TropicalColors.deepSea)),
                      Text('Try one challenge at a time. They compound.',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF8B7355))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...challenges.map((c) => _buildChallengeCard(c)),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Challenge c) {
    Color difficultyColor;
    switch (c.difficulty) {
      case 'Low':
        difficultyColor = TropicalColors.palmGreen;
        break;
      case 'Medium':
        difficultyColor = TropicalColors.sunsetOrange;
        break;
      case 'High':
        difficultyColor = TropicalColors.hibiscus;
        break;
      default:
        difficultyColor = TropicalColors.oceanBlue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: difficultyColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(c.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(c.title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: TropicalColors.deepSea)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(c.difficulty,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: difficultyColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(c.description,
              style: const TextStyle(
                  fontSize: 12,
                  color: TropicalColors.coconut,
                  height: 1.4)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: TropicalColors.sky.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(c.category,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: TropicalColors.deepSea)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoutine() {
    final engine = SurvivalEngine(_dataService.userProfile);
    final routine = engine.getDailyRoutine();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TropicalColors.oceanBlue.withOpacity(0.15),
                  TropicalColors.teal.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: TropicalColors.oceanBlue.withOpacity(0.3),
                  width: 1.5),
            ),
            child: Row(
              children: [
                const Text('⏰', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('The Ideal Day',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: TropicalColors.deepSea)),
                      Text('A framework, not a prison. Adapt to your life.',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF8B7355))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...routine.map((block) => _buildRoutineBlock(block)),
        ],
      ),
    );
  }

  Widget _buildRoutineBlock(RoutineBlock block) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: block.color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(block.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Container(
                width: 3,
                height: 30,
                decoration: BoxDecoration(
                  color: block.color.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: block.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(block.time,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: block.color)),
                ),
                const SizedBox(height: 4),
                Text(block.title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: block.color)),
                const SizedBox(height: 2),
                Text(block.description,
                    style: const TextStyle(
                        fontSize: 12,
                        color: TropicalColors.coconut,
                        height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyKit() {
    final engine = SurvivalEngine(_dataService.userProfile);
    final checklist = engine.getEmergencyChecklist();
    final essentials = checklist.where((c) => c.essential).toList();
    final extras = checklist.where((c) => !c.essential).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TropicalColors.hibiscus.withOpacity(0.15),
                  TropicalColors.sunsetOrange.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: TropicalColors.hibiscus.withOpacity(0.3),
                  width: 1.5),
            ),
            child: Row(
              children: [
                const Text('🎒', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('72-Hour Emergency Kit',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: TropicalColors.deepSea)),
                      Text('Pack once. Update yearly. Hope you never need it.',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF8B7355))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('⭐ Essentials', 'Must-haves for everyone'),
          const SizedBox(height: 8),
          ...essentials.map((item) => _buildKitItem(item, true)),
          const SizedBox(height: 20),
          _buildSectionHeader('➕ Add-Ons', 'Highly recommended'),
          const SizedBox(height: 8),
          ...extras.map((item) => _buildKitItem(item, false)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TropicalColors.charcoal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: TropicalColors.charcoal.withOpacity(0.2), width: 1),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    color: TropicalColors.charcoal, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Store your kit in a waterproof container near an exit. Check it every 6 months. Rotate food and water.',
                    style: TextStyle(
                        fontSize: 12,
                        color: TropicalColors.coconut,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKitItem(EmergencyItem item, bool essential) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: essential
                ? TropicalColors.palmGreen.withOpacity(0.3)
                : TropicalColors.sandDark,
            width: 1.5),
      ),
      child: Row(
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: TropicalColors.deepSea)),
                Text(item.detail,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF8B7355))),
              ],
            ),
          ),
          if (essential)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: TropicalColors.palmGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Essential',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: TropicalColors.palmGreen)),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: TropicalColors.deepSea)),
        Text(subtitle,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8B7355))),
      ],
    );
  }
}

// ============= PROFILE SETUP SHEET =============

class _ProfileSetupSheet extends StatefulWidget {
  final UserProfile initialProfile;
  final Function(UserProfile) onSave;

  const _ProfileSetupSheet({
    required this.initialProfile,
    required this.onSave,
  });

  @override
  State<_ProfileSetupSheet> createState() => _ProfileSetupSheetState();
}

class _ProfileSetupSheetState extends State<_ProfileSetupSheet> {
  late String? _season;
  late String? _ageRange;
  late String? _locationType;
  late String? _climate;
  late String? _livingSituation;

  final List<Map<String, String>> _seasons = [
    {'name': 'Spring', 'emoji': '🌸'},
    {'name': 'Summer', 'emoji': '☀️'},
    {'name': 'Fall', 'emoji': '🍂'},
    {'name': 'Winter', 'emoji': '❄️'},
  ];

  final List<Map<String, String>> _ageRanges = [
    {'name': 'Teen', 'emoji': '🎒'},
    {'name': 'Young Adult', 'emoji': '🎓'},
    {'name': 'Adult', 'emoji': '💼'},
    {'name': 'Middle Age', 'emoji': '🏡'},
    {'name': 'Senior', 'emoji': '🧓'},
  ];

  final List<Map<String, String>> _locations = [
    {'name': 'Urban', 'emoji': '🏙️'},
    {'name': 'Suburban', 'emoji': '🏘️'},
    {'name': 'Rural', 'emoji': '🌾'},
    {'name': 'Coastal', 'emoji': '🌊'},
    {'name': 'Mountain', 'emoji': '🏔️'},
  ];

  final List<Map<String, String>> _climates = [
    {'name': 'Tropical', 'emoji': '🌴'},
    {'name': 'Temperate', 'emoji': '🌤️'},
    {'name': 'Arid', 'emoji': '🏜️'},
    {'name': 'Cold', 'emoji': '🧊'},
    {'name': 'Humid', 'emoji': '💨'},
  ];

  final List<Map<String, String>> _livingSituations = [
    {'name': 'Alone', 'emoji': '🚪'},
    {'name': 'Family', 'emoji': '👨‍👩‍👧'},
    {'name': 'Roommates', 'emoji': '🏠'},
    {'name': 'Partner', 'emoji': '❤️'},
  ];

  @override
  void initState() {
    super.initState();
    _season = widget.initialProfile.season;
    _ageRange = widget.initialProfile.ageRange;
    _locationType = widget.initialProfile.locationType;
    _climate = widget.initialProfile.climate;
    _livingSituation = widget.initialProfile.livingSituation;
  }

  void _save() {
    if (_season == null ||
        _ageRange == null ||
        _locationType == null ||
        _climate == null ||
        _livingSituation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select all options',
              style: TextStyle(color: Colors.white)),
          backgroundColor: TropicalColors.hibiscus,
        ),
      );
      return;
    }
    widget.onSave(UserProfile(
      season: _season,
      ageRange: _ageRange,
      locationType: _locationType,
      climate: _climate,
      livingSituation: _livingSituation,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: TropicalColors.sky,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Text('🧭 ', style: TextStyle(fontSize: 24)),
                Text('Set Up Your Profile',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TropicalColors.deepSea)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
                'Choose what applies to you for personalized survival advice.',
                style: TextStyle(fontSize: 12, color: Color(0xFF8B7355))),
            const SizedBox(height: 20),
            _buildCategorySelector('🌸 Current Season', _seasons, _season,
                (v) => setState(() => _season = v)),
            const SizedBox(height: 16),
            _buildCategorySelector('🎂 Age Range', _ageRanges, _ageRange,
                (v) => setState(() => _ageRange = v)),
            const SizedBox(height: 16),
            _buildCategorySelector('📍 Location Type', _locations,
                _locationType, (v) => setState(() => _locationType = v)),
            const SizedBox(height: 16),
            _buildCategorySelector('🌡️ Climate', _climates, _climate,
                (v) => setState(() => _climate = v)),
            const SizedBox(height: 16),
            _buildCategorySelector('🏠 Living Situation', _livingSituations,
                _livingSituation, (v) => setState(() => _livingSituation = v)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: TropicalColors.sandDark),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: TropicalColors.coconut)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TropicalColors.forest,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Profile 🌺',
                        style: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(
      String title,
      List<Map<String, String>> options,
      String? selected,
      Function(String) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: TropicalColors.deepSea)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.map((opt) {
            final isSelected = selected == opt['name'];
            return GestureDetector(
              onTap: () => onSelect(opt['name']!),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(colors: [
                          TropicalColors.forest,
                          TropicalColors.palmGreen
                        ])
                      : null,
                  color: isSelected ? null : TropicalColors.sand,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? TropicalColors.forest
                        : TropicalColors.sandDark,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(opt['emoji']!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(opt['name']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : TropicalColors.coconut,
                        )),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ============= DAILY SCREEN =============

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  final DataService _dataService = DataService();
  final Map<String, TextEditingController> _controllers = {};
  String _currentTime = '';
  Timer? _timer;

  final List<DailyCategory> _categories = DailyCategory.categories;
  final List<WeeklyCategory> _weeklyCategories = WeeklyCategory.categories;

  @override
  void initState() {
    super.initState();
    for (var category in _categories) {
      _controllers[category.name] = TextEditingController();
    }
    _startClock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now().toLocal();
    final eastern = now.add(const Duration(hours: -5));
    if (mounted) {
      setState(() => _currentTime = DateFormat('h:mm:ss a').format(eastern));
    }
  }

  void _addDailyGoal(String category) {
    final text = _controllers[category]?.text.trim() ?? '';
    if (text.isNotEmpty) {
      _dataService.addDailyGoal(DailyGoalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        date: DateTime.now(),
        category: category,
      ));
      _controllers[category]?.clear();
      setState(() {});
    }
  }

  void _toggleDailyGoal(String id) {
    _dataService.toggleDailyGoal(id);
    setState(() {});
  }

  void _deleteDailyGoal(String id) {
    _dataService.deleteDailyGoal(id);
    setState(() {});
  }

  void _toggleWeeklyGoal(String key) {
    _dataService.toggleWeeklyCheckbox(key);
    setState(() {});
  }

  void _deleteWeeklyGoal(int index) {
    _dataService.deleteWeeklyGoal(index);
    setState(() {});
  }

  void _openDailyReminder(DailyGoalEntry goal) {
    showReminderMenu(
      context,
      initialReminder: goal.reminder,
      title: goal.text,
      onSave: (reminder) {
        _dataService.updateDailyReminder(goal.id, reminder);
        setState(() {});
      },
    );
  }

  void _openWeeklyReminder(int index, WeeklyGoal goal) {
    showReminderMenu(
      context,
      initialReminder: goal.reminder,
      title: goal.value,
      onSave: (reminder) {
        _dataService.updateWeeklyReminder(index, reminder);
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dayName = DateFormat('EEEE').format(today);
    final monthDay = DateFormat('MMMM d').format(today);
    final todayGoals = _dataService.getTodayDailyGoals();
    final completedCount = todayGoals.where((g) => g.isCompleted).length;
    final totalCount = todayGoals.length;
    final todaysWeeklyGoals = _dataService.getTodaysWeeklyGoals();
    final weeklyGoalsByDay = _dataService.getWeeklyGoalsByDay();
    final totalWeeklyGoals = _dataService.getTotalWeeklyGoals();

    return Scaffold(
      backgroundColor: TropicalColors.sand,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [TropicalColors.oceanBlue, TropicalColors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🌴 ', style: TextStyle(fontSize: 16)),
                Text('Island Goals',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                Text(' 🏝️', style: TextStyle(fontSize: 16)),
              ],
            ),
            Text('$dayName, $monthDay',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_currentTime,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, TropicalColors.sand],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: TropicalColors.sky, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: TropicalColors.sunshine.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text('☀️', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$completedCount of $totalCount done',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: TropicalColors.deepSea)),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value:
                              totalCount > 0 ? completedCount / totalCount : 0,
                          backgroundColor: TropicalColors.sandDark,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              TropicalColors.palmGreen),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${totalCount > 0 ? (completedCount / totalCount * 100).round() : 0}%',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: TropicalColors.palmGreen),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, TropicalColors.sand],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: TropicalColors.oceanBlue, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🌊', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      const Text('This Week\'s Voyage',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: TropicalColors.deepSea)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: TropicalColors.oceanBlue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('$totalWeeklyGoals goals',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: TropicalColors.deepSea)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDayColumn('Mon', weeklyGoalsByDay['Monday'] ?? []),
                      _buildDayColumn('Tue', weeklyGoalsByDay['Tuesday'] ?? []),
                      _buildDayColumn(
                          'Wed', weeklyGoalsByDay['Wednesday'] ?? []),
                      _buildDayColumn('Thu', weeklyGoalsByDay['Thursday'] ?? []),
                      _buildDayColumn('Fri', weeklyGoalsByDay['Friday'] ?? []),
                      _buildDayColumn('Sat', weeklyGoalsByDay['Saturday'] ?? []),
                      _buildDayColumn('Sun', weeklyGoalsByDay['Sunday'] ?? []),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (todaysWeeklyGoals.isNotEmpty) ...[
                    const Divider(color: TropicalColors.sky),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('🏄', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        const Text('Today\'s Waves',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: TropicalColors.sunsetOrange)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...todaysWeeklyGoals.map((entry) {
                      final colorIndex = entry.key % _weeklyCategories.length;
                      final catColor = _weeklyCategories[colorIndex].color;
                      final catName = _weeklyCategories[colorIndex].name;
                      final checkboxKey =
                          '${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}_${entry.key}';
                      final isChecked =
                          _dataService.weeklyCheckboxStates[checkboxKey] ??
                              false;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: TropicalColors.sand,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isChecked
                                ? TropicalColors.palmGreen
                                : TropicalColors.sky,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 5,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: catColor,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(catName,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: TropicalColors.coconut)),
                                      Text(
                                        entry.value.value,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isChecked
                                              ? TropicalColors.coconut
                                                  .withOpacity(0.5)
                                              : TropicalColors.deepSea,
                                          decoration: isChecked
                                              ? TextDecoration.lineThrough
                                              : null,
                                          fontWeight: isChecked
                                              ? FontWeight.w400
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                buildClockButton(
                                  reminder: entry.value.reminder,
                                  onTap: () => _openWeeklyReminder(
                                      entry.key, entry.value),
                                ),
                                const SizedBox(width: 4),
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (_) {
                                    _toggleWeeklyGoal(checkboxKey);
                                    setState(() {});
                                  },
                                  activeColor: TropicalColors.palmGreen,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: TropicalColors.hibiscus, size: 20),
                                  onPressed: () {
                                    _deleteWeeklyGoal(entry.key);
                                    setState(() {});
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                ),
                              ],
                            ),
                            if (entry.value.reminder != null &&
                                entry.value.reminder!.hasReminder)
                              Padding(
                                padding: const EdgeInsets.only(left: 17, top: 4),
                                child: buildReminderChipStatic(
                                    entry.value.reminder!),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TropicalColors.sand,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('🌺 No weekly goals today',
                            style: TextStyle(
                                fontSize: 13, color: TropicalColors.coconut)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._categories.map((category) {
              final categoryGoals =
                  todayGoals.where((g) => g.category == category.name).toList();

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: category.color.withOpacity(0.3), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(category.emoji,
                              style: const TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(width: 10),
                        Text(category.name,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: category.color)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (categoryGoals.isNotEmpty)
                      ...categoryGoals.map((goal) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: TropicalColors.sand,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: goal.isCompleted
                                  ? TropicalColors.palmGreen
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Checkbox(
                                  value: goal.isCompleted,
                                  onChanged: (_) {
                                    _toggleDailyGoal(goal.id);
                                    setState(() {});
                                  },
                                  activeColor: TropicalColors.palmGreen,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                title: Text(
                                  goal.text,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: goal.isCompleted
                                        ? TropicalColors.coconut
                                            .withOpacity(0.5)
                                        : TropicalColors.coconut,
                                    decoration: goal.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    fontWeight: goal.isCompleted
                                        ? FontWeight.w400
                                        : FontWeight.w500,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    buildClockButton(
                                      reminder: goal.reminder,
                                      onTap: () => _openDailyReminder(goal),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          size: 16,
                                          color: TropicalColors.hibiscus),
                                      onPressed: () {
                                        _deleteDailyGoal(goal.id);
                                        setState(() {});
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                          minWidth: 32, minHeight: 32),
                                    ),
                                  ],
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 0),
                                dense: true,
                                minLeadingWidth: 0,
                              ),
                              if (goal.reminder != null &&
                                  goal.reminder!.hasReminder)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 44, right: 8, bottom: 6),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child:
                                        buildReminderChipStatic(goal.reminder!),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: TropicalColors.sand,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: TropicalColors.sandDark),
                            ),
                            child: TextField(
                              controller: _controllers[category.name],
                              style: const TextStyle(
                                  fontSize: 13, color: TropicalColors.coconut),
                              decoration: InputDecoration(
                                hintText:
                                    'Add ${category.name.toLowerCase()} goal...',
                                hintStyle: const TextStyle(
                                    color: Color(0xFF8B7355), fontSize: 12),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                              onSubmitted: (_) => _addDailyGoal(category.name),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                category.color,
                                category.color.withOpacity(0.7)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => _addDailyGoal(category.name),
                            icon: const Icon(Icons.add,
                                color: Colors.white, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                                minWidth: 40, minHeight: 40),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDayColumn(String dayName, List<MapEntry<int, WeeklyGoal>> goals) {
    final isCurrentDay =
        dayName == DateFormat('EEEE').format(DateTime.now()).substring(0, 3);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isCurrentDay
              ? TropicalColors.oceanBlue.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isCurrentDay
              ? Border.all(color: TropicalColors.oceanBlue, width: 1.5)
              : null,
        ),
        child: Column(
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrentDay ? FontWeight.w700 : FontWeight.w500,
                color: isCurrentDay
                    ? TropicalColors.deepSea
                    : TropicalColors.coconut,
              ),
            ),
            const SizedBox(height: 4),
            if (goals.isNotEmpty)
              Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: goals.map((entry) {
                  final colorIndex = entry.key % _weeklyCategories.length;
                  final catColor = _weeklyCategories[colorIndex].color;
                  final checkboxKey =
                      '${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}_${entry.key}';
                  final isChecked =
                      _dataService.weeklyCheckboxStates[checkboxKey] ?? false;
                  return Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isChecked ? catColor.withOpacity(0.3) : catColor,
                      shape: BoxShape.circle,
                      border: isChecked
                          ? Border.all(color: catColor, width: 1)
                          : null,
                    ),
                  );
                }).toList(),
              )
            else
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: TropicalColors.sandDark,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============= WEEKLY SCREEN =============

class WeeklyScreen extends StatefulWidget {
  const WeeklyScreen({super.key});

  @override
  State<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  final DataService _dataService = DataService();
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, String> _selectedDays = {};
  bool _isLoading = true;

  final List<WeeklyCategory> _categories = WeeklyCategory.categories;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _categories.length; i++) {
      _controllers[i] = TextEditingController();
      _selectedDays[i] = 'Monday';
    }
    _loadData();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    await _dataService.loadAllData();
    for (int i = 0; i < _categories.length; i++) {
      if (_dataService.weeklyEntries.containsKey(i)) {
        _controllers[i]?.text = _dataService.weeklyEntries[i]!.value;
        _selectedDays[i] = _dataService.weeklyEntries[i]!.day;
      }
    }
    setState(() => _isLoading = false);
  }

  void _updateEntry(int index) {
    final text = _controllers[index]!.text.trim();
    final day = _selectedDays[index] ?? 'Monday';
    if (text.isNotEmpty) {
      _dataService.addWeeklyGoal(index, text, day);
      setState(() {});
    }
  }

  void _deleteWeeklyGoal(int index) {
    _dataService.deleteWeeklyGoal(index);
    _controllers[index]?.clear();
    setState(() {});
  }

  void _toggleCheckbox(String key) {
    _dataService.toggleWeeklyCheckbox(key);
    setState(() {});
  }

  void _openReminder(int index) {
    final goal = _dataService.weeklyEntries[index];
    if (goal == null) return;
    showReminderMenu(
      context,
      initialReminder: goal.reminder,
      title: goal.value,
      onSave: (reminder) {
        _dataService.updateWeeklyReminder(index, reminder);
        setState(() {});
      },
    );
  }

  void _showCalendarView() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: WeeklyCalendarView(
            savedEntries: _dataService.weeklyEntries,
            categories: _categories,
            checkboxStates: _dataService.weeklyCheckboxStates,
            onCheckboxToggle: _toggleCheckbox,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: TropicalColors.sand,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(TropicalColors.oceanBlue),
          ),
        ),
      );
    }

    final totalGoals = _dataService.getTotalWeeklyGoals();
    final completedGoals =
        _dataService.weeklyCheckboxStates.values.where((v) => v).length;

    return Scaffold(
      backgroundColor: TropicalColors.sand,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [TropicalColors.oceanBlue, TropicalColors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🏄 ', style: TextStyle(fontSize: 16)),
            Text('Weekly Waves',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            Text(' 🌊', style: TextStyle(fontSize: 16)),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: Colors.white),
            onPressed: _showCalendarView,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: TropicalColors.sand,
            child: Row(
              children: [
                _buildStatCard('Total', totalGoals.toString(),
                    TropicalColors.oceanBlue),
                _buildStatCard('Done', completedGoals.toString(),
                    TropicalColors.palmGreen),
                _buildStatCard('Left', (totalGoals - completedGoals).toString(),
                    TropicalColors.sunsetOrange),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              itemBuilder: (context, index) => _buildGoalCard(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: TropicalColors.coconut,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(int index) {
    final category = _categories[index];
    final hasSaved = _dataService.weeklyEntries.containsKey(index);
    final goal = hasSaved ? _dataService.weeklyEntries[index] : null;
    final savedValue = goal?.value ?? '';
    final savedDay = goal?.day ?? 'Not set';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: category.color.withOpacity(0.3), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Text(category.emoji, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(category.name,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: category.color)),
                ),
                if (hasSaved) ...[
                  buildClockButton(
                    reminder: goal!.reminder,
                    onTap: () => _openReminder(index),
                  ),
                  const SizedBox(width: 6),
                ],
                if (hasSaved)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: TropicalColors.palmGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🌺 SAVED',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: TropicalColors.palmGreen)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(category.description,
                style:
                    const TextStyle(fontSize: 12, color: Color(0xFF8B7355))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: TropicalColors.sand,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TropicalColors.sandDark),
                    ),
                    child: TextField(
                      controller: _controllers[index],
                      style: const TextStyle(
                          fontSize: 14, color: TropicalColors.coconut),
                      decoration: const InputDecoration(
                        hintText: 'Enter weekly goal...',
                        hintStyle:
                            TextStyle(color: Color(0xFF8B7355), fontSize: 13),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) => _updateEntry(index),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                    color: TropicalColors.sand,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TropicalColors.sandDark),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDays[index],
                      style: const TextStyle(
                          fontSize: 12, color: TropicalColors.coconut),
                      icon: const Icon(Icons.arrow_drop_down,
                          size: 16, color: TropicalColors.coconut),
                      items: const [
                        'Monday',
                        'Tuesday',
                        'Wednesday',
                        'Thursday',
                        'Friday',
                        'Saturday',
                        'Sunday'
                      ]
                          .map((day) => DropdownMenuItem(
                              value: day, child: Text(day.substring(0, 3))))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedDays[index] = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [TropicalColors.oceanBlue, TropicalColors.teal]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: () => _updateEntry(index),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size(60, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Save',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
                  ),
                ),
                if (hasSaved) ...[
                  const SizedBox(width: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: TropicalColors.hibiscus,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton(
                      onPressed: () => _deleteWeeklyGoal(index),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size(36, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ],
            ),
            if (hasSaved) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: TropicalColors.sand,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TropicalColors.sandDark),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: TropicalColors.palmGreen, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(savedValue,
                          style: const TextStyle(
                              fontSize: 13,
                              color: TropicalColors.coconut,
                              fontWeight: FontWeight.w500)),
                    ),
                    Text(_selectedDays[index] ?? savedDay,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF8B7355))),
                  ],
                ),
              ),
              if (goal!.reminder != null && goal.reminder!.hasReminder) ...[
                const SizedBox(height: 6),
                buildReminderChipStatic(goal.reminder!),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ============= HABIT SCREEN =============

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen>
    with SingleTickerProviderStateMixin {
  final DataService _dataService = DataService();
  final TextEditingController _habitController = TextEditingController();
  final TextEditingController _badHabitController = TextEditingController();
  String _selectedIcon = '🌺';
  String _selectedBadIcon = '🚫';
  int _selectedPeriod = 7;
  String _currentTime = '';
  Timer? _timer;
  late TabController _tabController;

  final List<String> _availableIcons = [
    '🌺', '🥥', '🌴', '🏄', '🌊', '🐠', '🦩', '🌅', '☀️', '🥗',
    '💧', '🏃', '🧘', '📖', '✍️', '🧴', '🚶', '🌙', '💪', '🧠',
    '❤️', '🌟', '🎯', '📚', '🎨', '🎵', '🧹', '🐚', '🍍', '🥭'
  ];

  final List<String> _badHabitIcons = [
    '🚫', '🚬', '🍺', '🍔', '🍩', '📱', '☕', '🎮', '🛒', '💸',
    '😤', '😴', '🍭', '🥤', '🍟', '📺', '🎰', '💊', '🗯️', '😡'
  ];

  final List<Map<String, String>> _commonBadHabits = [
    {'name': 'Smoking', 'icon': '🚬'},
    {'name': 'Drinking alcohol', 'icon': '🍺'},
    {'name': 'Junk food', 'icon': '🍔'},
    {'name': 'Sugary drinks', 'icon': '🥤'},
    {'name': 'Doomscrolling', 'icon': '📱'},
    {'name': 'Excessive caffeine', 'icon': '☕'},
    {'name': 'Video games', 'icon': '🎮'},
    {'name': 'Impulse shopping', 'icon': '🛒'},
    {'name': 'Oversleeping', 'icon': '😴'},
    {'name': 'Nail biting', 'icon': '💅'},
    {'name': 'Late-night snacking', 'icon': '🍩'},
    {'name': 'TV binging', 'icon': '📺'},
    {'name': 'Gossiping', 'icon': '🗯️'},
    {'name': 'Procrastinating', 'icon': '⏰'},
    {'name': 'Energy drinks', 'icon': '⚡'},
  ];

  @override
  void initState() {
    super.initState();
    if (!_availableIcons.contains(_selectedIcon)) {
      _selectedIcon = _availableIcons.first;
    }
    if (!_badHabitIcons.contains(_selectedBadIcon)) {
      _selectedBadIcon = _badHabitIcons.first;
    }
    _tabController = TabController(length: 2, vsync: this);
    _startClock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _habitController.dispose();
    _badHabitController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now().toLocal();
    final eastern = now.add(const Duration(hours: -5));
    if (mounted) {
      setState(() => _currentTime = DateFormat('h:mm:ss a').format(eastern));
    }
  }

  void _addHabit() {
    final name = _habitController.text.trim();
    if (name.isNotEmpty) {
      _dataService.addHabit(name, _selectedIcon);
      _habitController.clear();
      setState(() {});
    }
  }

  void _deleteHabit(String id) {
    _dataService.deleteHabit(id);
    setState(() {});
  }

  void _toggleHabit(String id, DateTime date) {
    _dataService.toggleHabit(id, date);
    setState(() {});
  }

  void _openHabitReminder(HabitEntry habit) {
    showReminderMenu(
      context,
      initialReminder: habit.reminder,
      title: habit.name,
      onSave: (reminder) {
        _dataService.updateHabitReminder(habit.id, reminder);
        setState(() {});
      },
    );
  }

  void _addBadHabit(String name, String icon) {
    if (name.isNotEmpty) {
      _dataService.addBadHabit(name, icon);
      _badHabitController.clear();
      setState(() {});
    }
  }

  void _deleteBadHabit(String id) {
    _dataService.deleteBadHabit(id);
    setState(() {});
  }

  void _recordRelapse(String id) {
    _dataService.recordRelapse(id);
    setState(() {});
  }

  void _openBadHabitReminder(BadHabitEntry habit) {
    showReminderMenu(
      context,
      initialReminder: habit.reminder,
      title: 'Avoid: ${habit.name}',
      onSave: (reminder) {
        _dataService.updateBadHabitReminder(habit.id, reminder);
        setState(() {});
      },
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TropicalColors.sand,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [TropicalColors.oceanBlue, TropicalColors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🌺 ', style: TextStyle(fontSize: 16)),
            Text('Island Habits',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            Text(' 🦩', style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_currentTime,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: TropicalColors.sunshine,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: '🌱 Build Good Habits'),
            Tab(text: '🚫 Quit Bad Habits'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGoodHabitsTab(),
          _buildBadHabitsTab(),
        ],
      ),
    );
  }

  Widget _buildGoodHabitsTab() {
    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: _selectedPeriod - 1));
    final habits = _dataService.getHabits();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border:
                Border(bottom: BorderSide(color: TropicalColors.sky, width: 1)),
          ),
          child: Row(
            children: [
              const Text('🌴 ', style: TextStyle(fontSize: 14)),
              const Text('Show:',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TropicalColors.deepSea)),
              const SizedBox(width: 12),
              _buildPeriodButton(7, '7 Days'),
              _buildPeriodButton(14, '14 Days'),
              _buildPeriodButton(30, '30 Days'),
            ],
          ),
        ),
        Expanded(
          child: habits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('🏝️', style: TextStyle(fontSize: 64)),
                      SizedBox(height: 16),
                      Text('No habits yet',
                          style: TextStyle(
                              fontSize: 16,
                              color: TropicalColors.coconut,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    final streak = _dataService.getHabitStreak(habit.id);
                    final days = _getDaysInPeriod(startDate, today);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: TropicalColors.teal.withOpacity(0.3),
                            width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: TropicalColors.sand,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(habit.icon,
                                      style: const TextStyle(fontSize: 22)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(habit.name,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  TropicalColors.deepSea)),
                                      if (streak > 0)
                                        Text('$streak day streak 🔥',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: TropicalColors
                                                    .sunsetOrange,
                                                fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                buildClockButton(
                                  reminder: habit.reminder,
                                  onTap: () => _openHabitReminder(habit),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: TropicalColors.hibiscus, size: 20),
                                  onPressed: () => _deleteHabit(habit.id),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                              height: 1, color: TropicalColors.sandDark),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              children: days.map((date) {
                                final isCompleted =
                                    habit.isCompletedOn(date);
                                final isToday = date.year == today.year &&
                                    date.month == today.month &&
                                    date.day == today.day;

                                return GestureDetector(
                                  onTap: () {
                                    if (isToday) {
                                      _toggleHabit(habit.id, date);
                                    }
                                  },
                                  child: Container(
                                    width: 38,
                                    height: 46,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    decoration: BoxDecoration(
                                      gradient: isCompleted
                                          ? const LinearGradient(
                                              colors: [
                                                TropicalColors.palmGreen,
                                                TropicalColors.teal
                                              ],
                                            )
                                          : null,
                                      color: isCompleted
                                          ? null
                                          : isToday
                                              ? TropicalColors.oceanBlue
                                                  .withOpacity(0.15)
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: isToday
                                          ? Border.all(
                                              color: TropicalColors.oceanBlue,
                                              width: 2)
                                          : null,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(DateFormat('E').format(date),
                                            style: TextStyle(
                                                fontSize: 9,
                                                color: isCompleted
                                                    ? Colors.white
                                                    : TropicalColors.coconut)),
                                        Text(DateFormat('d').format(date),
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: isCompleted
                                                    ? Colors.white
                                                    : TropicalColors.deepSea,
                                                fontWeight: isToday
                                                    ? FontWeight.w700
                                                    : FontWeight.w400)),
                                        if (isCompleted)
                                          const Icon(Icons.check,
                                              color: Colors.white, size: 12),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border:
                Border(top: BorderSide(color: TropicalColors.sky, width: 1)),
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: TropicalColors.sand,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TropicalColors.sandDark),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _availableIcons.contains(_selectedIcon)
                        ? _selectedIcon
                        : _availableIcons.first,
                    style: const TextStyle(fontSize: 24),
                    items: _availableIcons
                        .map((icon) => DropdownMenuItem<String>(
                            value: icon,
                            child: Text(icon,
                                style: const TextStyle(fontSize: 24))))
                        .toList(),
                    onChanged: (value) {
                      if (value != null && mounted) {
                        setState(() => _selectedIcon = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: TropicalColors.sand,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TropicalColors.sandDark),
                  ),
                  child: TextField(
                    controller: _habitController,
                    style: const TextStyle(
                        fontSize: 14, color: TropicalColors.coconut),
                    decoration: const InputDecoration(
                      hintText: 'Add new habit...',
                      hintStyle:
                          TextStyle(color: Color(0xFF8B7355), fontSize: 13),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (_) => _addHabit(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [TropicalColors.oceanBlue, TropicalColors.teal]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: _addHabit,
                  icon: const Icon(Icons.add, color: Colors.white, size: 24),
                  padding: const EdgeInsets.all(0),
                  constraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadHabitsTab() {
    final badHabits = _dataService.getBadHabits();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                TropicalColors.hibiscus.withOpacity(0.15),
                TropicalColors.sunsetOrange.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: TropicalColors.hibiscus.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            children: [
              const Text('💪', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Break Free, One Day at a Time',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: TropicalColors.deepSea)),
                    Text(
                      badHabits.isEmpty
                          ? 'Add a habit you want to quit!'
                          : 'You\'re tracking ${badHabits.length} habit${badHabits.length > 1 ? 's' : ''}. Keep going! 🌟',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF8B7355)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: badHabits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('🎯', style: TextStyle(fontSize: 64)),
                      SizedBox(height: 16),
                      Text('No bad habits tracked',
                          style: TextStyle(
                              fontSize: 16,
                              color: TropicalColors.coconut,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: badHabits.length,
                  itemBuilder: (context, index) {
                    final habit = badHabits[index];
                    final currentStreak = habit.getCurrentStreak();
                    final longestStreak = habit.getLongestStreak();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: TropicalColors.palmGreen.withOpacity(0.4),
                            width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: TropicalColors.hibiscus
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(habit.icon,
                                      style: const TextStyle(fontSize: 24)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(habit.name,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: TropicalColors.deepSea)),
                                ),
                                buildClockButton(
                                  reminder: habit.reminder,
                                  onTap: () => _openBadHabitReminder(habit),
                                  color: TropicalColors.hibiscus,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: TropicalColors.hibiscus, size: 20),
                                  onPressed: () => _deleteBadHabit(habit.id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    TropicalColors.palmGreen.withOpacity(0.2),
                                    TropicalColors.teal.withOpacity(0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: TropicalColors.palmGreen
                                        .withOpacity(0.5),
                                    width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  const Text('🌟',
                                      style: TextStyle(fontSize: 32)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('CLEAN STREAK',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: TropicalColors
                                                    .palmGreen,
                                                letterSpacing: 1)),
                                        Text('$currentStreak',
                                            style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: TropicalColors
                                                    .palmGreen,
                                                height: 1.0)),
                                        Text(
                                          currentStreak == 1 ? 'day' : 'days',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: TropicalColors.coconut),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Best',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF8B7355),
                                              fontWeight: FontWeight.w600)),
                                      Text('$longestStreak',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: TropicalColors.oceanBlue)),
                                      const Text('days',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF8B7355))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _recordRelapse(habit.id),
                                    icon: const Icon(Icons.refresh,
                                        size: 16,
                                        color: TropicalColors.sunsetOrange),
                                    label: const Text('Record Slip',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                TropicalColors.sunsetOrange)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      side: BorderSide(
                                          color: TropicalColors.sunsetOrange
                                              .withOpacity(0.5),
                                          width: 1.5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _dataService.resetBadHabitStreak(
                                          habit.id);
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.restart_alt,
                                        size: 16, color: Colors.white),
                                    label: const Text('Restart',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          TropicalColors.palmGreen,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border:
                Border(top: BorderSide(color: TropicalColors.sky, width: 1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add a Bad Habit to Quit',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: TropicalColors.deepSea)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: TropicalColors.sand,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TropicalColors.sandDark),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _badHabitIcons.contains(_selectedBadIcon)
                            ? _selectedBadIcon
                            : _badHabitIcons.first,
                        style: const TextStyle(fontSize: 24),
                        items: _badHabitIcons
                            .map((icon) => DropdownMenuItem<String>(
                                value: icon,
                                child: Text(icon,
                                    style: const TextStyle(fontSize: 24))))
                            .toList(),
                        onChanged: (value) {
                          if (value != null && mounted) {
                            setState(() => _selectedBadIcon = value);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: TropicalColors.sand,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: TropicalColors.sandDark),
                      ),
                      child: TextField(
                        controller: _badHabitController,
                        style: const TextStyle(
                            fontSize: 14, color: TropicalColors.coconut),
                        decoration: const InputDecoration(
                          hintText: 'Add bad habit...',
                          hintStyle: TextStyle(
                              color: Color(0xFF8B7355), fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        onSubmitted: (_) => _addBadHabit(
                            _badHabitController.text.trim(), _selectedBadIcon),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        TropicalColors.hibiscus,
                        TropicalColors.sunsetOrange
                      ]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _addBadHabit(
                          _badHabitController.text.trim(), _selectedBadIcon),
                      icon: const Icon(Icons.add,
                          color: Colors.white, size: 24),
                      padding: const EdgeInsets.all(0),
                      constraints:
                          const BoxConstraints(minWidth: 44, minHeight: 44),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _commonBadHabits.length,
                  itemBuilder: (context, index) {
                    final bad = _commonBadHabits[index];
                    return GestureDetector(
                      onTap: () => _addBadHabit(bad['name']!, bad['icon']!),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: TropicalColors.sand,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: TropicalColors.hibiscus
                                  .withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(bad['icon']!,
                                style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(bad['name']!,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: TropicalColors.deepSea,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(int days, String label) {
    final isSelected = _selectedPeriod == days;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = days),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [TropicalColors.oceanBlue, TropicalColors.teal])
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? TropicalColors.oceanBlue : TropicalColors.sky,
            width: 1.5,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : TropicalColors.coconut)),
      ),
    );
  }

  List<DateTime> _getDaysInPeriod(DateTime start, DateTime end) {
    final days = <DateTime>[];
    DateTime current = DateTime(start.year, start.month, start.day);
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }
}

// ============= REPORT SCREEN =============

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  final DataService _dataService = DataService();
  late TabController _tabController;
  String _currentTime = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startClock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now().toLocal();
    final eastern = now.add(const Duration(hours: -5));
    if (mounted) {
      setState(() => _currentTime = DateFormat('h:mm:ss a').format(eastern));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TropicalColors.sand,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [TropicalColors.purple, TropicalColors.oceanBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📊 ', style: TextStyle(fontSize: 16)),
            Text('Insights',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            Text(' 🔍', style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_currentTime,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: TropicalColors.sunshine,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          tabs: const [
            Tab(text: '📅 Daily'),
            Tab(text: '🗓️ Weekly'),
            Tab(text: '📈 Monthly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyReport(),
          _buildWeeklyReport(),
          _buildMonthlyReport(),
        ],
      ),
    );
  }

  Widget _buildDailyReport() {
    final stats = _dataService.getOverallStats();
    final todayDaily = stats['todayDailyCompleted'] as int;
    final todayDailyTotal = stats['todayDailyTotal'] as int;
    final todayHabit = stats['todayHabitCompleted'] as int;
    final todayHabitTotal = stats['todayHabitTotal'] as int;
    final dailyRate = todayDailyTotal > 0
        ? (todayDaily / todayDailyTotal * 100).round()
        : 0;
    final habitRate =
        todayHabitTotal > 0 ? (todayHabit / todayHabitTotal * 100).round() : 0;
    final combinedTotal = todayDailyTotal + todayHabitTotal;
    final combinedDone = todayDaily + todayHabit;
    final combinedRate =
        combinedTotal > 0 ? (combinedDone / combinedTotal * 100).round() : 0;

    final badHabits = _dataService.getBadHabits();
    final bestCleanStreak = badHabits.isEmpty
        ? 0
        : badHabits.map((b) => b.getCurrentStreak()).reduce(math.max);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(
            title: 'Today\'s Performance',
            emoji: '☀️',
            mainValue: '$combinedRate%',
            subtitle: '$combinedDone of $combinedTotal items completed',
            gradient: [TropicalColors.oceanBlue, TropicalColors.teal],
            progress: combinedTotal > 0 ? combinedDone / combinedTotal : 0,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniCard(
                  emoji: '🎯',
                  title: 'Daily Goals',
                  value: '$todayDaily/$todayDailyTotal',
                  percentage: dailyRate,
                  color: TropicalColors.oceanBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniCard(
                  emoji: '🌺',
                  title: 'Habits',
                  value: '$todayHabit/$todayHabitTotal',
                  percentage: habitRate,
                  color: TropicalColors.palmGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniCard(
                  emoji: '💪',
                  title: 'Best Streak',
                  value: '$bestCleanStreak days',
                  percentage: bestCleanStreak > 0 ? 100 : 0,
                  color: TropicalColors.hibiscus,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('📊 Last 7 Days Trend',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: TropicalColors.deepSea)),
          const SizedBox(height: 8),
          _buildTrendChart(),
        ],
      ),
    );
  }

  Widget _buildWeeklyReport() {
    final stats = _dataService.getOverallStats();
    final dailyCompleted = stats['dailyCompleted7'] as int;
    final dailyTotal = stats['dailyTotal7'] as int;
    final habitCompletions = stats['habitCompletions7'] as int;
    final habitPossible = stats['habitPossible7'] as int;
    final weeklyCompleted = stats['weeklyCompleted'] as int;
    final weeklyTotal = stats['weeklyTotal'] as int;
    final dailyRate =
        dailyTotal > 0 ? (dailyCompleted / dailyTotal * 100).round() : 0;
    final habitRate = habitPossible > 0
        ? (habitCompletions / habitPossible * 100).round()
        : 0;
    final weeklyRate =
        weeklyTotal > 0 ? (weeklyCompleted / weeklyTotal * 100).round() : 0;

    final weekData = _dataService.getDailyGoalsHistory(7);
    final habitWeekData = _dataService.getHabitsHistory(7);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(
            title: 'This Week\'s Progress',
            emoji: '🗓️',
            mainValue: '${((dailyRate + habitRate) / 2).round()}%',
            subtitle: 'Average completion this week',
            gradient: [TropicalColors.purple, TropicalColors.oceanBlue],
            progress: (dailyRate + habitRate) / 200,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniCard(
                  emoji: '🎯',
                  title: 'Daily Goals',
                  value: '$dailyCompleted/$dailyTotal',
                  percentage: dailyRate,
                  color: TropicalColors.oceanBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniCard(
                  emoji: '🌺',
                  title: 'Habit Days',
                  value: '$habitCompletions/$habitPossible',
                  percentage: habitRate,
                  color: TropicalColors.palmGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniCard(
                  emoji: '🏄',
                  title: 'Weekly Goals',
                  value: '$weeklyCompleted/$weeklyTotal',
                  percentage: weeklyRate,
                  color: TropicalColors.sunsetOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('📊 Daily Goals This Week',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: TropicalColors.deepSea)),
          const SizedBox(height: 8),
          _buildWeeklyBarChart(
              weekData, 'Daily Goals', TropicalColors.oceanBlue),
          const SizedBox(height: 20),
          const Text('🌺 Habits This Week',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: TropicalColors.deepSea)),
          const SizedBox(height: 8),
          _buildWeeklyBarChart(
              habitWeekData, 'Habits Completed', TropicalColors.palmGreen),
          const SizedBox(height: 20),
          const Text('🎯 Category Breakdown (7 Days)',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: TropicalColors.deepSea)),
          const SizedBox(height: 8),
          _buildCategoryBreakdown(7),
        ],
      ),
    );
  }

  Widget _buildMonthlyReport() {
    final stats = _dataService.getOverallStats();
    final dailyCompleted = stats['dailyCompleted30'] as int;
    final dailyTotal = stats['dailyTotal30'] as int;
    final habitCompletions = stats['habitCompletions30'] as int;
    final dailyRate =
        dailyTotal > 0 ? (dailyCompleted / dailyTotal * 100).round() : 0;
    final badHabits = _dataService.getBadHabits();
    final totalCleanDays = stats['cleanDays'] as int;
    final totalRelapses = stats['relapses'] as int;
    final monthData = _dataService.getDailyGoalsHistory(30);

    int bestDayCount = 0;
    DateTime? bestDay;
    for (var d in monthData) {
      if ((d['completed'] as int) > bestDayCount) {
        bestDayCount = d['completed'] as int;
        bestDay = d['date'] as DateTime;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(
            title: 'This Month\'s Journey',
            emoji: '📈',
            mainValue: '$dailyRate%',
            subtitle: '30-day goal completion rate',
            gradient: [TropicalColors.sunsetOrange, TropicalColors.hibiscus],
            progress: dailyRate / 100,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniCard(
                  emoji: '🎯',
                  title: 'Goals Done',
                  value: '$dailyCompleted',
                  percentage: dailyRate,
                  color: TropicalColors.oceanBlue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniCard(
                  emoji: '🌺',
                  title: 'Habit Days',
                  value: '$habitCompletions',
                  percentage: habitCompletions > 0 ? 100 : 0,
                  color: TropicalColors.palmGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniCard(
                  emoji: '💪',
                  title: 'Clean Days',
                  value: '$totalCleanDays',
                  percentage: totalCleanDays > 0 ? 100 : 0,
                  color: TropicalColors.hibiscus,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (bestDay != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TropicalColors.sunshine.withOpacity(0.3),
                    TropicalColors.sunsetOrange.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: TropicalColors.sunshine.withOpacity(0.5),
                    width: 1.5),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Best Day This Month',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: TropicalColors.coconut)),
                        Text(DateFormat('EEEE, MMM d').format(bestDay),
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: TropicalColors.deepSea)),
                      ],
                    ),
                  ),
                  Text('$bestDayCount',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: TropicalColors.sunsetOrange)),
                ],
              ),
            ),
          const SizedBox(height: 20),
          const Text('📊 30-Day Goal Trend',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: TropicalColors.deepSea)),
          const SizedBox(height: 8),
          _buildMonthlyTrendChart(monthData),
          if (badHabits.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('💪 Bad Habit Progress',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: TropicalColors.deepSea)),
            const SizedBox(height: 8),
            ...badHabits.map((habit) => _buildBadHabitReportCard(habit)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TropicalColors.palmGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'You have $totalCleanDays total clean days and only $totalRelapses slip${totalRelapses == 1 ? '' : 's'}. Keep going! 🌟',
                style: const TextStyle(
                    fontSize: 12, color: TropicalColors.coconut),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String emoji,
    required String mainValue,
    required String subtitle,
    required List<Color> gradient,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(mainValue,
              style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withOpacity(0.9))),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard({
    required String emoji,
    required String title,
    required String value,
    required int percentage,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(title,
              style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF8B7355),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    final dailyData = _dataService.getDailyGoalsHistory(7);
    final habitData = _dataService.getHabitsHistory(7);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: TropicalColors.sky.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: dailyData.map((d) {
              final date = d['date'] as DateTime;
              final rate = d['rate'] as int;
              return _buildBarColumn(
                DateFormat('E').format(date).substring(0, 3),
                rate,
                TropicalColors.oceanBlue,
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          const Text('Daily Goals',
              style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8B7355),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: habitData.map((d) {
              final date = d['date'] as DateTime;
              final rate = d['rate'] as int;
              return _buildBarColumn(
                DateFormat('E').format(date).substring(0, 3),
                rate,
                TropicalColors.palmGreen,
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          const Text('Habits',
              style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8B7355),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart(
      List<Map<String, dynamic>> data, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((d) {
              final date = d['date'] as DateTime;
              final completed = d['completed'] as int;
              final total = d['total'] as int;
              final rate = d['rate'] as int;
              return Expanded(
                child: Column(
                  children: [
                    Text('$completed',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color)),
                    const SizedBox(height: 3),
                    Container(
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: total > 0 ? (rate / 100) * 60 : 0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.6)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(DateFormat('E').format(date).substring(0, 3),
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF8B7355))),
                    Text('$completed/$total',
                        style: TextStyle(
                            fontSize: 9, color: color.withOpacity(0.8))),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8B7355),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendChart(List<Map<String, dynamic>> data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: TropicalColors.sunsetOrange.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final rate = d['rate'] as int;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0.5),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: rate > 0 ? (rate / 100) * 100 : 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: rate >= 70
                              ? [TropicalColors.palmGreen, TropicalColors.teal]
                              : rate >= 40
                                  ? [
                                      TropicalColors.sunsetOrange,
                                      TropicalColors.sunshine
                                    ]
                                  : [
                                      TropicalColors.hibiscus,
                                      TropicalColors.sunsetPink
                                    ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(2)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('MMM d').format(data.first['date'] as DateTime),
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF8B7355))),
              const Text('30-Day Trend',
                  style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8B7355),
                      fontWeight: FontWeight.w600)),
              Text(DateFormat('MMM d').format(data.last['date'] as DateTime),
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF8B7355))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarColumn(String label, int rate, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text('$rate%',
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 3),
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            alignment: Alignment.bottomCenter,
            child: Container(
              height: rate > 0 ? (rate / 100) * 50 : 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.6)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8B7355),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(int days) {
    final breakdown = _dataService.getCategoryBreakdown(days);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TropicalColors.sky.withOpacity(0.4)),
      ),
      child: Column(
        children: breakdown.entries.map((entry) {
          final name = entry.key;
          final data = entry.value;
          final completed = data['completed'] ?? 0;
          final total = data['total'] ?? 0;
          final rate = total > 0 ? (completed / total * 100).round() : 0;
          final cat = DailyCategory.categories.firstWhere(
            (c) => c.name == name,
            orElse: () => DailyCategory(
                name: name, emoji: '⭐', color: TropicalColors.oceanBlue),
          );
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(name,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: TropicalColors.coconut)),
                ),
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: rate / 100,
                      backgroundColor: cat.color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 50,
                  child: Text('$completed/$total',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cat.color)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBadHabitReportCard(BadHabitEntry habit) {
    final current = habit.getCurrentStreak();
    final longest = habit.getLongestStreak();
    final journey = habit.getDaysSinceStart();
    final progress = longest > 0 ? current / longest : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: TropicalColors.palmGreen.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(habit.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(habit.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TropicalColors.coconut)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: TropicalColors.palmGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$current days clean',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: TropicalColors.palmGreen)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: TropicalColors.palmGreen.withOpacity(0.15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(TropicalColors.palmGreen),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text('Journey: $journey days',
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF8B7355))),
              ),
              Text('Best: $longest days',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: TropicalColors.oceanBlue)),
              const SizedBox(width: 10),
              Text('${habit.getTotalRelapses()} slips',
                  style: const TextStyle(
                      fontSize: 10, color: TropicalColors.sunsetOrange)),
            ],
          ),
        ],
      ),
    );
  }
}

// ============= WEEKLY CALENDAR VIEW =============

class WeeklyCalendarView extends StatefulWidget {
  final Map<int, WeeklyGoal> savedEntries;
  final List<WeeklyCategory> categories;
  final Map<String, bool> checkboxStates;
  final Function(String) onCheckboxToggle;

  const WeeklyCalendarView({
    super.key,
    required this.savedEntries,
    required this.categories,
    required this.checkboxStates,
    required this.onCheckboxToggle,
  });

  @override
  State<WeeklyCalendarView> createState() => _WeeklyCalendarViewState();
}

class _WeeklyCalendarViewState extends State<WeeklyCalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border:
                Border(bottom: BorderSide(color: TropicalColors.sky, width: 1)),
          ),
          child: Row(
            children: [
              const Text('🌊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text('Weekly Calendar',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: TropicalColors.deepSea)),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done 🌺',
                    style: TextStyle(
                        color: TropicalColors.oceanBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  _focusedDay =
                      DateTime(_focusedDay.year, _focusedDay.month - 1);
                }),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.chevron_left,
                      color: TropicalColors.oceanBlue),
                ),
              ),
              const SizedBox(width: 16),
              Text(DateFormat('MMMM yyyy').format(_focusedDay),
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: TropicalColors.deepSea)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => setState(() {
                  _focusedDay =
                      DateTime(_focusedDay.year, _focusedDay.month + 1);
                }),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.chevron_right,
                      color: TropicalColors.oceanBlue),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildCalendarGrid(),
                if (_selectedDay != null) ...[
                  const Divider(color: TropicalColors.sky),
                  const SizedBox(height: 8),
                  _buildDayDetails(_selectedDay!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;

    final List<Widget> dayWidgets = [];
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    for (var name in dayNames) {
      dayWidgets.add(Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(name,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: TropicalColors.coconut),
            textAlign: TextAlign.center),
      ));
    }

    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(Container());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedDay.year, _focusedDay.month, day);
      final isSelected = _selectedDay != null && _isSameDay(_selectedDay!, date);
      final hasGoals = _hasGoalsForDay(date);

      dayWidgets.add(
        GestureDetector(
          onTap: () => setState(() => _selectedDay = date),
          child: Container(
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [TropicalColors.oceanBlue, TropicalColors.teal])
                  : hasGoals
                      ? LinearGradient(colors: [
                          TropicalColors.palmGreen.withOpacity(0.2),
                          TropicalColors.teal.withOpacity(0.2),
                        ])
                      : null,
              color: isSelected || hasGoals ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    isSelected ? TropicalColors.oceanBlue : Colors.transparent,
              ),
            ),
            child: Column(
              children: [
                Text(day.toString(),
                    style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : TropicalColors.deepSea,
                        fontSize: 14)),
                if (hasGoals)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Colors.white : TropicalColors.palmGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      children: dayWidgets,
    );
  }

  bool _hasGoalsForDay(DateTime day) {
    final dayName = DateFormat('EEEE').format(day);
    for (int i = 0; i < widget.categories.length; i++) {
      final entry = widget.savedEntries[i];
      if (entry != null && entry.day == dayName) return true;
    }
    return false;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildDayDetails(DateTime day) {
    final dayName = DateFormat('EEEE').format(day);
    final List<Widget> widgets = [];

    for (int i = 0; i < widget.categories.length; i++) {
      final entry = widget.savedEntries[i];
      if (entry != null && entry.day == dayName) {
        final checkboxKey = '${day.day}_${day.month}_${day.year}_$i';
        final isChecked = widget.checkboxStates[checkboxKey] ?? false;

        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TropicalColors.sand,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isChecked ? TropicalColors.palmGreen : TropicalColors.sky,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.categories[i].color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(widget.categories[i].emoji,
                      style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.categories[i].name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: Color(0xFF8B7355))),
                      Text(entry.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: isChecked
                                ? TropicalColors.coconut.withOpacity(0.5)
                                : TropicalColors.deepSea,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: isChecked
                                ? FontWeight.w400
                                : FontWeight.w500,
                          )),
                    ],
                  ),
                ),
                Checkbox(
                  value: isChecked,
                  onChanged: (value) {
                    widget.onCheckboxToggle(checkboxKey);
                    setState(() {});
                  },
                  activeColor: TropicalColors.palmGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        );
      }
    }

    if (widgets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: Text('🌺 No weekly goals for this day',
              style: TextStyle(color: Color(0xFF8B7355), fontSize: 14)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('Goals for ${DateFormat('EEEE, MMMM d').format(day)}',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: TropicalColors.deepSea)),
        ),
        ...widgets,
      ],
    );
  }
}

// ============= MODELS =============

class DailyCategory {
  final String name;
  final String emoji;
  final Color color;

  const DailyCategory({
    required this.name,
    required this.emoji,
    required this.color,
  });

  static const List<DailyCategory> categories = [
    DailyCategory(name: 'Health', emoji: '🥥', color: Color(0xFFE63946)),
    DailyCategory(name: 'Job', emoji: '⚓', color: Color(0xFF0077B6)),
    DailyCategory(name: 'Wellness', emoji: '🌺', color: Color(0xFFAF52DE)),
    DailyCategory(name: 'Education', emoji: '🐚', color: Color(0xFFF4A261)),
    DailyCategory(name: 'Fitness', emoji: '🏄', color: Color(0xFF2A9D8F)),
    DailyCategory(name: 'Creativity', emoji: '🎨', color: Color(0xFFE76F51)),
    DailyCategory(name: 'Social', emoji: '🦩', color: Color(0xFF06D6A0)),
  ];
}

class WeeklyCategory {
  final String name;
  final String description;
  final String emoji;
  final Color color;

  const WeeklyCategory({
    required this.name,
    required this.description,
    required this.emoji,
    required this.color,
  });

  static const List<WeeklyCategory> categories = [
    WeeklyCategory(
        name: 'Health',
        description: 'Physical and mental well-being',
        emoji: '🥥',
        color: Color(0xFFE63946)),
    WeeklyCategory(
        name: 'Wealth',
        description: 'Financial goals',
        emoji: '🐚',
        color: Color(0xFF2A9D8F)),
    WeeklyCategory(
        name: 'Wellness',
        description: 'Balance and fulfillment',
        emoji: '🌺',
        color: Color(0xFFAF52DE)),
    WeeklyCategory(
        name: 'Intellect',
        description: 'Learning and growth',
        emoji: '🐠',
        color: Color(0xFF0077B6)),
    WeeklyCategory(
        name: 'Reading',
        description: 'Books and knowledge',
        emoji: '📖',
        color: Color(0xFFF4A261)),
    WeeklyCategory(
        name: 'Fitness',
        description: 'Physical activity',
        emoji: '🏄',
        color: Color(0xFF06D6A0)),
    WeeklyCategory(
        name: 'Creativity',
        description: 'Artistic and innovative',
        emoji: '🎨',
        color: Color(0xFFE76F51)),
  ];
}