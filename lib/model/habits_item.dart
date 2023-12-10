import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Habits {
  static List<HabitItem> new_Habits = [];

  static void add_Habits(HabitItem item) {
    new_Habits.insert(0, item);
  }

  static void setHabits() async {}

  Future<http.Response> fetch_goals() async {
    var url = Uri.parse(" ");
    final response = await http.get(url);
    //final List<HabitItem> loadedOrder = [];
    final extractedData = json.decode(response.body) as HabitItem;
    if (extractedData == null) {
      return null;
    }
  }

  Future<http.Response> addGoals(HabitItem item) async {
    var url = Uri.parse(" ");

    final response = await http.post(
      url,
      body: json.encode(item),
    );
  }
}

class HabitApi {
  String image;
  int points;
  String habits_name;
  int section_id;
  int times_Remaining;
  int date_type;
  int repetition;
  String timeOfHabit;
  int remainderHour;
  int remainderMin;

  HabitApi(this.image, this.times_Remaining, this.points, this.habits_name,
      this.section_id, this.date_type, this.repetition, this.timeOfHabit , this.remainderHour , this.remainderMin);

  @override
  String toString() {
    return 'HabitApi{image: $image, points: $points, habits_name: $habits_name, section_id: $section_id, times_Remaining: $times_Remaining, date_type: $date_type, repetition: $repetition, timeOfHabit: $timeOfHabit, remainderHour: $remainderHour, remainderMin: $remainderMin}';
  }
}

class HabitItem {
  String image;
  String section_title;
  int times_Remaining;
  int points;
  DateTime starting_Day;
  String habits_name;
  String time_Of_The_Habits;
  TimeOfDay Reminder;
  PerformHabits repeat;
  int id;
  String activeDate;
  int section_id;
  int date_type;
  int repetition;
  int Points_earned;

  HabitItem(
      this.id,
      this.image,
      this.section_title,
      this.times_Remaining,
      this.points,
      this.habits_name,
      this.Reminder,
      this.starting_Day,
      this.time_Of_The_Habits,
      this.repeat,
      [this.activeDate,
      this.section_id,
      this.date_type,
      this.repetition]
      // [this.section_id],
      );

  @override
  String toString() {
    return '{image: $image, section_title: $section_title,times_Remaining: $times_Remaining,points: $points,habits_name: $habits_name,Reminder: $Reminder,starting_Day: $starting_Day,time_Of_The_Habits: $time_Of_The_Habits,repeat: $repeat}';
  }
}

class PerformHabits {
  String repeat_The_Habits;
  List<String> days = [];

  PerformHabits(
    this.repeat_The_Habits,
    this.days,
  );

  @override
  String toString() {
    return '{repeat_The_Habits: $repeat_The_Habits, days: $days,}';
  }
}
