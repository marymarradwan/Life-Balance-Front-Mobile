import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Emoje{
  int id;
  String emoje_path;
  String emoje_name;
  bool isClicked;
  Emoje(this.id,this.emoje_path,this.emoje_name,this.isClicked);

  Emoje.clone(Emoje source) :
        this.id = source.id,
        this.emoje_path = source.emoje_path,
        this.emoje_name = source.emoje_name,
        this.isClicked = source.isClicked;
        /*this.adjacentNodes = source.adjacentNodes.map((item) => new MyModal.clone(item)).toList();*/


  @override
  String toString() {

    return '{emoje_path: $emoje_path, emoje_name: $emoje_name,isClicked: $isClicked}';
  }
}

class singleActivity{
  int id ;
  int Section_id;
  String name;
  String image;
  int points;
  bool isClicked;
  bool Fav;
  List<Emoje> Emoji;
  String trailing_path;
  //String image_Mood_path;
  DateTime from_time;
  DateTime to_time;
  String notes;
  int Emoje_id;
  bool expanded;
  singleActivity(this.id,this.Section_id,this.name,this.image,this.points,this.isClicked,this.expanded,[this.Fav,this.Emoji,this.trailing_path,this.from_time,this.to_time,this.notes,this.Emoje_id]);
  @override
  String toString() {

    return '{id: $id, Section_id: $Section_id,name: $name,image: $image,points: $points,trailing_path: $trailing_path,Emoje_id: $Emoje_id,notes: $notes}';
  }
}

class SectionActivities{
  int id;
  String SectionName;
  List<singleActivity> activities;

  SectionActivities(this.id,this.SectionName,this.activities);
  @override
  String toString() {

    return '{id: $id, SectionName: $SectionName,activities: $activities}';
  }
}
