import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:life_balancing/Util/http/network_client.dart';
import 'package:life_balancing/model/activite_Item.dart';
import 'package:life_balancing/model/entity_mood.dart';
import 'package:life_balancing/model/goal_item.dart';
import 'package:life_balancing/model/habits_item.dart';

// get token
getHeaders({token}){
  return <String, String>{
    'Content-Type': 'application/json',
    'accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}


Future<http.Response> config(url, token) async {
  var baseUrl = network_client.Url;

  return http.get(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
}

Future<http.Response> login(url, email, password) async {
  var baseUrl = network_client.Url;
  return http.post(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
    }),
  );
}

Future<http.Response> SingUp(url, name, UserName, image, email, password, ConfirmPassword) async {
  var baseUrl = network_client.Url;

  return http.post(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      "name": UserName,
      "userName": email,
      "image": image,
      "email": email,
      "password": password,
      "ConfirmPassword": ConfirmPassword
    }),
  );
}

Future<http.Response> UpdateProfilImage(url, Image_Name, token) async {
  var baseUrl = network_client.Url;

  print("$baseUrl/$url");
  return http.put(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, String>{
      "firstName": null,
      "middleName": null,
      "lastName": null,
      "userName": null,
      "image": Image_Name,
    }),
  );
}

Future<String> SaveFile(url, String imageName) async {
  var baseUrl = network_client.Url;
  var uri = Uri.parse("$baseUrl/$url");
  Map<String, String> headers = {'Content-Type': 'multipart/form-data', 'accept': 'application/json'};
  var request = http.MultipartRequest('POST', uri);
  request.headers.addAll(headers);
  request.files.add(await http.MultipartFile.fromPath('file', imageName));
  var response = await request.send();
  var responsed = await http.Response.fromStream(response);
  var jsondata = json.decode(responsed.body);
  var filename = jsondata['data']['fileName'];
  var fileurl = jsondata['data']['url'];
  //print("filename"+filename);
  //print("fileurl"+fileurl);
  if (response.statusCode == 200) {
    return filename;
  } else {
    return null;
  }
}

Future<http.Response> getSections(url, token) async {
  var baseUrl = network_client.Url;

  return http.get(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
}

Future<http.Response> getSelectedDateJournal(url, String SelectedDate, token) async {
  var baseUrl = network_client.Url;

  return http.post(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, String>{
      'date': SelectedDate,
    }),
  );
}

Future<http.Response> getData(url, token) async {
  var baseUrl = network_client.Url;

  return http.get(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
}

//Habits

Future<http.Response> updateHabit(url, moveType, id, token) async {
  var baseUrl = network_client.Url;

  return http.put(
    Uri.parse("$baseUrl/$url/$id"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, int>{
      'move_type': moveType,
    }),
  );
}

Future<http.Response> addEntityMood(url, EntityMood entityMood, token) async {
  var baseUrl = network_client.Url;

  return http.post(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      "entity_id": entityMood.entity_id,
      "mood_id": entityMood.mood_id,
      "entity_type": entityMood.entity_type,
    }),
  );
}

Future<http.Response> createHabit(url, HabitApi habit, token) async {
  var baseUrl = network_client.Url;
  print("$baseUrl/$url");

  return http.post(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      "name": habit.habits_name,
      "image": habit.image,
      "points": habit.points,
      "section_id": habit.section_id,
      "date_type": habit.date_type,
      "repetition_type": habit.repetition,
      "repetition_number": habit.times_Remaining,
      "time_0f_habit": habit.timeOfHabit,
      "remainder_hour": habit.remainderHour,
      "remainder_min": habit.remainderMin
    }),
  );
}

Future<http.Response> updateHabitItem(url, id, HabitApi item, token) async {
  var baseUrl = network_client.Url;

  return http.put(
    Uri.parse("$baseUrl/$url/$id"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      "name": item.habits_name,
      "image": item.image,
      "points": item.points,
      "section_id": item.section_id,
      "date_type": item.date_type,
      "repetition_type": item.repetition,
      "repetition_number": item.times_Remaining,
      "time_0f_habit": item.timeOfHabit,
      "remainder_hour": item.remainderHour,
      "remainder_min": item.remainderMin
    }),
  );
}

//Mood

