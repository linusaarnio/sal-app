import 'package:flutter/material.dart';
import 'utils.dart';
import 'category.dart';
import 'ical_to_category.dart';
import 'dart:async';


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

  /// Asyncrhonously creates the category from ical, will fail without internet connection.
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

  bool viewingLastAllowedDate() {
    DateTime lastDay = DateTime.now().add(Duration(
      days: 14,
    ));
    return (date.day == lastDay.day &&
        date.month == lastDay.month &&
        date.year == lastDay.year);
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
        context: context, initialTime: isStartTime ? startTime : endTime);
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
          initialDate: date);
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
    double arrowSize = 50;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          child: Icon(
            Icons.arrow_left,
            size: arrowSize,
            color: viewingToday() ? Colors.grey : Colors.black,
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
            style: Theme.of(context).textTheme.display1,
            textAlign: TextAlign.center,
          ),
        ),
        InkWell(
          child: Icon(
            Icons.arrow_right,
            size: arrowSize,
            color: viewingLastAllowedDate() ? Colors.grey : Colors.black,
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
      padding: EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () => changeTime(context, isStartTime),
        child: Text(
          isStartTime ? startTime.format(context) : endTime.format(context),
          style: Theme.of(context).textTheme.display1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// The row of both start time and end time
  Widget timesRow(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      timeTile(context, true),
      timeTile(context, false),
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
      roomtexts.add(Container(
          color: isFree ? Colors.lime[100] : Colors.orange[100],
          child: ListTile(
            title: Text(
              room.name,
              style: Theme.of(context).textTheme.display1.apply(
                    color: isFree ? Colors.green[500] : Colors.red,
                  ),
            ),
            leading: Icon(isFree ? Icons.check_circle : Icons.error,
                color: isFree ? Colors.green[500] : Colors.red),
          )));
      //roomtexts.add(Divider(color: Colors.black38,));
    }
    return Container(
        padding: EdgeInsets.only(top: 10, bottom: 50, left: 50, right: 50),
        child: Card(
            elevation: 10,
            // color: Colors.teal[200],
            child: Column(
              children: roomtexts,
            )));
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
