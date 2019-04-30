import 'package:flutter/material.dart';

/// This is a file containing useful data structures.

/// The starting hours of schedule blocks for tekFak.
List<int> startHours = [8, 10, 13, 15, 17, 19];

enum SlideDirection { left, right }

int currentYear = DateTime.now().year;
int currentMonth = DateTime.now().month;
int currentDay = DateTime.now().day;

/// The base url for schedules, append an ending from urlEndingForCategorySchedule in this file to create a complete schedule url.
String scheduleBaseUrl = "https://cloud.timeedit.net/liu/web/schema/";

List<String> categoryNames = ["SU-salar", "ISYtan", "ISY-salar", "PC-salar"];

Map<String, List<String>> roomsInCategory = {
  "SU-salar": [
    "SU00",
    "SU01",
    "SU02",
    "SU03",
    "SU04",
    "SU10",
    "SU11",
    "SU12",
    "SU13",
    "SU14",
    "SU15/16",
    "SU17/18",
  ],
  "ISYtan": [
    "ISYtan1",
    "ISYtan2",
    "ISYtan3",
    "ISYtan4",
    "ISYtan5",
    "ISYtan6",
    "ISYtan7",
    "ISYtan8",
    "ISYtan9",
    "ISYtan10"
  ],
  "ISY-salar": [
    "RT1",
    "RT2",
    "RT3",
    "RT4",
    "TRANSISTOR",
    "ALGO",
    "BUSS",
    "DIODEN",
    "FREJ",
    "GRIN",
    "MEAD",
    "MUX1",
    "MUX2",
    "MUX3",
    "MUX4",
    "RESISTORN",
    "SOUT",
    "TYRISTORN"
  ],
  "PC-salar": [
    "PC1",
    "PC2",
    "PC3",
    "PC4",
    "PC5",
  ]
};

/// The url ending for schedule urls, append to the base url in this file to create a complete schedule url.
Map<String, String> urlEndingForCategorySchedule = {
  "SU-salar": "ri657Q5QU95ZYYQ5Q367Qjugy4Z5WY75nb5SZY.ics",
  "ISYtan":
      "ri684Q12Y66Z65Q5Y161X286y6Z652Y894Y9429Q517918XX2656346456199XY84215865X4Y6Y698X1436166X3185935460X98Y6636Z55Q37786X0Y4497Q1Yn95486.ics",
  "ISY-salar": "ri697QYQSQ3Z9YQ5nI6Z054gy7Z7ZZZX4YQ54Y6.ics",
  "PC-salar":
      "ri684Q16Y88Z65Q5Y165X786y6Z857Y894Y0479Q517918XX7856749801789X45477Q8ZnQ5Y66.ics"
};

Map<String, IconData> iconForCategory = {
  "SU-salar": Icons.code,
  "ISYtan": Icons.people_outline,
  "ISY-salar": Icons.lightbulb_outline,
  "PC-salar": Icons.computer,
};

// Colors
const Color liuBlue100 = Color(0xff00b9e7);
const Color liuTurqoise60 = Color(0xFF93d9e1);
const Color liuTurqoise40 = Color(0xFFc0e7eb);
