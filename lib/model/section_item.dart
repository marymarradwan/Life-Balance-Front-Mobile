import 'dart:core';

import 'package:flutter/material.dart';

class SectionItem {
  String image_Path;
  String section_Name;
  IconData icon;
  int id;
  Color color;

  SectionItem(
    this.icon,
    this.image_Path,
    this.section_Name,
    this.color,
    this.id,
  );
}

class Sections {
  static List<SectionItem> sections = [];
}
