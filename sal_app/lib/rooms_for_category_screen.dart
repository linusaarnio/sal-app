import 'package:flutter/material.dart';
import 'room.dart';
import 'utils.dart';
import 'tiles.dart';
import 'category.dart';
import 'ical_to_category.dart';

class RoomsForCategoryScreen extends StatefulWidget {
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

  Future<void> _createCategory() async {
    String urlString =
        scheduleBaseUrl + urlEndingForCategorySchedule[widget.categoryName];
    Uri url = Uri.parse(urlString);
    var tempCategory = await categoryFromUrl(url, widget.categoryName);
    setState(() {
      category = tempCategory;
    });
  }

  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (category == null) {
      var nowHour = TimeOfDay.now().hour;
      if (date.day != DateTime.now().day || date.month != DateTime.now().month) {
        startTime = TimeOfDay(hour: 8, minute: 15,);
      } 
      else if (nowHour == 8) {
            startTime = TimeOfDay(hour: 8, minute: 15,);
      } else if (nowHour >= 19) {
            startTime = TimeOfDay(hour: 19, minute: 15,);
      } else {
        for (var i = 0; i < startHours.length; ++i) {
          if (startHours[i] > nowHour) {
            startTime = TimeOfDay(hour: startHours[i-1], minute: 15,);
            break;
          }
        }
      }
      endTime = TimeOfDay(hour: startTime.hour +2, minute: 0,);
      await _createCategory();
    }
  }

  bool endTimeBeforeStart() {
    return (startTime.hour > endTime.hour ||
        (startTime.hour == endTime.hour && startTime.minute > endTime.minute));
  }

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

  void changeDate(BuildContext context) async {
    var newDate = await showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(Duration(days: 1)),
        lastDate: DateTime.now().add(new Duration(days: 14)),
        initialDate: date);
    setState(() {
      date = newDate ?? date;
    });
  }

  Widget dateTile(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () => changeDate(context),
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
    );
  }

  Widget timeTile(BuildContext context, bool isStartTime) {
    return Container(
        color: Colors.blue,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () => changeTime(context, isStartTime),
            child: Text(
              isStartTime ? startTime.format(context) : endTime.format(context),
              style: Theme.of(context).textTheme.display1,
              textAlign: TextAlign.center,
            ),
          ),
        ));
  }

  Widget timesRow(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      timeTile(context, true),
      timeTile(context, false),
    ]);
  }

  Widget _roomsBlock() {
    var roomtexts = <Text>[];
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
      roomtexts.add(Text(
        room.name,
        style: Theme.of(context).textTheme.display1.apply(
              color: isFree ? Colors.green : Colors.red,
            ),
      ));
    }
    return Column(
      children: roomtexts,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: (category != null)
          ? ListView(
              children: <Widget>[
                dateTile(context),
                timesRow(context),
                _roomsBlock(),
              ],
            )
          : LinearProgressIndicator(
              value: null,
            ),
    );
  }
}
