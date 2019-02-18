import 'package:flutter/material.dart';
import 'utils.dart';
import 'category.dart';
import 'ical_to_category.dart';
import 'dart:async';
import 'dart:ui';

Color activeArrowColor = Colors.grey[600];
Color disabledArrowColor = Colors.grey[300];
double fontSizeFactor = 0.5;

/// The screen showing which rooms are free for a chosen category.
class RoomsForCategoryScreen extends StatefulWidget {
  /// The name of the category this screen is showing rooms for.
  final String categoryName;

  RoomsForCategoryScreen(this.categoryName);

  @override
  _RoomsForCategoryScreenState createState() => _RoomsForCategoryScreenState();
}

class _RoomsForCategoryScreenState extends State<RoomsForCategoryScreen> {
  Category category;
  DateTime date = DateTime.now();
  TimeOfDay startTime; // change this
  TimeOfDay endTime;

  /// Asynchronously creates the category from ical, will fail without internet connection.
  Future<void> _createCategory() async {
    String urlString =
        scheduleBaseUrl + urlEndingForCategorySchedule[widget.categoryName];
    Uri url = Uri.parse(urlString);
    var tempCategory = await categoryFromUrl(url, widget.categoryName);
    setState(() {
      category = tempCategory;
    });
  }

  /// Runs after initState and whenever dependencies are changed.
  /// Creates category if it doesn't exist and correctly sets initial times.
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (category == null) {
      var nowHour = TimeOfDay.now().hour;
      if (!viewingToday()) {
        startTime = TimeOfDay(
          hour: 8,
          minute: 15,
        );
      } else if (nowHour == 8) {
        startTime = TimeOfDay(
          hour: 8,
          minute: 15,
        );
      } else if (nowHour >= 19) {
        startTime = TimeOfDay(
          hour: 19,
          minute: 15,
        );
      } else {
        for (var i = 0; i < startHours.length; ++i) {
          if (startHours[i] > nowHour) {
            startTime = TimeOfDay(
              hour: startHours[
                  i - 1], // Starthour will be the latest passed hour.
              minute: 15,
            );
            break;
          }
        }
      }
      endTime = TimeOfDay(
        hour: startTime.hour + 2,
        minute: 0,
      );
      await _createCategory();
    }
  }

  /// Is the chosen date todays date?
  bool viewingToday() {
    DateTime today = DateTime.now();
    return (date.day == today.day &&
        date.month == today.month &&
        date.year == today.year);
  }

  /// Is the chosen date the last date we have info for?
  bool viewingLastAllowedDate() {
    DateTime lastDay = DateTime.now().add(Duration(
      days: 14,
    ));
    return (date.day == lastDay.day &&
        date.month == lastDay.month &&
        date.year == lastDay.year);
  }

  /// Is the chosen time at or before the first schedule block?
  bool viewingFirstBlock() {
    return startTime.hour <= startHours[0];
  }

  /// Is the chosen time at or after the last schedule block?
  bool viewingLastBlock() {
    return startTime.hour >= startHours[startHours.length - 1];
  }

  /// Is the end time set to be before the start time?
  bool endTimeBeforeStart() {
    return (startTime.hour > endTime.hour ||
        (startTime.hour == endTime.hour && startTime.minute > endTime.minute));
  }

  /// Shows a time picker, and sets either starttime or endtime (depending on the parameter isStartTime)
  /// to the chosen time.
  /// If the user sets endtime before starttime, it tries to ajust the not set time to fit normal schedule block times.
  void changeTime(BuildContext context, bool isStartTime) async {
    var newTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? startTime : endTime,
    );
    setState(() {
      if (isStartTime) {
        startTime = newTime ?? startTime;
        if (endTimeBeforeStart()) {
          endTime = TimeOfDay(hour: startTime.hour + 2, minute: 0);
        }
      } else {
        endTime = newTime ?? endTime;
        if (endTimeBeforeStart()) {
          startTime = TimeOfDay(hour: endTime.hour - 2, minute: 15);
        }
      }
    });
  }

  /// Switches to the schedule block before the chosen starthour.
  void previousScheduleBlock() {
    int nowHour = startTime.hour;
    for (var i = 1; i < startHours.length; ++i) {
      if (startHours[i] >= nowHour) {
        setState(() {
          startTime = TimeOfDay(
            hour:
                startHours[i - 1], // Starthour will be the latest passed hour.
            minute: 15,
          );
          endTime = TimeOfDay(hour: startTime.hour + 2, minute: 0);
        });
        return;
      }
    }
    setState(() {
      startTime = TimeOfDay(
        hour: startHours[startHours.length - 1],
        minute: 15,
      );
      endTime = TimeOfDay(hour: startTime.hour + 2, minute: 0);
    });
  }

  /// Switches to the schedule block after the chosen starthour.
  void nextScheduleBlock() {
    int nowHour = startTime.hour;
    for (var i = 0; i < startHours.length; ++i) {
      if (startHours[i] > nowHour) {
        setState(() {
          startTime = TimeOfDay(
            hour: startHours[i], // Starthour will be the latest passed hour.
            minute: 15,
          );
          endTime = TimeOfDay(hour: startTime.hour + 2, minute: 0);
        });
        break;
      }
    }
  }

  /// Changes date with duration.
  /// If duration = null,shows a datepicker and sets the date to the chosen date (you can choose earliest yesterday and latest two weeks ahead).
  /// Sets times to the first schedule block.
  void changeDate(BuildContext context, Duration duration) async {
    var newDate;
    if (duration == null) {
      newDate = await showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(Duration(days: 1)),
        lastDate: DateTime.now().add(new Duration(days: 14)),
        initialDate: date,
      );
    } else {
      newDate = date.add(duration);
    }
    setState(() {
      date = newDate ?? date;
      startTime = TimeOfDay(hour: 8, minute: 15);
      endTime = TimeOfDay(hour: 10, minute: 0);
    });
  }

  /// The tile that shows the chosen date, will show a time picker to change date on click.
  Widget dateTile(BuildContext context) {
    double arrowSize = 40;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          child: Icon(
            Icons.arrow_left,
            size: arrowSize,
            color: viewingToday() ? disabledArrowColor : activeArrowColor,
          ),
          onTap: () =>
              viewingToday() ? null : changeDate(context, Duration(days: -1)),
        ),
        InkWell(
          onTap: () => changeDate(context, null),
          child: Text(
            date.year.toString() +
                "-" +
                date.month.toString() +
                "-" +
                date.day.toString(),
            style: Theme.of(context)
                .textTheme
                .display1
                .apply(fontSizeFactor: fontSizeFactor),
            textAlign: TextAlign.center,
          ),
        ),
        InkWell(
          child: Icon(
            Icons.arrow_right,
            size: arrowSize,
            color: viewingLastAllowedDate()
                ? disabledArrowColor
                : activeArrowColor,
          ),
          onTap: () => viewingLastAllowedDate()
              ? null
              : changeDate(context, Duration(days: 1)),
        )
      ],
    );
  }

  /// A tile that shows a time, will change either start or end time on click (depending on parameter isStartTime)
  Widget timeTile(BuildContext context, bool isStartTime) {
    return Padding(
      padding: EdgeInsets.only(top: 4, bottom: 4),
      child: InkWell(
        onTap: () => changeTime(context, isStartTime),
        child: Text(
          isStartTime ? startTime.format(context) : endTime.format(context),
          style: Theme.of(context)
              .textTheme
              .display1
              .apply(fontSizeFactor: fontSizeFactor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// The row of both start time and end time
  Widget timesRow(BuildContext context) {
    double iconSize = 40;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      IconButton(
        icon: Icon(Icons.arrow_left,
            size: iconSize,
            color: viewingFirstBlock() ? disabledArrowColor : activeArrowColor),
        onPressed: () => previousScheduleBlock(),
      ),
      timeTile(context, true),
      Text(
        " - ",
        style: Theme.of(context).textTheme.display1.apply(),
      ),
      timeTile(context, false),
      IconButton(
        icon: Icon(
          Icons.arrow_right,
          size: iconSize,
          color: viewingLastBlock() ? disabledArrowColor : activeArrowColor,
        ),
        onPressed: () => nextScheduleBlock(),
      ),
    ]);
  }

  /// The block which shows the rooms and indicates wheter they are free or not for the chosen date and times.
  Widget _roomsBlock() {
    var roomtexts = <Widget>[];
    for (var room in category.rooms) {
      var isFree = room.isFreeBetween(
          DateTime(
            date.year,
            date.month,
            date.day,
            startTime.hour,
            startTime.minute,
          ),
          DateTime(
            date.year,
            date.month,
            date.day,
            endTime.hour,
            endTime.minute,
          ));
      roomtexts.add(Chip(
        backgroundColor: isFree ? Colors.lime[200] : Colors.orange[200],
        label: Text(
          room.name,
          style: Theme.of(context).textTheme.display1.apply(
                color: isFree ? Colors.green[500] : Colors.red,
                fontSizeFactor: 0.7,
              ),
        ),
      ));
      //roomtexts.add(Divider(color: Colors.black38,));
    }
    return Container(
        padding: EdgeInsets.only(top: 10, bottom: 50, left: 20, right: 20),
        child: Wrap(
              children: roomtexts,
              spacing: 8.0,
              runSpacing: 4.0,
            ));
  }

  Widget _dateTimeBlock(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 15, bottom: 10, left: 20, right: 20),
        child: Card(
            elevation: 5,
            color: Colors.teal[50],
            child: Column(
              children: <Widget>[
                Center(child: dateTile(context)),
                timesRow(context)
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: (category != null)
          ? ListView(
              children: <Widget>[
                _dateTimeBlock(context),
                _roomsBlock(),
              ],
            )
          : LinearProgressIndicator(
              value: null,
            ),
    );
  }
}
