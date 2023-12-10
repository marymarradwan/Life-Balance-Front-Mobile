import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Goals {
  static List<GoalItem> goals = [];

  static void add_goals(GoalItem item) {
    goals.insert(0, item);
  }

  Future<http.Response> fetch_goals() async {
    var url = Uri.parse(" ");
    final response = await http.get(url);
    //final List<GoalItem> loadedOrder = [];
    final extractedData = json.decode(response.body) as GoalItem;
    if (extractedData == null) {
      return null;
    }
  }

  Future<http.Response> addGoals(GoalItem item) async {
    var url = Uri.parse(" ");

    final response = await http.post(
      url,
      body: json.encode(item),
    );
  }
}

class GoalItem {
  int id;
  int Section_id;
  String image_Path;
  String goal_Name;
  String Description;
  List<Tasks> tasks;
  DateTime final_date;
  int Duration;
  int points;
  String Time_of_the_goal;
  TimeOfDay Reminder;
  bool Complete_Goal;

  GoalItem(
      this.id,
      this.Section_id,
      this.image_Path,
      this.goal_Name,
      this.tasks,
      this.Reminder,
      this.points,
      this.Duration,
      this.final_date,
      this.Time_of_the_goal,
      [this.Description,
      this.Complete_Goal]);

  static int get_task_number(GoalItem item) {
    return item.tasks.length;
  }

  static int get_end_Task_Number(GoalItem item) {
    int end = 0;
    for (int i = 0; i < item.tasks.length; i++) {
      if (item.tasks[i].is_Finished) end++;
    }
    return end;
  }

  static double get_completion_Rate(GoalItem item) {
    int total = get_task_number(item);
    int end = get_end_Task_Number(item);
    return end / total;
  }

  static int Calculate_points(int Durations, int task_numbers) {
    if (Durations >= 14 && task_numbers >= 7)
      return 100;
    else if (Durations >= 14 && (task_numbers >= 4 && task_numbers <= 6))
      return 75;
    else if (Durations >= 14 && (task_numbers >= 2 && task_numbers <= 3))
      return 50;
    else if (Durations >= 14 && task_numbers == 1)
      return 25;
    else if ((Durations >= 7 && Durations < 14) && (task_numbers >= 4))
      return 75;
    else if ((Durations >= 7 && Durations < 14) &&
        (task_numbers >= 1 && task_numbers <= 3))
      return 50;
    else if ((Durations >= 1 && Durations <= 6) && (task_numbers >= 4))
      return 100;
    else if ((Durations >= 1 && Durations <= 6) &&
        (task_numbers >= 1 && task_numbers <= 3)) return 75;
  }

  static int Calculate_duration(DateTime final_date) {
    int duration = final_date.difference(DateTime.now()).inHours;
    if (duration < 0)
      return 0;
    else
      return duration >= 0 && duration < 24 ? 1 : 1 + (duration / 24).toInt();
  }

  @override
  String toString() {
    return '{image_Path: $image_Path, goal_Name: $goal_Name,tasks: $tasks,Reminder: $Reminder,points: $points,Duration: $Duration,final_date: $final_date,Time_of_the_goal: $Time_of_the_goal,Description: $Description,}';
  }
}

class Tasks {
  int id;
  int goal_id;
  bool is_Finished;
  TextEditingController title;

  Tasks(this.id, this.goal_id, this.is_Finished, this.title);

  @override
  String toString() {
    return '{id: $id,goal_id: $goal_id,is_Finished: $is_Finished, tasks: ${title.text},}';
  }
}

class TaskWidget {
  Tasks task;
  Widget child;

  TaskWidget(this.task, this.child);
}
