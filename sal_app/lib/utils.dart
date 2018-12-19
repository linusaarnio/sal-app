import 'room.dart';

/// This is a file containing useful data structures.

/// The starting hours of schedule blocks for tekFak.
List<int> startHours = [8, 10, 13, 15, 17, 19];

int currentYear = DateTime.now().year;
int currentMonth = DateTime.now().month;
int currentDay = DateTime.now().day;

/// The base url for schedules, append an ending from urlEndingForCategorySchedule in this file to create a complete schedule url.
String scheduleBaseUrl = "https://cloud.timeedit.net/liu/web/schema/";


List<String> categoryNames = ["SU-salar"];
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
  ]
};

/// The url ending for schedule urls, append to the base url in this file to create a complete schedule url.
Map<String, String> urlEndingForCategorySchedule = {
  "SU-salar": "ri657Q5QU95ZYYQ5Q367Qjugy4Z5WY75nb5SZY.ics"
};
