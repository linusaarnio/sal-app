import 'room.dart';

List<int> startHours = [8, 10, 13, 15, 17, 19];

int currentYear = DateTime.now().year;
int currentMonth = DateTime.now().month;
int currentDay = DateTime.now().day;

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
Map<String, String> urlEndingForCategorySchedule = {
  "SU-salar": "ri657Q5QU95ZYYQ5Q367Qjugy4Z5WY75nb5SZY.ics"
};