Future<http.Response> Do_mode(url, int modeId, String note, String date, token) async {
  var baseUrl = network_client.Url;

  return http.post(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{"moods_id": modeId, "note": note, "date": date}),
  );
}

//Goals

Future<http.Response> createGoal(url, GoalItem item, token) async {
  var baseUrl = network_client.Url;

  return http.post(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      "name": item.goal_Name,
      "image": item.image_Path,
      "points": item.points,
      "section_id": item.Section_id,
      "final_date": item.final_date.toIso8601String(),
      "duration": item.Duration,
      "tasks": item.tasks.map((task) => {'title': task.title.text}).toList(),
    }),
  );
}

Future<http.Response> updategoals(url, id, GoalItem item, token) async {
  var baseUrl = network_client.Url;

  return http.put(
    Uri.parse("$baseUrl/$url/$id"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      "name": item.goal_Name,
      "image": item.image_Path,
      "points": item.points,
      "section_id": item.Section_id,
      "final_date": item.final_date.toIso8601String(),
      "duration": item.Duration,
      //need tasks List
      "tasks": item.tasks.map((task) => {'id': task.id, 'title': task.title.text}).toList(),
    }),
  );
}

Future<http.Response> delete_goal(url, id, token) async {
  var baseUrl = network_client.Url;

  return http.delete(
    Uri.parse("$baseUrl/$url/$id"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
}

Future<http.Response> updatetask_finished_or_unFinished(url, id, token) async {
  var baseUrl = network_client.Url;

  return http.put(
    Uri.parse("$baseUrl/$url/$id"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, int>{}),
  );
}

Future<http.Response> updatetask_title(url, id, String Title, bool isFinished, token) async {
  var baseUrl = network_client.Url;

  return http.put(
    Uri.parse("$baseUrl/$url/$id"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{"title": Title, "is_Finished": isFinished}),
  );
}

Future<http.Response> updatetask_delete(url, id, token) async {
  var baseUrl = network_client.Url;

  return http.delete(
    Uri.parse("$baseUrl/$url/$id"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
}

Future<http.Response> CreateTask(url, Tasks item, token) async {
  var baseUrl = network_client.Url;

  return http.post(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(
        <String, dynamic>{"title": item.title.text, "goal_id": item.goal_id, "is_Finished": item.is_Finished}),
  );
}

Future<http.Response> canCompleteGoal(url, id, token) async {
  var baseUrl = network_client.Url;

  return http.put(
    Uri.parse("$baseUrl/$url/$id"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{}),
  );
}

Future<http.Response> getSingleGoals(url, id, token) async {
  var baseUrl = network_client.Url;

  return http.get(
    Uri.parse("$baseUrl/$url/$id"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
}

//Activity
Future<http.Response> CreateCustomActivity(
    url, String name, String ImageName, int points, int Section_id, token) async {
  var baseUrl = network_client.Url;

  return http.post(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{"name": name, "image": ImageName, "points": points, "section_id": Section_id}),
  );
}

Future<http.Response> createSingleActivite(
    url, int activityId, int moodId, String note, String DateFrom, String DateTo, String DateJournal, token) async {
  var baseUrl = network_client.Url;

  return http.post(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      "activity_id": activityId,
      "mood_id": moodId,
      "note": note,
      "form": DateFrom,
      "to": DateTo,
      "date": DateJournal
    }),
  );
}

Future<http.Response> createVisitActivity(
    url, String companyId, token) async {
  var baseUrl = network_client.Url;

  return http.post(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      "company_id": companyId,
    }),
  );
}

Future<http.Response> createQuickEntryActivities(
    url, String DateJournal, List<singleActivity> activities, token) async {
  var baseUrl = network_client.Url;

  return http.post(
    Uri.parse("$baseUrl/$url"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      "date": DateJournal,
      "activities": activities
          .map((e) => {"section_id": e.Section_id, "activity_id": e.id, "mood_id": e.Emoje_id, "note": e.notes})
          .toList()
    }),
  );
}

Future<http.Response> deleteHabit(url, id, token) async {
  var baseUrl = network_client.Url;

  return http.delete(
    Uri.parse("$baseUrl/$url/$id"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
}

Future<http.Response> getBadgeInfo(url, id, token) async {
  var baseUrl = network_client.Url;

  return http.get(
    Uri.parse("$baseUrl/$url/$id"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
}
